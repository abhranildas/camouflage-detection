# CLEANUP.md — camouflage_detection

Tracked removals/reconciliations for the vision-commons migration. Per the user's
directive, nothing here has been **deleted** — this file *flags* everything for a
later batch review/approval. Items marked **DONE** were purely additive.

Unlike texture-segmentation, camouflage_detection's live decision variables are all
camouflage-specific (edge-power / ideal-observer), so there were **no verified
drop-in DV repointings** in the live path this pass — the commons adoption here is
mostly the shared PTB harness (deferred) plus the flagged items below.

---

## 1. `edgecode/` (standalone legacy)
- 4th copy of the `Rp/Rh/Re/Rs` decision variables (+ `mk_contour.m`, and
  `texture_discrimination.m` which references a **missing `mk_win.m`**). `Rs` is now
  `nat_stat_bayes.dv_spatial` (promoted, verified identical). Fold `Rp/Rh/Re` onto
  `nat_stat_bayes.{dv_power,dv_spot_hist,dv_edge_hist}` or delete the tree.

## 2. Root `+lib` dependency (extract camouflage-domain code into this repo)
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

## 3. Dangling `lib.*` references (BROKEN — fix or drop as dead)
Mostly in `+tinker` prototypes and the `_texture_exponent`/`_shape_exponent` variant scripts:
`lib.circular_mask`, `lib.pink_noise_2d`, `lib.edge_vector` (only `edge_vector_ideal` exists),
`lib.whiten_pink_noise_square`, `lib.compute_dPrime_pCorrect`, `lib.new_edge`,
`lib.cosWindowFlattop2`, `lib.reverse_pink_noise_square`. Confirm they're off the live path,
then fix or delete.

## 4. Stale hardcoded absolute paths
- `+experiment/+analysis/computeBootstrappedThreshold.m:37,41` — `/Users/steve/Dropbox/...` and
  `C:\Users\sebastian\Dropbox\...`. Replace with `config.paths.exp_files` (the rest of `+analysis`
  already loads from relative `exp_files/...`).

## 5. Duplicates / orphans / bugs
- `gammaCorrect` exists **three** ways: `+experiment/gammaCorrect.m`, `lib.gammaCorrect`, and
  `vislib.gamma_compress`/`gamma_expand`. Consolidate.
- `+experiment/occludingTarget.m` — references undefined `background` (should be `backgroundImg`); dead.
- `+experiment/saveCurrentSession.m` — buggy `save(...)` (passes a value, not a name) + an
  inconsistent path scheme; orphaned relative to the live `saveCurrentLevel`.
- `+experiment/subjectExperimentFile_alpha.m` — byte-identical duplicate of `subjectExperimentFile.m`.
- `.asv` autosaves (e.g. `+general/compute_edge_props_exp_eq.asv`, `..._full.asv`).

## 6. Copy-paste experiment-variant families (canonicalize with a parameter)
- `generate_camouflage_stimuli{,_all,_diff_bg,_shape_exponent,_texture_exponent}.m`,
  `sessionSettings{,_all,_diff_bg,_shape_exponent,_texture_exponent}.m`,
  `setUpExperiment{,_all,_diff_bg,_search,_shape_exponent,_texture_exponent}.m`. Heavy duplication;
  fold into one parameterized generator/settings/setup per family.

## 7. Data reconciliation
- `data/edge_powers/natural/*.mat` (source/derivation) vs `global_data/edge_powers/*.mat` (deployed,
  read by `experiment.setUpExperiment`). Keep one canonical location to avoid drift.

## 8. Optics constant
- Some legacy scripts pass wavelength **555 nm** (`test.m`: `lib.otf_filter(stim,ppd,4,555)`); the
  other repos and `config.m` use 550. Confirm the canonical value with Geisler.

## 9. Experiment harness → `vision-commons/+psychexp` (separate pass, needs PTB testing)
- camo's single-copy `+experiment` (`+main` runtime, `+analysis` offline, root stimulus/session code)
  is the **better template** for the shared harness than texseg's duplicated one. Unify the loop
  skeleton + intervals + session resume/save + **optional EyeLink** plug-in into `+psychexp`; keep
  camo's dependency-injected `loadSessionStimuli` pattern; leave `runCamouflageExperiment_search.m`
  as a standalone escape hatch. Deferred (can't verify headlessly); ships with a manual test checklist.
