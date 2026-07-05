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

## 2. Root `+lib` dependency (extract camouflage-domain code into this repo) — LEFT AS-IS (user's call, not this pass)
Camo has **no local `+lib`**; every `lib.*` call resolves to the lab-root `+lib`.
The live experiment path depends on it heavily. Split it:
- **Camouflage-domain code → move into this repo** (a domain package, e.g. `+camo`):
  `stimulus`, `target_mask`, `edge_measures`, `edge_measures_ideal`, `edge_vector_ideal`,
  `edge`, `gauss_llr`, `find_spot_centers`, `embedImageinCenter`, and the filter-bank
  builders `gabor2D`/`differenceOfGaussians2D`/`haar2D`/`spot2D` + `fftconv2`/`cropImage`/
  `samplePatchCoordinates` (used by `+stats`).
- **Generic DV/optics → adopt from vision-commons** where an equivalent exists
  (`otf_filter`→`vislib.otf_filter` after the 3-channel-bug check; any Rp/Rh/Re usage
  → `nat_stat_bayes`).
- Then drop the root-`+lib` dependency and remove the `root_parent` `addpath` from `setup.m`.

## 3. Dangling `lib.*` references (BROKEN — fix or drop as dead) — LEFT AS-IS (user's call)
Mostly in `+tinker` prototypes and the `_texture_exponent`/`_shape_exponent` variant scripts:
`lib.circular_mask`, `lib.pink_noise_2d`, `lib.edge_vector` (only `edge_vector_ideal` exists),
`lib.whiten_pink_noise_square`, `lib.compute_dPrime_pCorrect`, `lib.new_edge`,
`lib.cosWindowFlattop2`, `lib.reverse_pink_noise_square`. Confirm they're off the live path,
then fix or delete.

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
- Some legacy scripts pass wavelength **555 nm** (`test.m`: `lib.otf_filter(stim,ppd,4,555)`); the
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
