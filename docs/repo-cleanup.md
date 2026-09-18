# Repo-wide cleanup plan

✅ done · 🚧 in progress · ⬜ not started

---

<details open>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">0. Status</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">🚧 0.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

**Description.** Comments, header docs, whitespace, operator and bracket spacing, indentation, reflow, blank-line grouping, file-local renames, plus function and file renames repo-wide (step 2a), and triaging any commented-out code found in each tranche's files (verdict only, nothing deleted). Checked by `isequal` on a canonical AST fingerprint — no execution needed.

**Status.** Tranches 0.1.2–0.1.10 predate the mandatory-snake_case rule, and 0.1.1 ran after them rather than before, so it also swept their headers, `See also` lines and `Contents.m` for the old names (see S2.19 for the in-file camelCase retrofit this still leaves open). `+stats/` (12 files) is entirely `_`-prefixed known-dead code, excluded from scope the same way it was in the original survey — no tranche assigned to it unless S3.6 revives it.

**To-do.**

- [x] **0.1.0.** Tooling: `canon`/`check_stage1`/`assert_rename_bijection`, golden-output harness — MATLAB R2024b Update 6.
- [x] **0.1.1.** Function and file renames, repo-wide — 38 renames (map in 3.1.1), verified over all 204 `.m` files.
- [x] **0.1.2.** `+lib/` edge & stimulus core — 14 files, 948 lines. **Sets in-file naming conventions for everything downstream.** *(predates snake_case mandate — see 3.1.3)*
- [x] **0.1.3.** `+lib/edge_props_stim.m` — 1 file, 535 lines.
- [x] **0.1.4.** `+lib/` remainder — 39 files cleaned of 41 listed, 1484 lines (`ptch_norm.m`/`watson_otf.m` excluded — S3.11's job).
- [x] **0.1.5.** `+experiment/+main/` — 11 files, 714 lines. *(camelCase family, deliberately not converted, predates the snake_case mandate — see S2.19)*
- [x] **0.1.6.** `+experiment/+analysis/` — 12 files, 787 lines. *(mixed camel/snake, deliberately preserved as found)*
- [x] **0.1.7.** `+experiment/` top level, incl. variant families — 26 files, 1390 lines. *(mixed camel/snake, deliberately preserved as found)*
- [x] **0.1.8.** `+general/` live model chain — 4 files, 833 lines (`compute_nat_img_eff_coding_bins.m`, `compute_edge_props_exp_pca.m`, `fit_edge_model_with_exps.m`, `compute_nll_edge_model.m`).
- [x] **0.1.9.** `+general/` remainder — 27 files, 1641 lines.
- [x] **0.1.10.** `+vis/` + `+tests/` — 10 files, 484 lines. *(per-file convention, genuinely mixed authorship)*
- [ ] **0.1.11.** `+tinker/` — 13 files, 1040 lines. **Not started.** → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [ ] **0.1.12.** Root files: `config.m`, `setup.m`, `edge_power_demo.m`, `scratch.m`, `test_erlang.m` — 5 files, 356 lines. **Not started.** → `matlab-cleanup-lead` (`model: "opus"`)

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.2 · Stage 2 · Tidying</h3></summary>

<div style="margin-left:1.5em">

**Description.** Adding a suppressing `;`, preallocation, `find`→logical indexing, deleting a provably unused assignment. Checked by a whitelisted-pattern diff **plus** a runtime golden-output match. A closed list of four: anything bigger is a Speed item (0.5).

**Status.** Not started. Only the `+lib/` core chain and the three psychometric functions in `+experiment/+analysis/` are covered by the golden harness (see 2) — everything else is pattern-check only.

**To-do.**

- [ ] **0.2.0.** Extend the golden harness to cover every tranche not yet in its 16-entry-point/32-field coverage.
- [ ] **0.2.1.** `+lib/` (tranches 0.1.2–0.1.4) — golden-checked.
- [ ] **0.2.2.** `+experiment/+analysis/` (tranche 0.1.6) — golden-checked for the three psychometric functions, pattern-only for the rest.
- [ ] **0.2.3.** `+experiment/` and `+experiment/+main/` (tranches 0.1.5, 0.1.7) — pattern-check only.
- [ ] **0.2.4.** `+general/` (tranches 0.1.8, 0.1.9) — pattern-check only.
- [ ] **0.2.5.** `+vis/`, `+tests/`, `+tinker/`, root — pattern-check only.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.3 · Stage 3 · Structure</h3></summary>

<div style="margin-left:1.5em">

**Description.** Signature changes, `arguments` blocks, merging duplicate functions, reordering statements, float/RNG-order changes, renaming a config struct field or a frozen `save`/`load` name, acting on the Stage 1 commented-out-code triage — not behaviour-preserving, done after Stage 1/2. **Rating:** 🔴 clear win, low risk · 🟠 real cost (design decision or wide call-site surface) · 🟡 marginal, defer. Id `S<tier>.<n>`, never renumbered.

**Status.** None started. S3.5 (smoke test) and the snake_case retrofit question (S2.19) should both be resolved early, before more Style tranches compound the divergence.

**To-do.**

- [ ] 🔴 **S1.1.** Fix `edge_power_demo`/patch-location border margin (resolves B1.11 once judged non-latent).
- [ ] 🔴 **S1.4.** Pick one edge-power definition — `lib.edge` vs `lib.edge_vector_ideal`/`edge_measures_ideal` (resolves B1.1). Open decision on `normalize` default.
- [ ] 🔴 **S1.9.** Rename zone-2 cross-file name-value parameters repo-wide (full list in 3.1.1).
- [ ] 🔴 **S1.12.** Add `arguments` blocks repo-wide (none exist; 11 files use `inputParser`).
- [ ] 🔴 **S1.13.** Remove dead scaffolding in the live path (global `bdry_ribbon`, duplicate write, debug `randi(10)`/`imshow`, 3 unconditional bar plots) — 7 named sites.
- [ ] 🔴 **S1.14.** Consolidate the 3 gamma-compression implementations onto `vislab.lib.gamma_compress`. Tranche 0.1.1 established that only **one** is a file in this repo (`+experiment/gammaCorrect.m`); the second is the inline `gammaCorrection` anonymous function at `runCamouflageExperiment_search.m:36`, and `lib.gammaCorrect` (`setUpExperiment_search.m:118`) resolves to nothing at all (B2.9). No rename was made — with one file there is nothing to disambiguate, and any name change belongs with the consolidation.
- [ ] 🔴 **S1.16.** Act on the Stage 1 commented-out-code triage (3.1.4) — delete superseded/scaffolding, convert alternative/unfinished, leave unknown.
- [ ] 🟠 **S2.2.** Route every path through `config.m` (currently zero callers) — resolves B2.1.
- [ ] 🟠 **S2.3.** Collapse the 5 experiment-variant families (`{setUpExperiment,sessionSettings,generate_camouflage_stimuli}×{base,_all,_diff_bg,_shape_exponent,_texture_exponent}`, 15 files, 75–81% duplicate lines).
- [ ] 🟠 **S2.7.** Make live `+general/` scripts into functions (~8 of 41 are live; not yet enumerated).
- [ ] 🟠 **S2.8.** Fix `edge_powers` producer/consumer path-layout split.
- [ ] 🟠 **S2.17.** Validate Psychtoolbox harness on hardware; two latent issues (`S.targetTypeStr` never set; `stimulusInterval`'s discarded onset return); EyeLink layer unreachable (`loadStimuliCamouflage.m:16` hardcodes `bFovea=1`). Needs user hardware sign-off.
- [ ] 🟠 **S2.19 (new).** Snake_case retrofit of `+experiment/` and its subpackages (tranches 0.1.5/0.1.6/0.1.7) to comply with the new mandate — open question (grandfather vs. retrofit); not yet assigned a tier consensus. Tranche 0.1.1 deliberately left `+experiment/`'s 43 camelCase **filenames** alone for exactly this reason (decision R2 in 3.1.3): filename casing there is inseparable from the ~574 camelCase in-file identifiers those tranches deliberately preserved, and converting one half now would create the very split this item exists to resolve. When S2.19 is settled, its filename half is a second, smaller step-2a pass using 3.1.1's rules.
- [ ] 🟡 **S3.5.** Add a real smoke test (seed→edge-power check, round-trip, minimal-arg call sweep, package-resolution sweep). Would have caught B2.1–B2.6, B2.9. Should run early despite its 🟡 tier — it's cheap insurance against every later tranche.
- [ ] 🟡 **S3.6.** Quarantine/delete the 29 `_`-prefixed dead files properly (currently only renamed in place); fix `+tests/gabor_similarity.m:42`'s broken call.
- [ ] 🟡 **S3.10.** Rename zone-3 frozen `save`/`load` names, only with a migration script (~100GB of real data at risk).
- [ ] 🟡 **S3.11.** Repoint `+lib/ptch_norm.m`/`watson_otf.m` to `vislab.lib.*`, delete local copies (resolves B3.3; signature differs, not drop-in).
- [ ] 🟡 **S3.15.** Reorder statements wherever flagged (per-instance safety review).
- [ ] 🟡 **S3.18.** Repo hygiene: gitignore `.claude/settings.local.json`, fix `.gitignore:2` `vislab_data/`→`vislab-common/`, clean stale MATLAB path entries (11 startup warnings).
- [ ] 🟡 **S1.1(alt).** Stop storing stimuli, store seeds (~100GB→~10MB) — design decision on caching strategy for the expensive Portilla-Simoncelli path.

*(Ids preserved verbatim from the pre-migration plan; a couple of tier/id mismatches inherited from the source — e.g. "S1.1" used for two different items above — are flagged for cleanup when this list is next touched, not silently fixed here.)*

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.4 · Stage 4 · Bugs</h3></summary>

<div style="margin-left:1.5em">

**Description.** Bugs found anywhere during Stage 1/2/3, fixed here after Structure. **Rating:** 🔴 severity 1, silently wrong results on a run path · 🟠 severity 2, reachable but not silent · 🟡 severity 3, latent. Id `B<severity>.<n>`, never renumbered. **User launches each fix manually — never auto-dispatched.**

**Status.** 38 of the 39 recorded bugs are unfixed; B3.9 closed as a side effect of tranche 0.1.1's filename/`function`-line rule. Highest open ids: B1.11, B2.25, B3.20.

**To-do.**

- [ ] 🔴 **B1.1.** Two incompatible edge-power definitions live (`lib.edge` vs `lib.edge_vector_ideal`/`edge_measures_ideal`), ratio ~3098×. `+lib/edge.m:92`, `+lib/edge_vector_ideal.m:91`, `+lib/steerable_grad.m:10,69`. Fixed by S1.4.
- [ ] 🔴 **B1.2.** Level order reversed in 3 of 5 `compute_edge_props_exp*` scripts (`_pca.m:18`, `_eq_sum.m:16`, `_rescaled.m:23` use `10:-1:1`; `_pca_all.m:15`, `_eq.m:16` use `1:10`) — mismatched labels in `classify_normals` fit.
- [ ] 🔴 **B1.3.** `lib.create_pink_noise_line.m:4-5` ignores its `exponent`/`alpha` argument entirely (guard always true) — shape-exponent manipulation is a no-op.
- [ ] 🔴 **B1.4.** `lib.stimulus.m:182-184` synthesizes target from *background's* texture stats, discarding target's own — wrong for `_diff_bg` family (which was run).
- [ ] 🔴 **B1.5.** `+general/compute_edge_group_measures.m:20` reads `lib.edge`'s outputs 3/4 which no longer mean contour groups (dead at `edge.m:114-134`) — silent regression, re-running overwrites good data.
- [ ] 🔴 **B1.6.** `+experiment/+main/responseInterval.m:25` timeout returns `-1`, assigned into a `false(...)`-preallocated array at `saveCurrentLevel.m:38` — corrupts SDT scoring.
- [ ] 🔴 **B1.7.** `computeThreshold_edgePower.m:88` (+3 sibling files) bootstrap `datasample(...,nTrials=30)` against up to 120 actual rows — inflates `threshold_sd`.
- [ ] 🔴 **B1.8.** `classify_normals` (`IntClassNorm/classify_normals.m:248,251-267`) silently discards `'eff'`/`'precision'` via `KeepUnmatched=true` — `fit_edge_model_with_exps.m:48`'s `'eff',0.34` does nothing; post-hoc rescaling also dead at `:204`.
- [ ] 🔴 **B1.9.** `fit_edge_model_with_exps.m:215-217` — `var_exp` compares model against itself (`mean_subj_acc` actually holds model accuracy, column-index bug). Related: `numel(~isnan(x))` at `:184` is a no-op (should be `nnz`).
- [ ] 🔴 **B1.10.** `compute_nat_img_eff_coding_bins.m:6,27,29,62` uses `ppd=106`, wavelength 555nm vs config's 60ppd/550nm — sampling-density mismatch on the live model chain's head.
- [ ] 🔴 **B1.11.** `compute_nat_img_eff_coding_bins.m:30,68-69,72,77,82` — patch locations drawn in cropped-image coords, used as full-image indices; border margin enforced at only 2 of 4 edges. Magnitude unverified.
- [ ] 🟠 **B2.1.** Live experiment-setup path can't find data (`vislab-common/data/edge_powers/` doesn't exist). `generate_camouflage_stimuli.m:2`, `setUpExperiment.m:32,47,72`. Fixed by S2.2.
- [ ] 🟠 **B2.2.** `lib.edge_props_stim.m:162` errors on camo stimuli (array-bounds); debug `randi(10)` at `:30` (advances RNG); `figure(1);imshow(stim)` at `:152-153`.
- [ ] 🟠 **B2.3.** `lib.edge_energy.m`/`lib.edge_shape.m` call `lib.steerable_grad` positionally against a name-value-only signature; `edge_energy.m:35` also uses removed `dsp.Normalizer`.
- [ ] 🟠 **B2.4.** `lib.stimulus` output arity: `generate_camouflage_stimuli_diff_bg.m:20,22` and `_texture_exponent.m:19,21` destructure shifted by one; `_shape_exponent.m:20` similarly shifted.
- [ ] 🟠 **B2.5.** `lib.stimulus.m:149-150` — `||` guard should be `&&`; errors with only one of `ml_b`/`cont_b` supplied.
- [ ] 🟠 **B2.6.** `_texture_exponent` chain renamed `nLevels`→`nBlocks`, `seeds`→`stimuliSeed` (`sessionSettings_texture_exponent.m:27`) but readers still expect old names.
- [ ] 🟠 **B2.7.** `SubjectExpFile.binIndex` read at `loadCurrentSession.m:35` but never created by `subjectExperimentFile.m:22-29`.
- [ ] 🟠 **B2.8.** `generate_camouflage_stimuli_all.m:33,40` — struct field mismatch (`textures` has 4 fields, `texture_list` on disk has 8).
- [ ] 🟠 **B2.9.** 15 package-qualified references resolve to nothing across 41 call sites (`tinker.filter`, `lib.circular_mask`, `lib.whiten_pink_noise_square`, `analysis.computeThresholdInBin`, `lib.edge_vector`, `lib.compute_dPrime_pCorrect`, `analysis.computeTemplateResponseSigma`, `analysis.compute_dPrime_pCorrect`, `experiment.analysis.computeThreshold_new_edge`, `experiment.show_image` (fix: `vis.show_image`), `lib.gammaCorrect`, `lib.new_edge`, `lib.pink_noise_2d`, `nm.analysis.fitPsychometric`, `stats.computeSceneSimilarityAmplitude`).
- [ ] 🟠 **B2.10.** `saveCurrentLevel.m:20-22` increments `levelCompleted` rather than setting it.
- [ ] 🟠 **B2.11.** Hardcoded absolute paths (`/Users/steve/...`, `C:\Users\sebastian\...`) in `computeBootstrappedThreshold.m:37,41` — carried forward, deliberately left stale.
- [ ] 🟠 **B2.12.** `lib.stimulus` with `target_radius=0` and >3 outputs errors (`:158,204`).
- [ ] 🟠 **B2.13.** `lib.stimulus.m:159,166,186` target branch tests background texture struct instead of target's own.
- [ ] 🟠 **B2.14.** `lib.compute_p_clipped.m:6` always says "boundary ribbon" regardless of input.
- [ ] 🟠 **B2.15.** `lib.crop_image`'s always-overridden `indColorChannels` reachable via 3 `+vis/` display callers.
- [ ] 🟠 **B2.16.** `runsingletrialTest.m:18,20` references undefined `w` (should be `window`).
- [ ] 🟠 **B2.17.** `plotThresholdvsCondition_mine.m` references undefined `dur`.
- [ ] 🟠 **B2.18.** `transform_camouflage_stimuli.m:13,25` reads `.nBlocks`/`.stimuliSeed` (only `_texture_exponent` chain emits these) but is called from the base chain.
- [ ] 🟠 **B2.19.** `compare_edge_energy_defs.m` calls nonexistent `analysis.compute_dPrime_pCorrect`.
- [ ] 🟠 **B2.20.** `video_demo.m` calls `lib.stimulus` positionally against name-value-only signature.
- [ ] 🟠 **B2.21.** `shuffle_unshuffle_exp.m`'s first-cell loop reassigns its own loop var — wrong printed progress count only.
- [ ] 🟠 **B2.22.** `vis.show_example_patches`'s `if bSave` branch references undefined `L`/`targetNr`.
- [ ] 🟠 **B2.23.** `vis.plot_psychometrics_vs_angle`/`_duration` both call nonexistent `analysis.computeThresholdInBin`.
- [ ] 🟠 **B2.24.** `tests.block_jumping`'s recompute loop calls `lib.stimulus` positionally.
- [ ] 🟠 **B2.25.** `tests.gabor_similarity` calls `stats.computeSceneSimilarityAmplitude`, unreachable due to `_`-prefix rename.
- [ ] 🟡 **B3.1.** `lib.edge_props_stim.m:21,129` hardcodes 256×256/radius-64 mask regardless of input size.
- [ ] 🟡 **B3.2.** `lib.crop_image.m:21` — `indColorChannel` missing trailing `s`, guard always true; `:33-35` swaps row/col for non-square patch.
- [ ] 🟡 **B3.3.** `lib.ptch_norm.m:15-16` undefined var `m`, `ntype==2` branch broken. Resolved by S3.11.
- [ ] 🟡 **B3.4.** `computeTemplateResponseSigma.m:44` — comparison inside `size()`; `:42` loop bound possibly wrong dimension.
- [ ] 🟡 **B3.5.** `lib.find_spot_centers.m:7` — `ismember(...,'row')` should be `'rows'`.
- [ ] 🟡 **B3.6.** `lib.hyperexp_nll.m` fits hypoexponential, not hyperexponential — name/code mismatch.
- [ ] 🟡 **B3.7.** `sessionSettings.m:40` — stray transpose in `strcmp(transformExpName','')`.
- [ ] 🟡 **B3.8.** `loadStimuliCamouflage.m:34` — `pixelsPerDeg = ExpSettings.monitor_distance` (field-name trap; correct today, migration needs S3.10).
- [x] 🟡 **B3.9.** `computeThreshold_edgeResponse.m:1` — function named `computeThreshold`, filename differs. **Resolved in tranche 0.1.1**: step 2a requires the `function` line to agree with the filename, so the declaration was renamed to `computeThreshold_edgeResponse`. Dispatch was always on the filename, so no call site moved.
- [ ] 🟡 **B3.10.** Undefined-variable blocks in `computeThreshold_edgeResponse.m:102-132` and `compute_nat_img_eff_coding_bins.m:123,283`.
- [ ] 🟡 **B3.11.** ~15 top-level `+general/` scripts depend on undefined workspace variables (part of S2.7).
- [ ] 🟡 **B3.12.** Bugs inside `_`-prefixed dead files (`+stats/_loadStatisticsSettings.m`, `_compute_edges.m`, `_compute_edge_strengths_multiscale.m`, `_fit_edge_model.m`, `_fit_edge_model_old.m`, `_computeThreshold_trials.m`, `_changepower.m` — the last silently overwrites data with no backup).
- [ ] 🟡 **B3.13.** `lib.edge_measures.m:6` hardcodes default boundary ribbon size, evaluated even when unused.
- [ ] 🟡 **B3.14.** `lib.target_mask.m:45-46` swaps row/col in non-circular branch, latent since `target_loc` always `'center'`.
- [ ] 🟡 **B3.15.** `lib.edge_props_stim` computes PCA rotation and discards it — promotes to severity-1 once B2.2 fixed.
- [ ] 🟡 **B3.16.** `stimulusInterval.m:41,52` returns offset time mislabeled as onset.
- [ ] 🟡 **B3.17.** `samplePatchesForExperiment.m:15,19` — duplicated `nargin<9` guard silently discards `simTypeStr`; no live callers.
- [ ] 🟡 **B3.18.** `generate_camouflage_stimuli_texture_exponent.m:14` writes `.alpha`, `lib.stimulus` reads `.exponent` — manipulation a no-op; promotes to severity-1 once B2.9/B2.4 fixed.
- [ ] 🟡 **B3.19.** `compute_nll_edge_model.m:18,35,52-53` — 3 of 4 outputs unreliable (loop-index bug, unassigned branch).
- [ ] 🟡 **B3.20.** `analyze_search_exps.m` writes `.hitRate`/`.dPrime` under the same field names for scalar vs. 19-vector quantities — unverified whether both cells ever run against the same struct.

**Recorded and disproved (not a bug):** unqualified `edge(...)` in `detect_edge_pixels.m:20`/`edge_measures.m:18` resolves correctly to Image Processing Toolbox `edge`, not `lib.edge`. Do not "fix."

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.5 · Stage 5 · Speed</h3></summary>

<div style="margin-left:1.5em">

**Description.** Optimization candidates found during survey or Stage 1–4, recorded, never made until here. **Rating:** 🔴 large win, low risk · 🟠 real cost (moderate gain, or perturbs float/RNG/`parfor` order) · 🟡 small/speculative/unverified — most items start here. Id `O<tier>.<n>`. Separate axis, **verification status**: Proven / Perturbing / Unprofiled — an Unprofiled item is **not implementable as recorded**, whatever its tier. **User launches each item manually — never auto-dispatched.**

**Status.** No timing data exists anywhere in the repo beyond raw `tic`/`toc` pairs in 21 files (no logged numbers, no README note on which stage is slow) — every item below starts Unprofiled.

**To-do.**

- [ ] 🟠 **O2.1.** `+general/compute_noise_colour.m:81` — `parfor` body has no output assignment at all; the parallelization is a complete no-op (worker-pool startup cost for nothing). Unprofiled — profile is "does removing `parfor` change wall-clock at all," expected trivially yes.
- [ ] 🟠 **O2.2.** `+tinker/pink_noise_seed_multiple_energies.m:21` — same shape: the loop's only output assignment is commented out (`:38-39`), currently computes nothing. Unprofiled.
- [ ] 🟡 **O3.1.** File I/O inside loops, ~25 files flagged by grep co-occurrence of `load`/`imread`/`save`/`dir`/`exist` with a `for`/`parfor` — not individually verified as loop-invariant vs. genuinely per-iteration. Heaviest: `+general/_fit_edge_model.m:47,55,57` (per-subject `dir`+`load` inside `for i_subj`), same shape in `_fit_edge_model_naive_scaling.m`, `fit_edge_model_with_exps.m:117,125,127`, `compute_avg_acc_for_texture.m:34,37`. Unprofiled — needs per-file reading to separate genuine per-item I/O (`+vis/show_example_patches.m`, `show_patch_grid.m`, `show_patches_one_by_one.m` load a *different* file per iteration, likely legitimate) from redundant reloads.
- [ ] 🟡 **O3.2.** Unpreallocated array growth by repeated concatenation (`var = [var; ...]`), ~40 instances across ~20 files, heaviest in `+experiment/+analysis/` threshold-computation family (`computeThreshold_edgePower.m:72-76`, `computeThreshold_edgeResponse.m:90-97`, `computeThreshold_texture_exponent.m:73-77`, `computeBootstrappedThreshold.m:70,72`) and `+general/` edge-power scripts (`_compute_edge_measures_ideal.m:9`, `_compute_edges.m:17,213`, `compute_edge_powers_camo.m:39`, `compute_noise_colour.m:99,154`). Several of these co-occur with the `parfor` loops in O3.3 below — worth profiling together. Unprofiled.
- [ ] 🟡 **O3.3.** 24 `parfor` loops repo-wide, spot-checked (not exhaustively) as writing to sliced/accumulator outputs, consistent with safe `parfor` use — none confirmed as a reduction-variable hazard beyond O2.1/O2.2 above. Full list in 2 (survey). Unprofiled — no per-loop timing exists to say which, if any, are worth parallelizing differently or at all.
- [ ] 🟡 **O3.4.** `+lib/gauss_llr.m:19` — `det(cov_b)/det(cov_a)`, a ratio of determinants rather than a solve, so `inv`/`\` substitution doesn't directly apply; flagged for a numerics look, not a confirmed win. Unprofiled.
- [ ] 🟡 **O3.5.** Storage vs. seed trade for stimulus caching (paired with S1.1 in Structure — this is the same finding wearing its Speed hat): regenerating from seeds instead of storing ~100GB needs a caching strategy for the expensive Portilla-Simoncelli path (~25 iterations/texture); pink noise regeneration is cheap. Unprofiled — no timing on PS synthesis cost exists yet.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.6 · Stage 6 · Closing</h3></summary>

<div style="margin-left:1.5em">

**Description.** A single fixed gate, run once 0.1 through 0.5 are all done. Never auto-dispatched — the orchestrator runs all four itself.

**To-do.**

- [ ] **0.6.1.** `check_stage1` re-run across every in-scope file against current HEAD.
- [ ] **0.6.2.** `golden_harness('replay', ...)` clean, end to end.
- [ ] **0.6.3.** Every item in 0.3, 0.4, and 0.5 ticked, or explicitly closed with a reason.
- [ ] **0.6.4.** Section 2 re-checked against the repo as it now stands.

</div>

</details>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">1. How an agent should execute this cleanup plan</h2></summary>

<div style="margin-left:1.5em">

`mtree` parses a `.m` file into MATLAB's own syntax tree; `tree2str` prints it back canonically (comments stripped, whitespace/bracket spacing normalised, missing `end` supplied):

```matlab
canon = @(f) tree2str(mtree(f,'-file'));
```

Blind to exactly what Stage 1 may change, sensitive to everything else. Verified: succeeds on all 164 in-scope files (see 2 for the scope definition — 29 `_`-prefixed dead files and the vendored `por_sim_tx_synth/` tree are excluded, same exclusion as the original survey).

Reverse-rename check: undo the rename map on the canonical form of the new file, assert equality with the canonical form of the old file:

```matlab
c_new = canon(new_file);
for k = 1:size(renames,1)   % renames = {new_name, old_name}
    c_new = regexprep(c_new, ['(?<![A-Za-z0-9_.])' renames{k,1} '(?![A-Za-z0-9_])'], renames{k,2});
end
isequal(canon(old_file), c_new)   % must be true
```

The lookahead matters: without it a short name (`patch`) can wrongly match inside a longer one (`patch_size`). The rename map must be a bijection with disjoint domain/range, asserted before use (`assert_rename_bijection.m`). `mtree`/`tree2str` are undocumented APIs — pin the MATLAB version (R2024b Update 6) in every commit that depends on the check.

**Stage 2's extra requirement: runtime golden output.** `tools/golden_harness.m` + `tools/golden_ref.mat` capture/replay 32 fields across 16 entry points, seeded explicitly via `rng(cfg.seed)`, never through the top-level driver: `lib.stimulus`, `lib.edge`, `lib.edge_vector_ideal`, `lib.edge_measures_ideal`, `lib.steerable_grad`, `lib.steerable_filter`, `lib.local_sd`, `lib.target_mask`, `lib.create_pink_noise_square`, `lib.whiten`, `lib.compute_p_clipped`, `lib.autocorr`, `lib.csf_fitted`, plus `experiment.analysis.psychometricFun`/`computeNegLogLikelihood`/`fitPsychometric`. Everything else (most of `+general/`, `+tinker/`, `+experiment/` — scripts, hardware-bound, or needing loaded `.mat` files) is pattern-check only, decided explicitly, not an oversight. `parfor` baseline: all 24 loops write to sliced outputs, none is a reduction — except two no-op cases now filed as O2.1/O2.2.

Semicolon insertion is Stage 2, not Stage 1: the canonical diff is exactly `X` → `X;` — trivially whitelisted, but not invisible.

Speed is its own stage because a Structure item is reviewed and reasoned about, while a Speed item isn't done until a stopwatch says it worked. It runs after Bugs and can be dropped entirely without touching anything else.

Stage 3 matters most: every tempting change belongs there (0.3's list), because each one changes output, call sites, or validation behaviour — keeping them out is what makes the behaviour-preserving pass's diff skimmable.

**All three of Structure, Bugs, and Speed rate on the same three-colour scale**, though what the tier means differs by list (see 0.3/0.4/0.5 descriptions). When the pass uncovers a structural opportunity, a bug, or an optimization, **record it with its tier/severity emoji and do not act on it** — the fix/change/optimization is a later stage's item, never done on the spot however easy it looks mid-tranche.

Statement reordering stays out of Stage 1/2 even though it looks cosmetic, because the check can't distinguish a safe reorder from an unsafe one.

**Before working section 0.3, check whether section 2 is still current** — re-measure if meaningful time has passed or the file set changed.

**Golden-reference maintenance, Stage 3 and Stage 4.** Run `golden_harness('replay', ...)` after every Stage 3/4 item. If output-preserving and replay passes, nothing to do. If replay fails: an expected-to-change item (a bug fix, a flagged behaviour change) gets a deliberate recapture with the delta logged; an item that was supposed to be output-preserving gets a **new bug** filed in 0.4, never a reflexive recapture.

**Stage 6 (Closing):** re-run the full check suite end to end rather than trusting the sum of per-item checks.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">2. Scope and measurements</h2></summary>

<div style="margin-left:1.5em">

Measured 2026-09-16 against current HEAD (MATLAB R2024b Update 6 for the Stage 1 tooling; the fresh survey below used `git`/grep-based static analysis, not headless MATLAB). Re-measure before trusting any of these after substantial changes.

**Scope, precisely.** Excluded: `por_sim_tx_synth/` (105 files — vendored `matlabPyrTools`/`textureSynth`, own `Contents.m`/license), and 29 `_`-prefixed known-dead files (7 in `+experiment/+analysis/`, 10 in `+general/`, 12 in `+stats/` — i.e. **all** of `+stats/`). This exclusion is carried forward unchanged from the original survey; a raw `git ls-files` count without it gives 204 files / ~16,340 lines, materially larger, because it counts the dead files as if in scope. With the exclusion applied: **164 files, 10,212 lines** (7,554 code, 2,659 comment) across `+experiment/` (49 files, 2,891 lines), `+general/` (31 files excl. dead, 2,474 lines), `+lib/` (56, 2,967), `+stats/` (0 in-scope, 12 excluded), `+tests/` (2, 107), `+tinker/` (13, 1,040), `+vis/` (8, 377), root (5, 356).

Concentration: 41 files under 25 lines, 81 more under 75; 8 files ≥150 lines hold 2,503 lines (25% of code): `+lib/edge_props_stim.m` (535), `+tinker/pink_noise.m` (366), `+general/compute_nat_img_eff_coding_bins.m` (355), `+general/fit_edge_model_with_exps.m` (309), `+tinker/whitening_tinker.m` (283), `+lib/stimulus.m` (252), `+general/plot_contour_props.m` (213), `+experiment/+main/runCamouflageExperiment_search.m` (190).

**What is actually wrong with the files:**

- **Lint.** `checkcode`: 222 messages, 90/164 files clean (measured at tooling time; not re-run for this update). Split: Stage 1/2 mechanical (~117: `NOPTS` 37, `AGROW` 30, `NOSEMI` 20, `SAGROW` 19, `LOAD` 9, `ISCL` 5, `LOGSUM` 3, `NANMEAN`/`NANSUM` 4), judgement-needed (~44: `NASGU` 24, `ASGLU` 12, `INUSD` 5, `USENS` 3, `STRNU` 1), bug signals (~40: `STOUT` 22, `PFBNS` 6, `GVMIS` 3, `NODEF` 2, singletons).
- **Formatting.** 19 files tab-indented (fresh re-scan: 13 confirmed still tab-indented, concentrated in `_`-prefixed excluded files plus `computeBootstrappedThreshold.m` and 3 `_computeNegLogLikelihood*`/`_fitPsychometric*` siblings — all pre-existing, none touched by a completed tranche). 718 lines with trailing whitespace (at tooling time). 45 files with a line >100 chars; worst `edge_props_stim.m` (13 over-length lines). Assignment spacing: 2,309 unspaced vs 1,102 spaced (pre-cleanup baseline); fresh spot-check on remaining untouched dirs (`+tinker/`, root, `+stats/`-excluded) shows the same unspaced-`=` pattern still dominant — 62 hits by a rougher single-pattern grep, concentrated in `test.m` (12), `+tinker/pink_noise.m` (4), `edge_power_demo.m` (3).
- **Header docs.** 116/164 begin with `function`; 39 originally had `Inputs`/`Output`, 18 had `See also`, 33 had none — all since improved by tranches 0.1.2–0.1.10's header rewrites (fresh count across the whole 204-file raw set, including excluded files: 90 have an Inputs/Output block, 156 have `See also` — the jump from 18→156 is almost entirely tranches 0.1.2–0.1.10's work). No `Contents.m` existed anywhere pre-cleanup; now 7 packages have one (`+experiment/`, `+experiment/+analysis/`, `+experiment/+main/`, `+general/`, `+lib/`, `+tests/`, `+vis/`). **Still missing: `+tinker/` and `+stats/`** (the latter excluded by design).
- **Names, inside files.** Most-used opaque identifiers pre-cleanup: `stim` 157, `x` 150, `d` 94, `seed` 82, `n` 73, `cont` 62, `ml` 59, `N` 56, `S` 52, `z` 51, `len` 51, `idx` 49, `y` 47, `r` 47, `c` 43, `a` 37, `mask` 35, `p` 34, `u` 33, `img` 33, `f` 29, `th` 24, `b` 24, `e` 23, `amp` 22, `ppd` 21 — the bulk of these have since been expanded per the rename map (3.1.1) in whichever tranche their file fell into; `+tinker/` and root (0.1.11/0.1.12, not started) still carry them unrenamed.
- **Names, of files.** Fresh census, all 204 raw filenames (i.e. including the 29 excluded): 107 snake_case, 54 camelCase (concentrated in `+experiment/+analysis` 11, `+experiment/+main` 10, `+experiment/` root 18, `+lib/` 10, plus `gaborSimilarity.m`, `spatialPattern.m`, `examplePatches.m`), 8 TitleCase, 29 leading-underscore (the excluded dead set), 6 other (`2D`/`1D`-suffixed: `gabor2D.m`, `haar2D.m`, `spot2D.m`, `pink_noise_1D.m`, `pink_noise_1D_dist.m`, `test_Erlang.m`). Families with a broken pattern: `compute_*`/`computeX` (24 files) splits hard on directory — `+general/` uniformly snake, `+experiment/+analysis/` uniformly camel; `compute_edge_props_exp*` sprawl (5 siblings — `_exp`, `_exp_eq`, `_exp_full`, `_exp_pca`, `_exp_raw` — no enumeration scheme distinguishing precedence); `plot_*`/`show_*`/`view*` (6 files) split three ways by directory with no rule for which verb a given visualization gets; `fit_*` (camel in `+experiment/+analysis/fitPsychometric.m`, snake elsewhere); `gammaCorrect` triplicated (already flagged in README.md:209, unconsolidated — tracked as S1.14). **Superseded by tranche 0.1.1 for the in-scope set:** the counts above are the pre-rename census; 38 files were renamed and every family break listed here was resolved or explicitly deferred (map and rules in 3.1.1). What remains is `+experiment/`'s 43 camelCase filenames, held for S2.19. Filename/`function`-line mismatches, re-checked repo-wide: one in scope (`computeThreshold_edgeResponse.m`, fixed, B3.9) and 21 in `_`-prefixed dead files, including `+general/_changepower.m` declaring `function e=newpower(...)` — all left for S3.6.
- **Casing census.** 107 snake / 54 camel / 8 TitleCase / 29 underscore-dead / 6 other, as above. camelCase assignment-target rough count: 574 across in-scope dirs — the split runs through variables too (`SubjectExpFile`, `ImgStats`, `bTarget`, `filePathOut`, all in `+experiment/`/`+stats/`). **Target is snake_case everywhere** per the new mandate; this is the size of what's still outstanding once 0.1.5–0.1.7's deliberate camelCase preservation is revisited (see S2.19).
- **Names diverge across call boundaries.** `compute_nat_img_eff_coding_bins.m:73` passes `patch_rgb`→`ptch`(`ptch_norm.m`)→caught as `ptchout`→`ptch_rgb` (3 names, 1 quantity, pre-cleanup — since partly addressed in 0.1.8's vocabulary); `setUpExperiment_search.m:67` passes `'bg_size', Stimulus.stimulus_sz` and `'ml_b', Stimulus.ml`.
- **Convention splits.** `+lib/`, `+general/`, `+tinker/` broadly snake_case; `+experiment/` (both subpackages) camelCase, Psychtoolbox heritage — **deliberately not converted** by 0.1.5/0.1.6/0.1.7, predates the snake_case mandate (see S2.19). `+vis/`/`+tests/` (0.1.10) turned out per-file mixed, harmonized only within each file.
- **Builtin shadows.** Pre-cleanup: `mask` 18×, `filter` 12×, `contrast` 8×, `edge` 7× (`lib/edge.m` shadows Image Processing Toolbox `edge` — deliberate, same name as the concept), `alpha` 4×, `type` 2×, `output` 2× — all fixed in zone-1 renames by whichever tranche touched them. Fresh scan of *remaining untouched* files (`+tinker/`, root): essentially clean except `type` as a loop variable in `+tinker/pink_noise_seed_multiple_energies.m:43` and a comment echo in `whitened_pn_stim_edge_energy.m:43`.
- **Commented-out code.** 780 of 2,659 comment lines were dead code pre-cleanup (~29% of comments); by directory `+general/` 297, `+lib/` 282, `+experiment/` 116, `+tinker/` 55, root 18, `+vis/` 12, `+tests/` 0. 37 contiguous ≥5-line blocks form the real worklist (triaged in 3.1.4); the rest are scattered 1–2-line fragments triaged in passing. `edge_props_stim.m` alone held 197 lines (19 separate blocks, since triaged in tranche 0.1.3). **`+tinker/` (0.1.11, not started) still carries its full 55 lines untriaged.**
- **Argument validation.** `arguments` blocks: 0, repo-wide, still true after a fresh check. `inputParser`: 11 files (was 9 at original survey — 2 more counted in the fresh full-repo scan, `+general/video_demo.m` and `+tests/block_jumping.m`, likely miscounted the first time rather than new). Deferred to Stage 3 (S1.12).
- **Performance shape (fresh scan, new for this update).** `inv`/`pinv`/`det`-where-`\`-would-do: 1 hit, `+lib/gauss_llr.m:19` (a determinant ratio, not a solve — flagged, not a confirmed target, O3.4). File I/O inside loops: ~25 files (O3.1). Unpreallocated growth-by-concatenation: ~40 instances, ~20 files (O3.2). `parfor`: 24 loops, all apparently sliced except two no-op cases (`compute_noise_colour.m:81`, `pink_noise_seed_multiple_energies.m:21` — O2.1, O2.2). Full locations in 0.5.
- **Is there any timing data at all?** 21 files have `tic`/`toc` pairs (all `+general/`, one `+experiment/+main/`, three `+tinker/`) but no logged runtime numbers and no README note on which stage is slow. Nobody knows where the wall-clock actually goes — stated plainly rather than inferred from loop nesting. This is why every Speed item above starts Unprofiled.

**The style target already exists.** `../vislab-common/+vislab/+lib/watson_otf.m` — summary line, fully-qualified signature, `Inputs`/`Output` with units, `See also`. Two in-scope files share a name with (uncleaned ancestors of) shared-library functions: `+lib/ptch_norm.m`, `+lib/watson_otf.m` — explicitly not cleaned in this pass, repointing is S3.11's job.

**Prior tooling** (`tools/`): `canon.m`, `check_stage1.m`, `assert_rename_bijection.m`, `golden_harness.m`, `golden_ref.mat` — all present and committed from tranche 0.1.0.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">3. Stage-by-stage details and work log</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.1 Renaming: the three zones, and the function/file map</h4></summary>

<div style="margin-left:1.5em">

**Casing.** `+lib/`, `+general/`, `+tinker/` are snake_case by established convention (tranches 0.1.2–0.1.4, 0.1.8–0.1.9). `+experiment/` (both subpackages) is camelCase by deliberate decision, not yet reconciled with the new mandate — see S2.19. `+vis/`/`+tests/` is genuinely mixed *inside* its files by original authorship, harmonized per-file by 0.1.10; its **filenames** are all snake_case since 0.1.1.

1. **File-local variables — free.** Cumulative vocabulary tables, one per completed tranche:
   - **0.1.2** (`+lib/` core): `theta`/`theta_grid`/`theta_field`/`theta_edge`/`theta_lags`; `filter_kernel`; `stim_grad`; `grad_normal`; `edge_amplitude_spectrum`/`edge_power_spectrum`/`edge_phase_spectrum`; `white_noise_bg`/`white_noise_target`; `stim_bg`; `source_image`; `boundary_`/`texture_` prefixes; `n_scales`/`n_orientations`/`neighborhood_size`/`n_synthesis_iter`; `disc_mask`/`disc_size`/`disc_center`/`disc_radius`.
   - **0.1.4** (`+lib/` remainder): `spatial_freq`/`pupil_diameter`/`wavelength`/`surround_shape_exponent`/`surround_strength`/`surround_size`/`center_size`/`params`/`atf`/`human_atf` (CSF family); `pink_noise`/`white_noise`/`pink_noise_filter`/`white_noise_fft`/`white_noise_filtered_fft`; `n_obs`/`mean_x`/`mean_y`/`mean_xy`/`mean_x2`/`mean_y2`/`corr_coeff` (+`_list`); `patch_coords_rc`; `x_grid`/`y_grid`/`envelope_radius`/`gabor_sd`/`amplitude`; `i_pixel`/`j_pixel`/`pixel_idx`/`next_pixel_idx`.
   - **0.1.6** (`+experiment/+analysis/`): `threshold_scale`, `slope`, `bias`, `d_prime`, `p_hit`/`p_correct_rejection`/`p_correct`, `n_blanks`/`n_targets`/`n_hits`/`n_correct_rejections`, `log_likelihood`/`neg_log_likelihood`, `exponent` (split `threshold` vs `edge_threshold` across sibling files — see B3.10), `edge_response`/`response_blank_means`/`response_blank_sds`/`response_target_means`/`response_target_sds`.
   - **0.1.7** (`+experiment/` top level): `luminance`/`contrast` (overriding the original prediction of `mean_lum`/`contrast_rms`, per decision A below); `mask_strip`; `shape_exponents`/`texture_exponents`; `filePathOut`; `patchIndex`; `n_scales`/`n_orientations`/`neighborhood_size`/`n_synthesis_iter`; `source_image`/`source_image_path`; `kernel_sigma`.
   - **0.1.8** (`+general/` live model chain): `d_prime`/`d_primes`/`d_primes_model`/`d_prime_subj`/`d_prime_contributions`; `noise_sd`; `edge_count_z`; pooled response moments (as 0.1.6); `d_prime_hit_false_alarm`/`false_alarm_rate`; `error_rates_model`/`error_rates_subj`/`error_rate_sd_subj`; `efficiency_scalar`/`squared_error`; `overall_boundary`; `norm_mean`/`norm_contrast`/`norm_type`; `patch_row_start`/`patch_col_start`; `patch_size`/`patch_padded_size`/`max_filter_size`/`source_image_size`/`n_elements`; `kernel_sigma_list`/`kernel_sigma_max`/`kernel_n_sigma`; `source_image_rgb`/`_grey`/`_otf`/`_path`; `filter_kernel`; `corr_raw`/`corr_pca`; `trial_grid`/`level_grid`/`session_grid`.
   - **0.1.9** (`+general/` remainder): `perf`→`accuracy`; `hitRate`/`faRate`/`dPrime`→`hit_rate`/`false_alarm_rate`/`d_prime`; `t`/`h`/`c`→`target_present`/`hits`/`correct_rejection`; `ep`→`edge_power`; `bd_strip`/`bd_pixels`→`mask_strip`/`boundary_edge_pixels`; `input_img`/`im0`→`source_image_path`/`source_image_grey`; `th`/`th_bin`→`theta`/`theta_bin`; `thislevel`→`this_level`.
   - **0.1.10** (`+vis/`+`+tests/`): per-file only, no shared cross-file vocabulary.
   - **0.1.11, 0.1.12** (`+tinker/`, root): not started — the abbreviation list in section 2 above (`stim`, `x`, `d`, `seed`, `n`, `cont`, `ml`, `N`, `S`, `z`, `len`, `idx`, `y`, `r`, `c`, `a`, `mask`, `p`, `u`, `img`, `f`, `th`, `b`, `e`, `amp`, `ppd`, plus `+tinker/`-specific `XX`/`YY`, `mnv`, `grad`, `haar`, `filt`, `wn`, `wnf`, `N_b`) is still live there.

2. **Cross-file vocabulary — repo-wide, or not at all.** Three kinds:
   - **Function and file names** — tranche 0.1.1, **done**; 38 renames, map and family rules below.
   - **Function arguments named consistently across the repo** — 37 distinct parameter names, 55 declaration sites (full call-site table: `target_radius` 34 sites, `texture` 24, `ml_b`/`cont_b` 23 each, `bg_size` 20, `kernel_size` 13, `seed` 8, plus 13 declared-but-never-passed names). **Deferred to Stage 3 (S1.9)** — high value, everywhere, but a half-done rename is worse than none.
   - **The config struct** — 33 `ExpSettings` fields + 8 `SubjectExpFile` fields, dot-qualified so `check_stage1` can't see them. **Deferred to Stage 3 (S3.10)**.

3. **Serialised variable names — frozen.** `ExpSettings`, `SubjectExpFile`, `Stimulus`, `edge_powers`, `edgePowerBlockEdges`, `edge_props`, `seed_energy`, `stim_energy`, `d`, `corr_cross`, `corr_blank_cross`, `corr_target_cross`, `LLR_blank`, `LLR_target`, plus `cdfs.mat`'s `ea,Na,eb,Nb,er,Nr,egm,Ngm,coeff`. Plus **all 33 `ExpSettings` fields and all 8 `SubjectExpFile` fields** — struct fields evade the rename regex, the trap `check_stage1` cannot catch.

**Function and file rename map** (step 2a — tranche 0.1.1, done). 38 file renames plus one `function`-line-only fix. The rules came first; the map is their application.

**Family rules (binding on every later rename in this repo, including S2.19's filename half).**

- **R1 · A filename is snake_case unless its package is camelCase.** `+lib/`, `+general/`, `+tinker/`, `+tests/`, `+vis/` and the root are snake_case, so every camelCase filename in them was converted. `+experiment/` and its two subpackages were **left exactly as found** — see R2.
- **R2 · `+experiment/` filename casing is S2.19's, not 0.1.1's.** 43 camelCase filenames live there. Their casing is inseparable from the ~574 camelCase in-file identifiers that tranches 0.1.5–0.1.7 deliberately preserved, and converting the filenames alone would produce `set_up_experiment.m` with a camelCase body — the exact split S2.19 exists to settle. 0.1.1 therefore changed names in `+experiment/` only where the *casing was not the problem*: `plotThresholdvsCondition_mine` → `plotThresholdVsCondition` (a meaningless `_mine` qualifier, plus `vs`→`Vs` inside the local convention) and the two run-on all-lowercase `testscripts/` names.
- **R3 · Two display verbs, split by what is drawn, not by directory.** `show_<noun>` renders **images** (pixels on screen); `plot_<noun>` renders a **graph** of data (axes with quantities). Everything else — `view*`, `present*`, and a bare noun with no verb at all — is retired. This is why `show_image` and `show_example_stimuli` were already right and kept, while `viewpatches`/`presentpatches`/`examplePatches` became `show_*` and `edge_strength_dists`/`psychometrics_vs_*` gained a `plot_` prefix.
- **R4 · A variant family's suffix names the axis it varies, and the same axis always spells the same way.** For `compute_edge_props_exp*` the two axes are the gradient-bin basis (`pca`, `eq`, `rescaled`) and, when it is not the default per-level `classify_normals` fit, the cross-scale combination (`_sum`). The canonical live-chain member is `_pca`; `_pca_all` is transparently "the same, over all 14 experiment paths." **Precedence is expressed by the canonical member having the shortest suffix, never by a filename swap** — a swap puts a name on both sides of the rename map, which `assert_rename_bijection` rejects and which can turn a real change into a false pass.
- **R5 · One token per concept across filenames.** "Experiment" is `exp`/`exps`, never `expt`/`expts` (`exp_paths`, `exp_files/`, `exp_settings.mat` already settle it). "Camouflage" is `camo`, never `cam`. "Pink noise" is spelled out, never `pn`. A 1-D/2-D suffix is `_1d`/`_2d`, except where the repo already has a better word — `+lib/create_pink_noise_line/_square/_cube` is that better word, so `+tinker/pink_noise_1D*` joined it as `pink_noise_line*` rather than becoming `pink_noise_1d*`.
- **R6 · No ad-hoc abbreviation where a sibling spells the word out**, and no `get` prefix on a function that just returns a value. Hence `diff_of_gaussians_filter` → `difference_of_gaussians_filter` (its sibling is `laplacian_of_gaussian_filter`), and `getTargetIndexFromString` → `target_index_from_string`.
- **R7 · The `function` line always agrees with the filename**, even where dispatch does not care. One in-scope violation existed and was fixed (B3.9).
- **R8 · `fit_*` needed no rename.** The camel/snake "split" the survey flagged is entirely R1: `fitPsychometric` is camel because `+experiment/+analysis/` is camel, and `fit_csf`/`fit_edge_model_with_exps`/`fit_hyperexp_dist` are snake because `+general/` is snake. The verb and the word order were already consistent. It resolves itself when S2.19 resolves.

| old file | new file | why |
|---|---|---|
| `+lib/compute_pClipped.m` | `+lib/compute_p_clipped.m` | R1 — camelCase tail in a snake package |
| `+lib/cosWindow2.m` | `+lib/cos_window_2d.m` | R1, R5 — the trailing `2` meant 2-D |
| `+lib/cosdRadial.m` | `+lib/cosd_radial.m` | R1 |
| `+lib/cropImage.m` | `+lib/crop_image.m` | R1 |
| `+lib/differenceOfGaussians2D.m` | `+lib/difference_of_gaussians_2d.m` | R1, R5 — patch generator, sibling of `gabor_2d`/`haar_2d`/`spot_2d` |
| `+lib/diff_of_gaussians_filter.m` | `+lib/difference_of_gaussians_filter.m` | R6 — `laplacian_of_gaussian_filter` spells its word out |
| `+lib/embedImageinCenter.m` | `+lib/embed_image_in_center.m` | R1 |
| `+lib/gabor2D.m` | `+lib/gabor_2d.m` | R1, R5 |
| `+lib/getTargetIndexFromString.m` | `+lib/target_index_from_string.m` | R1, R6 — drops the `get` prefix |
| `+lib/haar2D.m` | `+lib/haar_2d.m` | R1, R5 |
| `+lib/loadPatchAtIndex.m` | `+lib/load_patch_at_index.m` | R1 |
| `+lib/monitorDegreesToPixels.m` | `+lib/monitor_deg_to_pix.m` | R1 |
| `+lib/radialavg.m` | `+lib/radial_avg.m` | R1 — run-on words |
| `+lib/samplePatchCoordinates.m` | `+lib/sample_patch_coordinates.m` | R1 |
| `+lib/spot2D.m` | `+lib/spot_2d.m` | R1, R5 |
| `+general/RandBoundary.m` | `+general/rand_boundary.m` | R1 — the only TitleCase file in a snake package |
| `+general/analyze_search_expts.m` | `+general/analyze_search_exps.m` | R5 |
| `+general/analyze_shape_expts.m` | `+general/analyze_shape_exps.m` | R5 |
| `+general/analyze_shuffled_expt.m` | `+general/analyze_shuffled_exp.m` | R5 |
| `+general/shuffle_unshuffle_expt.m` | `+general/shuffle_unshuffle_exp.m` | R5 |
| `+general/cam_ability_vs_samples.m` | `+general/camo_ability_vs_samples.m` | R5 |
| `+general/compute_edge_props_exp.m` | `+general/compute_edge_props_exp_pca_all.m` | R4 — PCA bins, per-level fit, all 14 experiment paths |
| `+general/compute_edge_props_exp_full.m` | `+general/compute_edge_props_exp_eq_sum.m` | R4 — `full` named nothing; it is plain (eq) bins combined by a cross-scale sum |
| `+general/compute_edge_props_exp_raw.m` | `+general/compute_edge_props_exp_rescaled.m` | R4 — `raw` named nothing; it re-spaces the bins to equispaced per scale |
| `+vis/examplePatches.m` | `+vis/show_example_patches.m` | R1, R3 |
| `+vis/presentpatches.m` | `+vis/show_patch_grid.m` | R3 — and the name now says grid, not just "patches" |
| `+vis/viewpatches.m` | `+vis/show_patches_one_by_one.m` | R3 — and the name now carries the one thing distinguishing it from `show_patch_grid` |
| `+vis/edge_strength_dists.m` | `+vis/plot_edge_strength_dists.m` | R3 — verb-less name for something that only plots |
| `+vis/psychometrics_vs_angle.m` | `+vis/plot_psychometrics_vs_angle.m` | R3 |
| `+vis/psychometrics_vs_dur.m` | `+vis/plot_psychometrics_vs_duration.m` | R3, R6 |
| `+tests/gaborSimilarity.m` | `+tests/gabor_similarity.m` | R1 |
| `+tinker/spatialPattern.m` | `+tinker/spatial_pattern.m` | R1 |
| `+tinker/pink_noise_1D.m` | `+tinker/pink_noise_line.m` | R5 — joins `+lib/create_pink_noise_line/_square/_cube`; also avoids colliding with the live local `pink_noise_1d` in `+tinker/pink_noise.m` |
| `+tinker/pink_noise_1D_dist.m` | `+tinker/pink_noise_line_dist.m` | R5 — parallels `+tinker/pink_noise_dist.m` |
| `+tinker/whitened_pn_stim_edge_energy.m` | `+tinker/whitened_pink_noise_edge_energy.m` | R5, R6 — `pn` appears nowhere else; `stim` added nothing |
| `+experiment/+analysis/plotThresholdvsCondition_mine.m` | `+experiment/+analysis/plotThresholdVsCondition.m` | R2 — `_mine` distinguished it from nothing |
| `+experiment/+main/testscripts/gettestexperimentstruct.m` | `.../getTestExperimentStruct.m` | R2 — run-on all-lowercase, case-only rename |
| `+experiment/+main/testscripts/runsingletrialTest.m` | `.../runSingleTrialTest.m` | R2 — case-only rename |
| `test.m` | `scratch.m` | R6 — a root-level scratchpad of ad-hoc cells; `test` said nothing and sat unqualified on the path |
| `test_Erlang.m` | `test_erlang.m` | R1 — case-only rename |
| *(no file rename)* `+experiment/+analysis/computeThreshold_edgeResponse.m` | — | R7 — `function` line only, `computeThreshold` → `computeThreshold_edgeResponse`; resolves B3.9 |

**Deliberately not renamed, with the reason** (documented negatives, so a later pass does not re-open them):

- **All 43 camelCase filenames in `+experiment/`** — R2, deferred to S2.19.
- **`+experiment/gammaCorrect.m`** — the survey's "triplicated `gammaCorrect`" is one file, one inline anonymous function (`runCamouflageExperiment_search.m:36`), and one sibling-repo function. With a single file there is nothing to disambiguate by suffix, and renaming it is entangled with S1.14's choice of which implementation survives.
- **`+general/plot_shape_exponent_exps.m`** — it plots nothing (unfinished stub). Renaming it to `load_*` would make the name truthful about a state nobody wants to keep; finishing or deleting it is Stage 3.
- **`+lib/hyperexp_nll.m`, `+general/fit_hyperexp_dist.m`** — the name is wrong (they fit a *hypo*exponential, B3.6), but correcting it is the bug fix, not a rename; it goes with Stage 4.
- **`+lib/edge.m`, `+lib/autocorr.m`, `+lib/deg2rad.m`** — deliberate builtin/toolbox shadows, package-scoped and documented in-file.
- **`+lib/ptch_norm.m`, `+lib/watson_otf.m`** — excluded from this pass entirely; S3.11 repoints them.
- **`+tinker/new_psychometric.m`** — `new` is a version marker that says nothing, but the script's purpose is not recoverable well enough to name it better; left as found.
- **The 29 `_`-prefixed dead files and `por_sim_tx_synth/`** — out of scope, as in every tranche. Their *call sites* into renamed `+lib/` functions were updated anyway (5 files in `+stats/`), so S3.6 does not inherit a broken tree.

**The four sweeps the check cannot do for you** — all four run, results in 3.1.3's step-0.1.1 entry.

**Units.** State pixels vs. degrees, mm, nm, "integer divisor not degrees" in every header — done per-tranche as headers are rewritten; not separately tabulated here.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.2 Tranches, sequencing, and model assignment</h4></summary>

<div style="margin-left:1.5em">

| # | Tranche | Files / lines | Agent | Why |
|---|---|---|---|---|
| 0.1.0 | Tooling + rename map + golden harness | — | `matlab-cleanup-lead` | Everything else trusts this |
| 0.1.1 | Function and file renames, repo-wide | all files | `matlab-cleanup-lead` | Ran after 0.1.2–0.1.10 instead of before, so it also swept their headers, `See also` lines and `Contents.m`. Repo-wide, never parallel |
| 0.1.2 | `+lib/` edge & stimulus core | 14 / 948 | `matlab-cleanup-lead` | Set in-file naming conventions |
| 0.1.3 | `+lib/edge_props_stim.m` | 1 / 535 | `matlab-cleanup-lead` | Largest single file |
| 0.1.4 | `+lib/` remainder | 39 / 1484 | `matlab-cleanup-mechanical` (sonnet) | Mechanical once 0.1.2's vocabulary exists |
| 0.1.5 | `+experiment/+main/` | 11 / 714 | `matlab-cleanup-mechanical` (sonnet) | Own camelCase family, self-contained |
| 0.1.6 | `+experiment/+analysis/` | 12 / 787 | `matlab-cleanup-mechanical` (sonnet) | Mixed camel/snake, self-contained |
| 0.1.7 | `+experiment/` top level | 26 / 1390 | `matlab-cleanup-lead` | Variant-family judgment calls |
| 0.1.8 | `+general/` live model chain | 4 / 833 | `matlab-cleanup-lead` | `eval`/bare-`load` frozen names, highest risk |
| 0.1.9 | `+general/` remainder | 27 / 1641 | `matlab-cleanup-mechanical` (sonnet) | Mechanical once 0.1.8's vocabulary exists |
| 0.1.10 | `+vis/` + `+tests/` | 10 / 484 | `matlab-cleanup-mechanical` (sonnet) | Small, per-file convention |
| 0.1.11 | `+tinker/` | 13 / 1040 | `matlab-cleanup-mechanical` (sonnet) | Mechanical once repo vocabulary exists |
| 0.1.12 | Root files | 5 / 356 | `matlab-cleanup-lead` | User-facing driver, config, demo |

**Escalation rule:** if `check_stage1` fails and the cause isn't obvious from the diff — stop, hand the file to `matlab-cleanup-escalation`, don't loosen the check.

**"Done" checklist** — as in the skill's Step 3, plus: every identifier the repo owns is snake_case except external-API/frozen/class names (not yet satisfied by 0.1.2–0.1.10, see S2.19); each file's `function` line agrees with its filename (checked repo-wide in 0.1.1 — one in-scope violation found and fixed, the rest are `_`-prefixed dead files).

One commit per tranche, per the skill's Committing section.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.3 Findings log</h4></summary>

<div style="margin-left:1.5em">

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.0 — tooling</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. `canon` verified on 164/164 in-scope files. Golden harness covers 32 fields / 16 entry points; capture-then-replay matched. Four design decisions: (1) reduction is a 5-field vector, not a plain sum — a naive sum gave a false-safe collision (69.7224 across three different functions); (2) NaN-aware via a separate NaN count; (3) `compute_pClipped` exercised on synthetic clipped data, not just a real stimulus; (4) always explicitly seeds via `rng(cfg.seed)`. Runtime ~55s, mostly parallel-pool startup. `parfor` confirmed safe for all 16 loops known at the time (later found to be 24 once `+tinker/`/root were counted). **Baseline decision, binding on all later tranches:** `+general/compute_nat_img_eff_coding_bins.m` and `+general/fit_edge_model_with_exps.m` carried an uncommitted live+commented `colorbarpzn(...)`→`vislab.lib.colorbarpzn(...)` repoint at tooling-commit time — not this repo's work, deliberately not committed here (kept clean of an unrelated in-progress edit); HEAD is not a valid baseline for those two files specifically. `which_sweep.m` explicitly not adopted into `tools/` (deferred to S3.5(d)).

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.2 — `+lib/` edge & stimulus core (14 files, 948 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD. All 14 passed `check_stage1` first try (24/14/13/18/4/5/5/10/7/1/12/3/6/0 renames). Golden harness replayed clean (32/32). `checkcode` unchanged (8 messages, same ids/files). **Binding entry for 0.1.3–0.1.12** — established conventions 1–7 (see below) plus the vocabulary table (3.1.1). Line-length exceptions: 3, all commented-out lines in `edge_measures.m` (115/117/124 chars). Bugs found: B2.13, B2.14, B3.13, B3.14.

**Conventions 1–7 (binding on every later tranche):**
1. One old name → exactly one new name per file (bijection constraint).
2. Loop counters `i_<thing>` in snake_case dirs / camelCase equivalent in `+experiment/`.
3. A local mirroring a zone-2 parameter keeps the parameter's exact name.
4. Header shape: exemplar's `% FUNCTION_NAME  Summary.` + signature + `Inputs`/`Output` (units) + `See also`.
5. Function bodies 4-space indented, terminal `end` added.
6. Author attribution moved to bottom of header (only where it already existed).
7. Cross-boundary names harmonized toward the caller's word, not the callee's.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.3 — `+lib/edge_props_stim.m` (1 file, 535 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD. 54 renames, passed. `checkcode` unchanged (18 messages). New decision A: a local merely *holding* a parameter value isn't renamed onto that parameter's own string-literal name (`grad_m_bins`→`grad_magnitude_bins`, not `grad_mag_bins`). New decision B: an output only assigned by dead code keeps its original short name — 15/30 outputs left unrenamed, documented in header. Line-length exceptions: 13, all dead lines. Bug found: B3.15.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.4 — `+lib/` remainder (41 listed, 39 cleaned; 1484 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD for all 41. All 39 in-scope passed (0–15 renames each; `ptch_norm.m`/`watson_otf.m` excluded, S3.11). Golden harness replayed twice (post-rename, post-reflow), matched. Six new rule discoveries: a local reused across frozen zones must be checked per-file, not just per-name; whole-file camelCase-authored files convert internals only, keep filename; struct fields can be frozen beyond the enumerated list if set by an out-of-scope caller; the zone-1-vs-string-literal check extends to `switch`/`case`; `case(...)`/`if(...)` redundant-looking parens are real AST nodes, never strip them (cost a first failed check-run on 11 files); Python text-mode writes under Git Bash on Windows can silently convert LF→CRLF (`gabor2D.m`) — always verify line endings after a bulk/shell-tool edit. `+lib/Contents.m` written (56 files). Bug found: B2.15 (re-severitied from B3.2). Line-length exceptions: 5.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.5 — `+experiment/+main/` (11 files, 714 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD. All 11 passed (1,1,0,0,0,0,0,0,13,0,0 renames). This directory's snake_case abbreviations from 0.1.2–0.1.4 don't apply — confirmed pure camelCase family by reading; `runCamouflageExperiment_search.m`'s internal snake_case stragglers converted *to* camelCase (13 renames), the mirror-image of 0.1.4's whole-file rule. Terminal `end` added to 8 files. Void-function `Output: none (side effect: ...)` header convention introduced here. Line-length exceptions: 2. Commented-out code: T4.1 (`displayLevelStart.m:39-45`), T4.2 (`giveFeedback.m:20,23,26`) — both **alternative**. Bugs found: B2.16, B3.16. `+experiment/+main/Contents.m` written.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.6 — `+experiment/+analysis/` (12 files, 787 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD. Convention: snake_case-scratch-locals + camelCase-parameters/struct-mirrors/loop-counters, consistent across all 12 — kept as found. 3 files failed first pass (rename-chain collisions, all self-caught, no escalation): `iLevel` reused for two different loops in 2 files; a rename onto an existing plot-label string literal in the 3rd. Deliberate exception: `threshold` vs `edge_threshold` across sibling files, forced by B3.10's dead scaffolding (renaming would silently supply a value to an undefined-variable dead block). `mean_subj_acc` left deliberately untruthful — renaming would erase evidence of the B1.9 pattern. Line-length exceptions: 2. `+experiment/+analysis/Contents.m` written. Bug found: B2.17. Commented-out code: T5.1–T5.5, all alternative/unfinished.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.7 — `+experiment/` top level (26 files, 1390 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD. One file (`generate_camouflage_stimuli_all`) failed first pass — the rewritten header had dropped a dead parameter (`bTargetPresent`) from the signature, a real Stage-3-level edit; restored, documented as the tranche's main lesson. Convention: mixed camel/snake kept as found, only stragglers harmonized. **Decision A:** `ml`/`cont`→`luminance`/`contrast` (overriding the original `mean_lum`/`contrast_rms` prediction), blocked in 3 sibling files by string-literal collisions with struct-field names. **Decision B:** `global bdry_ribbon` keeps its name; local copies renamed to `mask_strip`. **Decision C:** the two meanings of `ExpSettings.alphas` (shape vs texture exponent) get two different local names while the frozen field stays `.alphas` in both. Two misspellings frozen and left uncorrected: `.moniter_brightness` field, `responseInvervalMs` local. Variant families cleaned as five separate files, not merged (S2.3's job later). Line-length exceptions: 4. `+experiment/Contents.m` written (top-level only). Commented-out code: T6.1–T6.9. Bugs found: B2.18, B3.17, B3.18.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.8 — `+general/` live model chain (4 files, 833 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: **pre-edit backup copies for all four** (two carry the uncommitted `colorbarpzn` repoint). All 4 passed first try (51/15/30/22 renames). Golden harness covers none of these 4. **Decision A** ("most dangerous thing in the tranche"): names reached via `eval()`/`evalin`/`assignin`/`feval`/`str2func`/`exist('...','var')` are invisible to `check_stage1` — grep for these before renaming anything in a new file. **Decision B:** bare `load(...)` with no output arg injects frozen names into the workspace, same as `save` literals. **Decision C:** bin-name/array-name mismatch kept deliberately (bins frozen via `save`, arrays expanded). **Decision D:** loop counters `i_<thing>`, but `nLevels`/`nTrials` kept camelCase (mirror `ExpSettings` fields). Two names deliberately not made truthful to avoid erasing bug evidence (`mean_subj_acc` re: B1.9). Line-length exceptions: 13. Commented-out code: T7.1–T7.18. Bugs found: **B1.11**, B3.19.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.9 — `+general/` remainder (27 files, 1641 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD for all 27. All 27 passed; 2 failed first pass, self-fixed without escalation. **Decision A:** a convention-1 collision inside one rename map is a bijection violation (two new names sharing one old name) — resolved by keeping one shared name (`i_location`) with an explanatory comment at the minority site. **Decision B:** line-ending convention checked per-file — this tranche's 27 files were 100% CRLF pre-edit; the editing tool silently wrote them all as LF, caught and reverted before final check. Vocabulary extended (analysis/accuracy terms, P-S knobs). Line-length exceptions: several, all dead. Commented-out code: T8.1–T8.10. Bugs found: **B2.19, B2.20, B2.21**, B3.20. `parfor` loops re-checked, all safe.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.10 — `+vis/` + `+tests/` (10 files, 484 lines)</h5></summary>

<div style="margin-left:1.5em">

Baseline: HEAD for all 10. Convention: per-file, not per-directory — 3 files pure camelCase (Walshe/Sebastian-authored), 3 pure snake_case, rest mixed-but-snake-majority (minority names converted up). No zone-2/zone-3 name touched. Line-length exceptions: none needed — all 8 over-100-char lines reflowed with `...` continuation. Line endings: LF for all 10, no CRLF issue. `Contents.m` written for both `+vis/` and `+tests/`. No `parfor` loops. Commented-out code: 5 blocks (2× `plot_edge_energy_hists.m`, `show_image.m`, 2× `viewpatches.m`) — scaffolding/alternative/alternative/scaffolding/superseded. Bugs found: **B2.22, B2.23, B2.24, B2.25**.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.1 — function and file renames, repo-wide (38 renames, 69 files touched)</h5></summary>

<div style="margin-left:1.5em">

**Baseline.** HEAD, for every `.m` file. At tranche start the only dirty files were `README.md`, `docs/repo-cleanup.md`, and the two excluded dead files `+general/_fit_edge_model.m` / `_fit_edge_model_naive_scaling.m` (the `colorbarpzn` repoint from the 0.1.0 entry) — no in-scope `.m` file carried uncommitted work, so HEAD was valid throughout. Those four pre-existing edits were committed separately (`chore: carry forward pre-existing uncommitted edits`) *before* this tranche's commit, so the rename diff stays reviewable.

**Verification — verbatim checker output**, MATLAB R2024b Update 6, run over **all 204 `.m` files in the repo** (in-scope plus the 29 `_`-prefixed dead files plus `tools/`), excluding only the vendored `por_sim_tx_synth/` tree:

```
bijection OK (143 rows)
FAIL +general/_fit_edge_model_naive_scaling.m

CHECK_STAGE1: 203 passed, 1 failed, 204 total
```

The single failure is explained and is not this tranche's: `_fit_edge_model_naive_scaling.m` is an excluded `_`-prefixed dead file that this tranche never edited (confirmed — it references no renamed name), and its baseline mismatch is the pre-existing `colorbarpzn(...)` → `vislab.lib.colorbarpzn(...)` repoint at `:161,166`, a live-code change invisible to no one but real to `canon`. Its sibling `_fit_edge_model.m` carries the same repoint but passes, because there the two changed lines are inside comments. No escalation needed.

A separate package-resolution sweep confirmed all 38 new names resolve: `RESOLUTION SWEEP: 38 of 38 new names resolve`.

**Decision R0 — the reverse-rename map carries the package-qualified forms as extra rows.** Essentially every call in this repo is package-qualified (`lib.crop_image(...)`), and `check_stage1`'s negative lookbehind at `check_stage1.m:30` refuses to reverse-rename a `.`-preceded name — so with a bare-identifier map this tranche would have failed on ~50 correct files and the mechanical check would have been worthless. **The regex was not loosened.** Instead the map was widened from 38 bare pairs to 143 rows by adding, for each rename, every qualified form that actually occurs in the tree (`lib.crop_image` ← `lib.cropImage`, `experiment.main.testscripts.getTestExperimentStruct` ← `...gettestexperimentstruct`, and the ALL-CAPS header forms). Each added row is *more* specific than the bare one, not less, so it cannot manufacture a pass the bare map would have refused; `assert_rename_bijection` still passes on all 143. The one caveat, recorded for honesty: `.` is a regex wildcard, so `lib.crop_image` would also match `libXcrop_image` — impossible in MATLAB source and not observed. This is the binding technique for S2.19's filename half.

**Decisions R1–R8** (the family rules) are written next to the map in 3.1.1, because that is where the next rename will be judged against them. The two that most constrain later work: **R2**, which keeps `+experiment/`'s 43 camelCase filenames out of this tranche and inside S2.19, and **R4**, which forbids expressing precedence by swapping two filenames because a swap violates the rename map's bijection requirement.

**The four sweeps.**

1. **Package-qualified call sites — verified by reading the diff**, as the skill requires, in addition to the R0 map rows. The whole `.m` diff (69 files, 209 changed lines) was read line by line; every changed line is exactly an old name replaced by its new name, and nothing else. Two things that only diff-reading caught, both now fixed: the blanket substitution had rewritten the *frozen golden-reference struct field* `golden.compute_pClipped` in `tools/golden_harness.m` (reverted — the field name is serialised into `tools/golden_ref.mat`, while the function call beside it was correctly repointed), and it had eaten a glob in `+lib/edge_props_stim.m:20`, turning `+general/compute_edge_props_exp*.m` into `..._pca_all*.m` (restored). A systematic check for further struct-field collateral found none: the only non-package dot-prefix anywhere in the substitution set was `golden.`.
2. **References outside `.m` files — 6 hits, all fixed.** `README.md:28` (`shuffle_unshuffle_expt.m`), `README.md:84` (`test.m, test_Erlang.m`), `CLEANUP.md:30,83` (`test.m`), and this plan document throughout (bug list, triage table, section 1's golden-harness entry-point list). `.gitignore` and `CITATION.cff`: no hits. No `.mlx`, shell, or batch files exist in the repo. No data filename is derived from a renamed function name — `data/old/video_demo.mat` pairs with `video_demo.m`, which was not renamed.
3. **Dynamic references — documented negative.** Grepping every old name *as a quoted string* across all `.m` files returned nothing. The `eval`/`exist` constructs in the `compute_edge_props_exp*` family build variable names (`grad_m_1` … `grad_p_16`) and test `exist('h','var')`; none names a renamed function. No `feval`, `str2func`, `which`, or `help` reference to a renamed name exists.
4. **Case-only renames — 3, all done through a temporary name**, since the filesystem is case-insensitive: `gettestexperimentstruct.m` → `getTestExperimentStruct.m`, `runsingletrialTest.m` → `runSingleTrialTest.m`, `test_Erlang.m` → `test_erlang.m`. All three are recorded by git as renames (`R`), not as delete-plus-create. A fourth would have been `pink_noise_1D.m` → `pink_noise_1d.m`; it was avoided by choosing `pink_noise_line.m` instead, which was independently the better name (R5) *and* sidestepped a collision with the live local variable `pink_noise_1d` in `+tinker/pink_noise.m` that would have made the reverse-rename fail on a correct edit.

**The out-of-order sweep this tranche had to absorb.** Step 2a should run before any tranche writes headers; here it ran tenth. So every `Contents.m`, header summary, signature line, `See also`, and cross-reference already written by 0.1.2–0.1.10 was swept for old names and updated — including the ALL-CAPS header convention (`% CROPIMAGE` → `% CROP_IMAGE`, `See also lib.GABOR2D` → `lib.GABOR_2D`). Three `Contents.m` files had their description columns re-aligned where a longer name broke them (`+general/`, `+tests/`, `+vis/`), and `+vis/Contents.m`'s "Patch viewers (camelCase, R. C. Walshe's convention…)" note was corrected, since those three files are no longer camelCase. Column re-alignment is comment-only whitespace, invisible to `canon`. **Noted, not fixed:** `+experiment/+analysis/Contents.m` never listed `plotThresholdvsCondition_mine` at all — a pre-existing omission, not a stale name, and adding an entry is a header edit outside this tranche's permitted set.

**Line-length exceptions: 3 in scope** (plus 2 in excluded dead files), all caused by a rename lengthening a line that was already near the limit, and all left because reflow is explicitly outside step 2a's permitted edits: `computeThreshold_edgeResponse.m:2` (107) and `:4` (113), `+lib/sample_patch_coordinates.m:1` (101). The excluded pair is `+stats/_addToStatStruct.m:28` and `_buildStatStructure.m:25` (106 each). Whoever next reflows those files should absorb them.

**Line endings** checked per file: every content edit was done through binary read/write, so each file kept the endings it had; `git diff` confirms 209 insertions against 208 deletions across 69 files, i.e. line-for-line, no whole-file rewrite. (The `core.autocrlf=true` warnings git prints are pre-existing and unrelated.)

**Commented-out code: none triaged here** — this tranche edits names only and reads no file for the first time, so no new block came into view. `+tinker/`'s 55 untriaged lines remain 0.1.11's.

**Bugs found: none new.** One existing bug closes as a side effect: **B3.9** (`function computeThreshold` inside `computeThreshold_edgeResponse.m`) is resolved by R7, which requires the `function` line to agree with the filename. Dispatch was always on the filename, so nothing moved at any call site; the in-file comment that recorded the mismatch was rewritten to record the fix. No optimization and no structural opportunity was acted on; S1.14 and S2.19 were both annotated with what this tranche learned about them.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Steps 0.1.11, 0.1.12 — `+tinker/`, root (not started)</h5></summary>

<div style="margin-left:1.5em">

Not started. `+tinker/` still carries its full abbreviation set (`XX`/`YY`, `mnv`, `grad`, `haar`, `filt`, `wn`, `wnf`, `N_b`) and 55 lines of untriaged commented-out code. Root's 5 files (`config.m`, `setup.m`, `edge_power_demo.m`, `scratch.m`, `test_erlang.m`) are the config file and user-facing driver — per the skill, these go late and get the strongest model.

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.4 Commented-out code — triage verdicts</h4></summary>

<div style="margin-left:1.5em">

37 contiguous ≥5-line blocks (out of 780 total dead-code lines pre-cleanup), one row per block, filled in as each tranche reached the file it's in. Acting on a verdict is Stage 3 (S1.16), never done here.

| block | file:lines | tranche | verdict |
|---|---|---|---|
| T1.1 | `+lib/edge.m:115-134` | 0.1.2 | **alternative** — contour-group computation; B1.5's live caller still expects it |
| T1.2 | `+lib/edge_measures.m:17` | 0.1.2 | **alternative** — Canny vs zero-crossing detector |
| T1.3 | `+lib/edge_measures.m:30,33` | 0.1.2 | **unfinished** — d' sketch, undefined vars |
| T1.4 | `+lib/edge_measures.m:35,39-51` | 0.1.2 | **unfinished** — per-contour loop, undefined vars |
| T1.5 | `+lib/target_mask.m:51-56` | 0.1.2 | **superseded** by `bwperim` at `:65` |
| T1.6 | `+lib/target_mask.m:58-61` | 0.1.2 | **superseded** by `bwperim` at `:65` |
| T1.7 | `+lib/target_mask.m:74,80` | 0.1.2 | **unknown** |
| T1.8 | `+lib/target_mask.m:84-85` | 0.1.2 | **superseded** by `:86-88` |
| T1.9 | `+lib/target_mask.m:90-92` | 0.1.2 | **superseded** by `:86-88` (also positionally broken, B2.3) |
| T1.10 | `+lib/target_mask.m:6,15` | 0.1.2 | **superseded** by seeding at `stimulus.m:82-83` |
| T1.11 | `+lib/steerable_filter.m:21-24` | 0.1.2 | **alternative** — L2-norm kernel normalization |
| T1.12 | `+lib/steerable_filter.m:26-30` | 0.1.2 | **scaffolding** — kernel visualization |
| T1.13 | `+lib/steerable_grad.m:47-50` | 0.1.2 | **superseded** by `:35-45` |
| T1.14 | `+lib/steerable_grad.m:64` | 0.1.2 | **alternative** — global-sd normalization, ties to B1.1/S1.4 |
| T1.15 | `+lib/edge_vector_ideal.m:51-54` | 0.1.2 | **superseded** by `:50,55-57` |
| T1.16 | `+lib/edge_vector_ideal.m:73` | 0.1.2 | **superseded** by `:79-80` |
| T1.17 | `+lib/edge_response.m:8-9` | 0.1.2 | **unfinished** / **alternative** (unweighted-mean pooling) |
| T1.18 | `+lib/edge_shape.m:44` | 0.1.2 | **superseded** by `:42,45` |
| T1.19 | `+lib/edge_energy.m:78` | 0.1.2 | **alternative** — unnormalized measure |
| T1.20 | `+lib/stimulus.m:78-79` | 0.1.2 | **superseded** by `:80` |
| T1.21 | `+lib/stimulus.m:124,181` | 0.1.2 | **superseded** — struct-clearing would break later fields |
| T1.22 | `+lib/compute_p_clipped.m:8` | 0.1.2 | **scaffolding** — print statement, ties to B2.14 |
| T2.1 | `+lib/edge_props_stim.m:52,158-159` | 0.1.3 | **unfinished** — two sketches of unused `grad_hist_thresh` |
| T2.2 | `+lib/edge_props_stim.m:70-72,75-94` | 0.1.3 | **alternative** (`:75-94`, tied to B2.2) / **unknown** (`:70-72`) |
| T2.3 | `+lib/edge_props_stim.m:112-118` | 0.1.3 | **alternative** — evidence for B3.15 |
| T2.4 | `+lib/edge_props_stim.m:134-139,165-166` | 0.1.3 | **alternative**, both |
| T2.5 | `+lib/edge_props_stim.m:275-300` | 0.1.3 | **alternative** — contour detection entry point |
| T2.6 | `+lib/edge_props_stim.m:303-399` | 0.1.3 | **alternative** / partly **unfinished** |
| T2.7 | `+lib/edge_props_stim.m:401-534` | 0.1.3 | **alternative** / **superseded** (older summary-struct fragments) |
| T3.1 | `+lib/csf_err.m:15-20` | 0.1.4 | **unfinished** — defensive log-clamp |
| T3.2 | `+lib/csf_spatial_filter.m` (last line) | 0.1.4 | **alternative** — cropped-window variant |
| T3.3 | `+lib/subplot_tight.m:49-50` | 0.1.4 | **superseded**, reason already inline |
| T3.4 | `+lib/autocorr.m:12` | 0.1.4 | **alternative** — normalized-correlation vs raw dot |
| T3.5 | `+lib/detect_edge_pixels.m:7` | 0.1.4 | **alternative** — DoG vs LoG filter |
| T3.6 | `+lib/embed_image_in_center.m:30` | 0.1.4 | **scaffolding** — stray warning |
| T4.1 | `+experiment/+main/displayLevelStart.m:39-45` | 0.1.5 | **alternative** — draw-order branch |
| T4.2 | `+experiment/+main/giveFeedback.m:20,23,26` | 0.1.5 | **alternative** — `sound()` vs `Beeper()` |
| T5.1 | `computeNegLogLikelihood.m:17-18,24-30,32-33,38,40` | 0.1.6 | **alternative** ×3 |
| T5.2 | `computeNegLogLikelihood_edgeResponse.m:50-54` | 0.1.6 | **alternative** — bias-aware model, same as T7.18 |
| T5.3 | `fitPsychometric.m:16-28` | 0.1.6 | **superseded** — old API computed `target_means` itself |
| T5.4 | `computeThreshold_edgePower.m:62-64,96-97` + `computeThreshold_texture_exponent.m:96-97` | 0.1.6 | **superseded** — mu-fixed-at-0 decision |
| T5.5 | `computeThreshold_edgeResponse.m:8,33,67-69` | 0.1.6 | **unfinished** ×2 |
| T6.1 | `setUpExperiment.m:21,52-64` | 0.1.7 | **alternative** — automatic bin-edge rule |
| T6.2 | `setUpExperiment.m:26,29` | 0.1.7 | **superseded** by exp_type-derived path |
| T6.3 | `setUpExperiment.m:71-77,81,84,90` | 0.1.7 | **alternative** / **superseded** (hardcoded subject list) |
| T6.4 | `saveCurrentLevel.m:24-33` | 0.1.7 | **alternative** — per-subject storage the author stopped keeping |
| T6.5 | `loadStimuliCamouflage.m:29-30,78-81,99` | 0.1.7 | **alternative** / **superseded** (edge-power reads) |
| T6.6 | `generate_camouflage_stimuli.m:6,36,41,51-54` | 0.1.7 | **superseded** ×3 / **unfinished** ×1 |
| T6.7 | `generate_camouflage_stimuli_shape_exponent.m:2-5,19,22` | 0.1.7 | **superseded**, all 4 |
| T6.8 | `setUpExperiment_shape_exponent.m:25,30-31` | 0.1.7 | **superseded**, ties to S2.3 |
| T6.9 | `setUpExperiment_search.m:12-16` | 0.1.7 | **alternative** — per-paradigm session count |
| T7.1 | `compute_nat_img_eff_coding_bins.m:5` | 0.1.8 | **alternative** — reproducibility seed, disabled |
| T7.2 | `compute_nat_img_eff_coding_bins.m:9,110` | 0.1.8 | **unfinished** — thresholding step never wired |
| T7.3 | `compute_nat_img_eff_coding_bins.m:26` | 0.1.8 | **alternative** — do-not-delete, ties to B3.10 |
| T7.4 | `compute_nat_img_eff_coding_bins.m:39-40` | 0.1.8 | **superseded** by `:41` |
| T7.5 | `compute_nat_img_eff_coding_bins.m:52,74` | 0.1.8 | **alternative** — RGB accumulation, ties to B3.10 |
| T7.6 | `compute_nat_img_eff_coding_bins.m:93-96,148` | 0.1.8 | **alternative** ×2 — custom-PCA-filter method fork |
| T7.7 | `compute_nat_img_eff_coding_bins.m:168-175` | 0.1.8 | **scaffolding** — diagnostic plot |
| T7.8 | `compute_nat_img_eff_coding_bins.m:270,273` | 0.1.8 | **superseded** by `:259-261` |
| T7.9 | `compute_nat_img_eff_coding_bins.m:293-294` | 0.1.8 | **unfinished**, well-documented (`egm`/`Ngm` cdf pair) |
| T7.10 | `compute_edge_props_exp_pca.m:2-3,5` + `fit_edge_model_with_exps.m:2-3,5-6` | 0.1.8 | **alternative** — full 14-exp path list |
| T7.11 | `compute_edge_props_exp_pca.m:29-41,54,59,62,68,93` + `fit_edge_model_with_exps.m:9-10,196` | 0.1.8 | **alternative** — retired contour-feature set; do not act before T2.5–T2.7/B2.2 settled |
| T7.12 | `compute_edge_props_exp_pca.m:107` | 0.1.8 | **scaffolding** — plot axis tweak |
| T7.13 | `fit_edge_model_with_exps.m:18` | 0.1.8 | **superseded** by `:58,103` |
| T7.14 | `fit_edge_model_with_exps.m:114-172` | 0.1.8 | **alternative** — 3 retired colour palettes |
| T7.15 | `fit_edge_model_with_exps.m:175-186` | 0.1.8 | **alternative** — live diagnostic display, carries the uncommitted `colorbarpzn` repoint |
| T7.16 | `fit_edge_model_with_exps.m:204,218,285` | 0.1.8 | **alternative** ×3 — do not delete `:204` until B1.8 fixed |
| T7.17 | `compute_nll_edge_model.m:13,16` | 0.1.8 | **alternative** ×2 |
| T7.18 | `compute_nll_edge_model.m:43-48` | 0.1.8 | **alternative** — same block as T5.2 |
| T8.1 | `rand_boundary.m:23-26,43` | 0.1.9 | **alternative** (deterministic ramp) / **scaffolding** (debug plot) |
| T8.2 | `analyze_shape_exps.m:15,18,25,28,35,38,45,48,55,58` | 0.1.9 | **alternative** (SD estimator) / **superseded** (bare plot lines) |
| T8.3 | `analyze_search_exps.m:107` | 0.1.9 | **alternative** — self-sufficient `centers` source |
| T8.4 | `compare_edge_energy_defs.m:6-7` | 0.1.9 | **alternative** — two other non-existent scoring functions |
| T8.5 | `compute_edge_group_measures.m:12,21,29` | 0.1.9 | **superseded** — by upstream removal in `lib.edge` (B1.5) |
| T8.6 | `compute_edge_powers_pink_noise.m:11-18,23-34` | 0.1.9 | **alternative**, both |
| T8.7 | shared fragment, `compute_edge_props_exp_{pca_all,eq,eq_sum,rescaled}.m` | 0.1.9 | **alternative**, all 4 copies, one verdict |
| T8.8 | `compute_noise_colour.m:13-14,78,103-123` | 0.1.9 | **alternative** (texture source) / **superseded** (duplicated block) |
| T8.9 | `compute_edge_props_exp_eq_sum.m:72-89` | 0.1.9 | **superseded** by live `sum(...)` — pending T7.11 |
| T8.10 | `compute_texture_autocorrelation.m:1-2,28` | 0.1.9 | **alternative** / **unknown** (`fftshift` line) |
| — | `plot_edge_energy_hists.m` ×2, `show_image.m`, `show_patches_one_by_one.m` ×2 | 0.1.10 | scaffolding/alternative/alternative/scaffolding/superseded |

`+tinker/`'s 55 dead-code lines (0.1.11, not started) are not yet triaged.

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.2 · Stage 2 · Tidying</h3></summary>

<div style="margin-left:1.5em">

Not started. Coverage gaps: most of `+general/`, `+tinker/`, `+experiment/` have no callable entry point for the golden harness (scripts, hardware-bound, or `.mat`-dependent) — decided as pattern-check-only, not an oversight.

**Per-tranche work log:** empty — nothing done yet.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.3 · Stage 3 · Structure</h3></summary>

<div style="margin-left:1.5em">

Not started. Commented-out code triaged in 3.1.4; nothing acted on yet.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.4 · Stage 4 · Bugs</h3></summary>

<div style="margin-left:1.5em">

Not started — all 39 bugs recorded in 0.4, none fixed.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.5 · Stage 5 · Speed</h3></summary>

<div style="margin-left:1.5em">

Not started — no timing data exists anywhere in the repo. Every item in 0.5 is Unprofiled.

| item | re-triage | before | after | output check | kept? |
|---|---|---|---|---|---|
| | | | | | |

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.6 · Stage 6 · Closing</h3></summary>

<div style="margin-left:1.5em">

Not started.

</div>

</details>

</details>
