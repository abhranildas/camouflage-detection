# CLEANUP.md — camouflage_detection

Tracked removals/reconciliations for the vision-commons migration. Per the user's
directive, nothing here has been **deleted** — this file *flags* everything for a
later batch review/approval. Items marked **DONE** were purely additive.

Unlike texture-segmentation, camouflage_detection's live decision variables are all
camouflage-specific (edge-power / ideal-observer), so there were **no verified
drop-in DV repointings** in the live path this pass — the commons adoption here is
mostly the shared PTB harness (deferred) plus the flagged items below.

---

## 1. `edgecode/` — REMOVED (done)
- Deleted the whole `edgecode/` folder (`Rp/Rh/Re/Rs`, `mk_contour.m`, `texture_discrimination.m`): a
  redundant 4th copy of the DV code, not on the live experiment path. `Rs` was already promoted to
  `nat_stat_bayes.dv_spatial` (verified identical). Recoverable in git history if ever needed.

## 2. Root `+lib` dependency (extract camouflage-domain code into this repo) — DONE
Camo now has its **own local `+lib`** (mirrors texture-segmentation's structure); it no
longer depends on the lab-root `+lib`. What was done this pass:
- **Copied the reachable set (56 functions)** from lab-root `+lib` into
  `camouflage_detection/+lib/` — every function camo calls, plus every function those
  call internally (transitive closure). Chosen over copying the whole root `+lib` to keep
  the repo clean: ~11 root functions camo never uses (`imblur`, `freqSpace`, `dPrime`,
  `discrim_accuracy`, `coloured_noise`, `pinken`, `samplePositions`, `csf_filter`,
  `correlations_across_same`, `create_porsim_square`, `integer_partition`) were **not**
  copied. **Nothing was deleted from root `+lib`** — it stays intact for texture-segmentation.
- **`otf_filter` → repointed to `vislib.otf_filter`** at all camo call sites
  (`test.m`, `+general/compute_edge_props_pink_noise.m`,
  `+general/compute_nat_img_eff_coding_bins.m`) and inside the copied
  `+lib/edge_props_stim.m`. Verified numerically equivalent to root's copy for camo's
  usage (grayscale, and per-channel for the texture case); vislib's version additionally
  handles color images in one call.
- **`edge_props_stim` kept in local `+lib`** (not promoted to vision-commons): it pulls in
  camouflage-domain code (`target_mask`, `steerable_grad`, `detect_edge_pixels`,
  `trace_contours`), so it doesn't belong in the generic shared library.
- **`setup.m` no longer adds the lab-root `+lib`** (`root_parent` addpath removed); the
  header + README were updated to describe the local `+lib`.
- **LATENT BUG carried over as-is (not fixed):** `+lib/ptch_norm.m` — its mean+contrast
  branch (`ntype==2`) references an undefined variable `m` and would error. Copied faithfully
  to preserve current behavior; camo's live path doesn't hit `ntype==2`. (vision-commons has
  a corrected `vislib.ptch_norm` with a different signature; a future pass could repoint to it
  after checking camo's call sites.)

## 3. Dangling `lib.*` references (BROKEN — fix or drop as dead) — LEFT AS-IS (user's call)
Mostly in `+tinker` prototypes and the `_texture_exponent`/`_shape_exponent` variant scripts:
`lib.circular_mask`, `lib.pink_noise_2d`, `lib.edge_vector` (only `edge_vector_ideal` exists),
`lib.whiten_pink_noise_square`, `lib.compute_dPrime_pCorrect`, `lib.new_edge`,
`lib.cosWindowFlattop2`, `lib.reverse_pink_noise_square`, `lib.gammaCorrect`. Confirm they're
off the live path, then fix or delete. These name functions that don't exist in root `+lib`
either, so they were already broken before the extraction — the local `+lib` doesn't change that.
- A few live in functions that got copied into the local `+lib`: `circular_mask` (called by
  `edge_shape`, `stimulus_spots`, `mismatch_template`), `whiten_pink_noise_square` (called by
  `mismatch_template`), and `contour_props` (a commented-out line in `edge_measures.m:43`, so inert).
  These callers are camo-exploratory (not on the live experiment path) and would already error if run.

## 4. Stale hardcoded absolute paths — LEFT AS STALE (user's call; `computeBootstrappedThreshold` uses an outdated per-block data scheme)
- `+experiment/+analysis/computeBootstrappedThreshold.m:37,41` — `/Users/steve/Dropbox/...` and
  `C:\Users\sebastian\Dropbox\...`. Replace with `config.paths.exp_files` (the rest of `+analysis`
  already loads from relative `exp_files/...`).

## 5. Duplicates / orphans / bugs
- **DONE:** removed `+experiment/occludingTarget.m` (dead, undefined `background`, unreferenced) and
  `+experiment/saveCurrentSession.m` (buggy + orphaned, superseded by `saveCurrentLevel`). Removed the
  byte-identical duplicate `+experiment/subjectExperimentFile_alpha.m` and repointed its two callers
  (`setUpExperiment_shape_exponent`, `setUpExperiment_texture_exponent`) to `experiment.subjectExperimentFile`.
- `.asv` autosaves — already git-ignored (`*.asv` in `.gitignore`); not in the repo, nothing to do.
- **Pending:** `gammaCorrect` exists **three** ways — `+experiment/gammaCorrect.m`, `lib.gammaCorrect`,
  and `vislib.gamma_compress`/`gamma_expand`. Consolidate (touches experiment code; do with the +lib pass).

## 6. Copy-paste experiment-variant families (canonicalize with a parameter) — LEFT AS-IS (user's call)
- `generate_camouflage_stimuli{,_all,_diff_bg,_shape_exponent,_texture_exponent}.m`,
  `sessionSettings{,_all,_diff_bg,_shape_exponent,_texture_exponent}.m`,
  `setUpExperiment{,_all,_diff_bg,_search,_shape_exponent,_texture_exponent}.m`. Heavy duplication;
  fold into one parameterized generator/settings/setup per family.

## 7. Data reconciliation
- `data/edge_powers/natural/*.mat` (source/derivation) vs `global_data/edge_powers/*.mat` (deployed,
  read by `experiment.setUpExperiment`). Keep one canonical location to avoid drift.

## 8. Optics constant
- Some legacy scripts pass wavelength **555 nm** (`test.m`: `vislib.otf_filter(stim,ppd,4,555)`); the
  other repos and `config.m` use 550. **User's own call** (camo is the user's repo — not a Geisler question).

## 9. Experiment harness → `vision-commons/+psychframework` (separate pass, needs PTB testing)
- camo's single-copy `+experiment` (`+main` runtime, `+analysis` offline, root stimulus/session code)
  is the **better template** for the shared harness than texseg's duplicated one. Unify the loop
  skeleton + intervals + session resume/save + **optional EyeLink** plug-in into `+psychframework`; keep
  camo's dependency-injected `loadSessionStimuli` pattern; leave `runCamouflageExperiment_search.m`
  as a standalone escape hatch.
- **DONE:** `vision-commons/+psychframework` (shared session→level→trial loop) added; `runCamouflageExperiment.m`
  now delegates the loop/screen/teardown to it, wiring camo's interval functions + EyeLink lifecycle
  (session/level/trial pre/post hooks, gated by `S.bFovea`) as hooks. The superseded `runSession.m` and
  `runTrial.m` were **deleted** (commit `5301e73`). Parse-verified; not headless-testable (Psychtoolbox) —
  PTB validation waived by the user. `runCamouflageExperiment_search.m` remains as a standalone escape hatch.
