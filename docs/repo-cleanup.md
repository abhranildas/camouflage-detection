# Repo-wide cleanup plan

✅ done · 🚧 in progress · ⬜ not started

---

<details open>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">0. Status</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">✅ 0.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

**Description.** Comments, header docs, whitespace, operator and bracket spacing, indentation, reflow, blank-line grouping, file-local renames, plus function and file renames repo-wide (step 2a), and triaging any commented-out code found in each tranche's files (verdict only, nothing deleted). Checked by `isequal` on a canonical AST fingerprint — no execution needed.

**Status.** Every in-scope file has been through a Stage 1 tranche, and `+experiment/`'s camelCase — which tranches 0.1.5–0.1.7 preserved because they predate the mandatory-snake_case rule — was retrofitted by S2.19, filenames and in-file identifiers together. `+stats/` (12 files) is entirely `_`-prefixed known-dead code, excluded from scope the same way it was in the original survey, so no tranche was ever assigned to it unless S3.6 revives it.

**To-do.**

- [x] **0.1.0.** Tooling: `canon`/`check_stage1`/`assert_rename_bijection`, golden-output harness — MATLAB R2024b Update 6.
- [x] **0.1.1.** Function and file renames, repo-wide — 38 renames (map in 3.1.1), verified over all 204 `.m` files.
- [x] **0.1.2.** `+lib/` edge & stimulus core — 14 files, 948 lines. **Sets in-file naming conventions for everything downstream.** *(predates snake_case mandate — see 3.1.3)*
- [x] **0.1.3.** `+lib/edge_props_stim.m` — 1 file, 535 lines.
- [x] **0.1.4.** `+lib/` remainder — 39 files cleaned of 41 listed, 1484 lines (`ptch_norm.m`/`watson_otf.m` excluded — S3.11's job).
- [x] **0.1.5.** `+experiment/+main/` — 11 files, 714 lines. *(camelCase family, preserved as found here; snake_cased later by S2.19)*
- [x] **0.1.6.** `+experiment/+analysis/` — 12 files, 787 lines. *(mixed camel/snake, preserved as found here; snake_cased later by S2.19)*
- [x] **0.1.7.** `+experiment/` top level, incl. variant families — 26 files, 1390 lines. *(mixed camel/snake, preserved as found here; snake_cased later by S2.19)*
- [x] **0.1.8.** `+general/` live model chain — 4 files, 833 lines (`compute_nat_img_eff_coding_bins.m`, `compute_edge_props_exp_pca.m`, `fit_edge_model_with_exps.m`, `compute_nll_edge_model.m`).
- [x] **0.1.9.** `+general/` remainder — 27 files, 1641 lines.
- [x] **0.1.10.** `+vis/` + `+tests/` — 10 files, 484 lines. *(per-file convention, genuinely mixed authorship)*
- [x] **0.1.11.** `+tinker/` — 13 files, 1040 lines.
- [x] **0.1.12.** Root files: `config.m`, `setup.m`, `edge_power_demo.m`, `scratch.m`, `test_erlang.m` — 5 files, 356 lines.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">✅ 0.2 · Stage 2 · Tidying</h3></summary>

<div style="margin-left:1.5em">

**Description.** Adding a suppressing `;`, preallocation, `find`→logical indexing, deleting a provably unused assignment. Checked by a whitelisted-pattern diff **plus** a runtime golden-output match. A closed list of four: anything bigger is a Speed item (0.5).

**Status.** All five tranches done. Every tranche has at least one golden-checked entry point except `+vis/`/`+tests/`/root, whose only golden-checked entry points live in `+tinker/`'s 5 functions — the rest of those four is pattern-check-only, the measured set of files with no callable, side-effect-free entry point at all (see 2 and the 0.2.0 log entry).

**To-do.**

- [x] **0.2.0.** Extend the golden harness to cover every tranche not yet in its 16-entry-point/32-field coverage — now 26 entry points / 57 fields.
- [x] **0.2.1.** `+lib/` (tranches 0.1.2–0.1.4) — golden-checked, 13 entry points.
- [x] **0.2.2.** `+experiment/+analysis/` (tranche 0.1.6) — golden-checked for 5 of its 12 files, pattern-only for the other 7 (all `.mat`-loading, plotting, or scripts).
- [x] **0.2.3.** `+experiment/` and `+experiment/+main/` (tranches 0.1.5, 0.1.7) — golden-checked for `gamma_correct` and `generate_target_present_matrix`, pattern-check only for the rest.
- [x] **0.2.4.** `+general/` (tranches 0.1.8, 0.1.9) — golden-checked for `compute_nll_edge_model`, its only function; the other 30 files are scripts, pattern-check only.
- [x] **0.2.5.** `+vis/`, `+tests/`, `+tinker/`, root — golden-checked for `+tinker/`'s 5 functions; the rest pattern-check only.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.3 · Stage 3 · Structure</h3></summary>

<div style="margin-left:1.5em">

**Description.** Signature changes, `arguments` blocks, merging duplicate functions, reordering statements, float/RNG-order changes, renaming a config struct field or a frozen `save`/`load` name, acting on the Stage 1 commented-out-code triage — not behaviour-preserving, done after Stage 1/2. **Rating:** 🔴 clear win, low risk · 🟠 real cost (design decision or wide call-site surface) · 🟡 marginal, defer. Id `S<tier>.<n>`, never renumbered.

**Status.** `tools/smoke_test.m` now runs green, so every open item has a cheap regression gate to check itself against.

**To-do.**

- [ ] 🔴 **S1.1.** Fix `edge_power_demo`/patch-location border margin (resolves B1.11 once judged non-latent).
- [ ] 🔴 **S1.4.** Pick one edge-power definition — `lib.edge` vs `lib.edge_vector_ideal`/`edge_measures_ideal` (resolves B1.1). Open decision on `normalize` default.
- [ ] 🔴 **S1.9.** Rename zone-2 cross-file name-value parameters repo-wide (full list in 3.1.1).
- [x] 🔴 **S1.12.** Add `arguments` blocks where they are behaviour-preserving. **Scope corrected on contact: 9 files use `inputParser`, not 11** — `+general/video_demo.m` and `+tests/block_jumping.m` only *mention* it in header prose a Stage 1 tranche wrote, so the original survey's 9 was right and the "fresh scan" that made it 11 was a grep artifact. Of the 9, **4 were converted** (`+lib/detect_edge_pixels.m`, `edge.m`, `edge_measures.m`, `edge_vector_ideal.m`). The other 5 cannot be converted without a design decision and are carried as **S2.21**.
- [ ] 🔴 **S1.13.** Remove dead scaffolding in the live path (global `bdry_ribbon`, duplicate write, debug `randi(10)`/`imshow`, 3 unconditional bar plots) — 7 named sites.
- [x] 🔴 **S1.14.** Consolidate the 3 gamma-compression implementations onto `vislab.lib.gamma_compress`. Tranche 0.1.1 established that only **one** is a file in this repo (`+experiment/gamma_correct.m`); the second is the inline `gammaCorrection` anonymous function at `run_camouflage_experiment_search.m:36`, and `lib.gammaCorrect` (`set_up_experiment_search.m:118`) resolves to nothing at all (B2.9). No rename was made — with one file there is nothing to disambiguate, and any name change belongs with the consolidation. **Done, but onto `experiment.gamma_correct`, not onto `vislab.lib.gamma_compress` — the item's named target was checked and rejected.** All three sites are now one implementation; the shared function turned out not to be a drop-in (fixed 0..255 white level, no quantisation, and zero live callers anywhere in the lab tree), so unifying with it is re-filed as S3.19. Closes B2.9's `lib.gammaCorrect` occurrence.
- [ ] 🔴 **S1.16.** Act on the Stage 1 commented-out-code triage (3.1.4) — delete superseded/scaffolding, convert alternative/unfinished, leave unknown.
- [x] 🟠 **S2.2.** Route every path through `config.m` — **done, and it resolved B2.1.** 33 files, 76 call sites: every `load`/`save`/`dir`/`imread`/`addpath` path literal in in-scope production code now reads `cfg = config()` and a `cfg.paths.*` field. `config.m` gained no new field; it lost one (`paths.images`, which had no callers and named a directory that has never existed) and **`paths.edge_powers` was repointed from `<data_root>/edge_powers` to `<repo>/data/edge_powers`, which is where the files actually are** — that one line is B2.1's whole fix. Two literals were deliberately left hardcoded, with reasons in 3.3.
- [x] 🟠 **S2.3.** Collapse the 5 experiment-variant families (`{set_up_experiment,session_settings,generate_camouflage_stimuli}×{base,_all,_diff_bg,_shape_exponent,_texture_exponent}`, 15 files, 75–81% duplicate lines). **Done for two of the three layers, and deliberately declined for the third.** `set_up_experiment` and `session_settings` are now one file each, taking the variant as their first argument (`'edge_power'`, `'all'`, `'diff_bg'`, `'shape_exponent'`, `'texture_exponent'`): 10 files and 958 lines became 2 files and 463. The five **generators** stay five files — past four lines of bookkeeping they share no computation, and collapsing them would have had to change `_shape_exponent`'s `parfor` axis, which changes the RNG draw order and so the stimuli. Reasoning and evidence in 3.3.
- [ ] 🟠 **S2.7.** Make live `+general/` scripts into functions (~8 of 41 are live; not yet enumerated).
- [ ] 🟠 **S2.8.** Fix `edge_powers` producer/consumer path-layout split.
- [ ] 🟠 **S2.17.** Validate Psychtoolbox harness on hardware; two latent issues (`S.targetTypeStr` never set; `stimulus_interval`'s discarded onset return); EyeLink layer unreachable (`load_stimuli_camouflage.m:16` hardcodes `bFovea=1`). Needs user hardware sign-off.
- [x] 🟠 **S2.19.** Snake_case retrofit of `+experiment/` and its subpackages (tranches 0.1.5/0.1.6/0.1.7). **The open grandfather-vs-retrofit question is settled: retrofit.** Both halves done together, as decision R2 required — 42 camelCase filenames converted in a second step-2a pass under 3.1.1's rules, and 534 in-file camelCase identifiers snake_cased across the 49 live files. What stays camelCase is only what is not ours to move: the zone-3 frozen `save`/`load` and struct-field names, the TitleCase settings-struct variables, and external Psychtoolbox/EyeLink API names.
- [ ] 🟠 **S2.20 (new).** Finish the snake_case retrofit outside `+experiment/`. S2.19 measured the leftover while closing its own scope: **49 camelCase assignment targets survive in `+vis/` (21), `+tests/` (5), `+general/` (14) and `+lib/` (9)** — tranches 0.1.2/0.1.4/0.1.9/0.1.10 also predate the mandate, and 0.1.10 explicitly kept three `+vis/` files "pure camelCase" as their authors wrote them. Same shape as S2.19 and the same method applies; the count is a tenth of S2.19's, but it needs the same frozen/external triage per file before anything is converted — at least one of the 49 (`edgePowerBlockEdges` in `+general/pick_edge_power_bins.m`) is a zone-3 frozen name that must not move. Filenames there are already all snake_case (0.1.1), so this is the in-file half only.
- [ ] 🟠 **S2.21 (new).** Decide what to do about the 5 remaining `inputParser` functions, which S1.12 could not convert: `+lib/target_mask.m`, `local_sd.m`, `steerable_grad.m` (the three *sinks* of live `varargin{:}` pass-through chains), and `+lib/stimulus.m`, `edge_props_stim.m` (the two *sources* of those chains). All nine `inputParser` users set `KeepUnmatched = true`, and for these five that setting is load-bearing: `stimulus.m:251` hands its entire raw `varargin` to `target_mask`, `steerable_grad.m:100` hands its own to `local_sd`, and `edge_props_stim.m:203,205` hands its own to `steerable_grad`, so each sink is routinely handed names it does not declare. MATLAB's `arguments` blocks have no `KeepUnmatched` equivalent and no trailing `varargin` is permitted after a name-value block, so converting any sink breaks the live, golden-checked stimulus path; converting a source removes the `varargin` the forward is built from, and rebuilding it with `namedargs2cell` would forward the source's *defaults* as well as the caller's values, which changes what the sink sees. The real item is therefore not "add `arguments` blocks" but "decide whether the flat one-bag-of-name-value-pairs pass-through design stays". It overlaps S1.9 (zone-2 name-value renames) and B2.4, and should be settled together with them. 🟠 because the benefit is real but the decision is the user's.
- [x] 🟡 **S3.5.** Add a real smoke test (seed→edge-power check, round-trip, minimal-arg call sweep, package-resolution sweep). Would have caught B2.1–B2.6, B2.9. Should run early despite its 🟡 tier — it's cheap insurance against every later tranche. **Done:** `tools/smoke_test.m`, 50 assertions, green on the current tree; found one new bug (B3.24).
- [ ] 🟡 **S3.6.** Quarantine/delete the 29 `_`-prefixed dead files properly (currently only renamed in place); fix `+tests/gabor_similarity.m:42`'s broken call.
- [ ] 🟡 **S3.10.** Rename zone-3 frozen `save`/`load` names, only with a migration script (~100GB of real data at risk).
- [ ] 🟡 **S3.11.** Repoint `+lib/ptch_norm.m`/`watson_otf.m` to `vislab.lib.*`, delete local copies (resolves B3.3; signature differs, not drop-in).
- [ ] 🟡 **S3.15.** Reorder statements wherever flagged (per-instance safety review).
- [ ] 🟡 **S3.18.** Repo hygiene: gitignore `.claude/settings.local.json`, fix `.gitignore:2` `vislab_data/`→`vislab-common/`, clean stale MATLAB path entries (11 startup warnings).
- [ ] 🟡 **S3.19 (new).** Unify `experiment.gamma_correct` with `vislab.lib.gamma_compress`, the remainder S1.14 declined to force. Both compute `out = white·(in/white)^(1/γ)`, but the shared one fixes `white = 255` and does not quantise, while every caller here needs an arbitrary output bit depth (`+vis/show_patch_grid.m` asks for 14) and a rounded integer pixel value. Routing the local one through it as written costs two compensating rescalings by 255 for a one-token power law — worse code, not better. The real fix is to give `vislab.lib.gamma_compress` an optional white-level argument (defaulting to 255, so backward-compatible) and then make the local function a genuine one-liner. 🟡 because the benefit is close to symbolic today: `vislab.lib.gamma_compress` has **zero live callers anywhere in the lab tree** (only `gamma_expand` is used, once, by `vislab.nat_stat_bayes.source_to_lms:69`), so nothing is actually diverging yet. It also needs a commit in a sibling repo and a signature decision the user should make, and it would put the experiment's live path behind a vislab-common dependency that `setup.m` only warns about when missing.
- [ ] 🟡 **S1.1(alt).** Stop storing stimuli, store seeds (~100GB→~10MB) — design decision on caching strategy for the expensive Portilla-Simoncelli path.

*(Ids preserved verbatim from the pre-migration plan; a couple of tier/id mismatches inherited from the source — e.g. "S1.1" used for two different items above — are flagged for cleanup when this list is next touched, not silently fixed here.)*

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">⬜ 0.4 · Stage 4 · Bugs</h3></summary>

<div style="margin-left:1.5em">

**Description.** Bugs found anywhere during Stage 1/2/3, fixed here after Structure. **Rating:** 🔴 severity 1, silently wrong results on a run path · 🟠 severity 2, reachable but not silent · 🟡 severity 3, latent. Id `B<severity>.<n>`, never renumbered. **User launches each fix manually — never auto-dispatched.**

**Status.** 63 of the 65 recorded bugs are unfixed; B3.9 closed as a side effect of tranche 0.1.1's filename/`function`-line rule, B2.1 as a side effect of S2.2, and one of B2.9's 15 dead references as a side effect of S1.14. Highest ids: B1.11, B2.29, B3.25.

**To-do.**

- [ ] 🔴 **B1.1.** Two incompatible edge-power definitions live (`lib.edge` vs `lib.edge_vector_ideal`/`edge_measures_ideal`), ratio ~3098×. `+lib/edge.m:92`, `+lib/edge_vector_ideal.m:91`, `+lib/steerable_grad.m:10,69`. Fixed by S1.4.
- [ ] 🔴 **B1.2.** Level order reversed in 3 of 5 `compute_edge_props_exp*` scripts (`_pca.m:18`, `_eq_sum.m:16`, `_rescaled.m:23` use `10:-1:1`; `_pca_all.m:15`, `_eq.m:16` use `1:10`) — mismatched labels in `classify_normals` fit.
- [ ] 🔴 **B1.3.** `lib.create_pink_noise_line.m:4-5` ignores its `exponent`/`alpha` argument entirely (guard always true) — shape-exponent manipulation is a no-op.
- [ ] 🔴 **B1.4.** `lib.stimulus.m:182-184` synthesizes target from *background's* texture stats, discarding target's own — wrong for `_diff_bg` family (which was run).
- [ ] 🔴 **B1.5.** `+general/compute_edge_group_measures.m:20` reads `lib.edge`'s outputs 3/4 which no longer mean contour groups (dead at `edge.m:114-134`) — silent regression, re-running overwrites good data.
- [ ] 🔴 **B1.6.** `+experiment/+main/response_interval.m:25` timeout returns `-1`, assigned into a `false(...)`-preallocated array at `save_current_level.m:38` — corrupts SDT scoring.
- [ ] 🔴 **B1.7.** `compute_threshold_edge_power.m:88` (+3 sibling files) bootstrap `datasample(...,nTrials=30)` against up to 120 actual rows — inflates `threshold_sd`.
- [ ] 🔴 **B1.8.** `classify_normals` (`IntClassNorm/classify_normals.m:248,251-267`) silently discards `'eff'`/`'precision'` via `KeepUnmatched=true` — `fit_edge_model_with_exps.m:48`'s `'eff',0.34` does nothing; post-hoc rescaling also dead at `:204`.
- [ ] 🔴 **B1.9.** `fit_edge_model_with_exps.m:215-217` — `var_exp` compares model against itself (`mean_subj_acc` actually holds model accuracy, column-index bug). Related: `numel(~isnan(x))` at `:184` is a no-op (should be `nnz`).
- [ ] 🔴 **B1.10.** `compute_nat_img_eff_coding_bins.m:6,27,29,62` uses `ppd=106`, wavelength 555nm vs config's 60ppd/550nm — sampling-density mismatch on the live model chain's head.
- [ ] 🔴 **B1.11.** `compute_nat_img_eff_coding_bins.m:30,68-69,72,77,82` — patch locations drawn in cropped-image coords, used as full-image indices; border margin enforced at only 2 of 4 edges. Magnitude unverified.
- [x] 🟠 **B2.1.** Live experiment-setup path can't find data (`vislab-common/data/edge_powers/` doesn't exist). **Fixed by S2.2, and genuinely resolved, not just routed.** The directory was never missing — it is `<repo>/data/edge_powers/`, holding `pink_noise.mat` and `natural/{bark,camo,camo_large,coral,foliage,grass,leaf,leather,moth,paper,rock,sand,scales,soil,spots}.mat`, each carrying both `edge_powers` and `edgePowerBlockEdges`, the two variables the loaders ask for. The literal named a sibling-repo path that has never held them. `cfg.paths.edge_powers` now points at the real directory and all three load sites read it from there; verified on disk (see 3.3).
- [ ] 🟠 **B2.2.** `lib.edge_props_stim.m:162` errors on camo stimuli (array-bounds); debug `randi(10)` at `:30` (advances RNG); `figure(1);imshow(stim)` at `:152-153`.
- [ ] 🟠 **B2.3.** `lib.edge_energy.m`/`lib.edge_shape.m` call `lib.steerable_grad` positionally against a name-value-only signature; `edge_energy.m:35` also uses removed `dsp.Normalizer`.
- [ ] 🟠 **B2.4.** `lib.stimulus` output arity: `generate_camouflage_stimuli_diff_bg.m:20,22` and `_texture_exponent.m:19,21` destructure shifted by one; `_shape_exponent.m:20` similarly shifted.
- [ ] 🟠 **B2.5.** `lib.stimulus.m:149-150` — `||` guard should be `&&`; errors with only one of `ml_b`/`cont_b` supplied.
- [ ] 🟠 **B2.6.** `_texture_exponent` chain renamed `nLevels`→`nBlocks`, `seeds`→`stimuliSeed` but readers still expect old names. Re-located by S2.3: now `session_settings.m`'s `'texture_exponent'` case (the `count_fields`/`result_fields` lists). The collapse deliberately did **not** fix it — it preserved the distinction exactly, and only made it easier to see, since the four variants that emit `.nLevels`/`.seeds` now sit beside the one that does not.
- [ ] 🟠 **B2.7.** `SubjectExpFile.binIndex` read at `load_current_session.m:35` but never created by `subject_experiment_file.m:22-29`.
- [ ] 🟠 **B2.8.** `generate_camouflage_stimuli_all.m:33,40` — struct field mismatch (`textures` has 4 fields, `texture_list` on disk has 8).
- [ ] 🟠 **B2.9.** 15 package-qualified references resolve to nothing across 41 call sites (`tinker.filter`, `lib.circular_mask`, `lib.whiten_pink_noise_square`, `analysis.computeThresholdInBin`, `lib.edge_vector`, `lib.compute_dPrime_pCorrect`, `analysis.compute_template_response_sigma`, `analysis.compute_dPrime_pCorrect`, `experiment.analysis.computeThreshold_new_edge`, `experiment.show_image` (fix: `vis.show_image`), `lib.gammaCorrect`, `lib.new_edge`, `lib.pink_noise_2d`, `nm.analysis.fitPsychometric`, `stats.computeSceneSimilarityAmplitude`). **One of the 15 is closed as a side effect of S1.14:** `lib.gammaCorrect` (`set_up_experiment_search.m:118`, its only call site) was repointed to `experiment.gamma_correct` and no longer appears anywhere in the source, so it is dropped from `tools/smoke_test.m`'s `known_dead` list and the sweep now counts 97 package-qualified references, not 98. The count above is left as first recorded; **14 references across 40 call sites remain**, so the item stays open.
- [ ] 🟠 **B2.10.** `save_current_level.m:20-22` increments `levelCompleted` rather than setting it.
- [ ] 🟠 **B2.11.** Hardcoded absolute paths (`/Users/steve/...`, `C:\Users\sebastian\...`) in `compute_bootstrapped_threshold.m:37,41` — carried forward, deliberately left stale.
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
- [ ] 🟠 **B2.26.** `+tinker/pink_noise.m:84,311` calls a bare `colored_noise(...)`, which resolves to no function anywhere in this repo (not package-qualified, so outside B2.9's sweep) — errors if either cell is run. Related, same cell: the `parfor` at `:311` reuses its own loop variable and a temporary (`autocorr_image`, `i_ensemble`) after the loop ends (`:337-338`), which `parfor` does not guarantee to hold a value for — moot until B2.26 itself is fixed, since the cell already errors before reaching it.
- [ ] 🟠 **B2.27.** `scratch.m:92` (cell 1) quivers `edge_vector(:, 1)` / `-edge_vector(:, 2)`, but `edge_vector` is never assigned anywhere in `scratch.m`. Cell 1 is otherwise self-contained, so running it from a clean workspace reaches this line and errors. Even with an `edge_vector` inherited from a manual `edge_power_demo` run it would still error: `lib.edge`'s edge vector is a 1-D profile, so `(:, 2)` is out of bounds. The boundary loop immediately above uses `boundary_contour_props(i).target_normal`, so the intended expression is almost certainly `texture_contour_props(i_contour).target_normal` — but that is a fix, not a Stage 1 edit, so the line is left as found.
- [ ] 🟠 **B2.28.** `+vis/show_patch_grid.m:37` calls `experiment.gamma_correct(cropped, 2, 14, 14)` with **four** arguments, but the function takes three — "Too many input arguments", so the function errors on its first patch. Found while tracing S1.14's call sites, and the history says exactly what happened: `gammaCorrect` was written in 2016 as `(imgIn, gammaValue, bitDepthIn, bitDepthOut)`, and commit `b38c8e7` ("Years of work", Nov 2021) dropped `bitDepthIn` so the input is now a normalised [0, 1] image. This call site was not updated and has been broken since. The intent is legible — gamma 2, 14 bits in, 14 bits out — so the fix is `experiment.gamma_correct(cropped/(2^14 - 1), 2, 14)`, but only if `lib.crop_image` really returns 14-bit pixel values here, which needs checking against a real `ImgStats` file. Left as found; S1.14 changed no signature, so this is not a regression it introduced.
- [ ] 🟠 **B2.29.** `+tinker/show_example_stimuli.m:27` calls `experiment.generate_camouflage_stimuli` with **8** positional arguments where the function takes 10. The two leading parameters, `texture` and `exp_type`, were added to the generator after this script was written, so every argument lands two positions early: `edge_energy_block_edges` arrives as `texture`, `n_trials` as `exp_type`, and the very first statement, `load(['vislab-common/data/edge_powers/', exp_type, '.mat'])`, errors on a numeric `exp_type`. The script is doubly stale — it also builds an 11-element `linspace` of *edges* where the generator wants an n_levels × 2 array of block limits, and its `experiment.show_image` at `:34` is one of B2.9's dead references. Found by S2.3's call-site sweep, which read every caller of all 15 variant-family files; the generator's signature is unchanged by that item, so this breakage is pre-existing, not introduced.
- [ ] 🟡 **B3.1.** `lib.edge_props_stim.m:21,129` hardcodes 256×256/radius-64 mask regardless of input size.
- [ ] 🟡 **B3.2.** `lib.crop_image.m:21` — `indColorChannel` missing trailing `s`, guard always true; `:33-35` swaps row/col for non-square patch.
- [ ] 🟡 **B3.3.** `lib.ptch_norm.m:15-16` undefined var `m`, `ntype==2` branch broken. Resolved by S3.11.
- [ ] 🟡 **B3.4.** `compute_template_response_sigma.m:44` — comparison inside `size()`; `:42` loop bound possibly wrong dimension.
- [ ] 🟡 **B3.5.** `lib.find_spot_centers.m:7` — `ismember(...,'row')` should be `'rows'`.
- [ ] 🟡 **B3.6.** `lib.hyperexp_nll.m` fits hypoexponential, not hyperexponential — name/code mismatch. Second site, found in tranche 0.1.12: root `test_erlang.m` plots the same hypoexponential density (two *different* rates), while an Erlang is the equal-rate case. The file was not renamed (0.1.1 fixes filenames, not misnomers that are really this bug); its header now states plainly what it actually plots.
- [ ] 🟡 **B3.7.** `session_settings.m:40` — stray transpose in `strcmp(transformExpName','')`.
- [ ] 🟡 **B3.8.** `load_stimuli_camouflage.m:34` — `pixelsPerDeg = ExpSettings.monitor_distance` (field-name trap; correct today, migration needs S3.10).
- [x] 🟡 **B3.9.** `compute_threshold_edge_response.m:1` — function named `computeThreshold`, filename differs. **Resolved in tranche 0.1.1**: step 2a requires the `function` line to agree with the filename, so the declaration was renamed to `compute_threshold_edge_response`. Dispatch was always on the filename, so no call site moved.
- [ ] 🟡 **B3.10.** Undefined-variable blocks in `compute_threshold_edge_response.m:102-132` and `compute_nat_img_eff_coding_bins.m:123,283`.
- [ ] 🟡 **B3.11.** ~15 top-level `+general/` scripts depend on undefined workspace variables (part of S2.7).
- [ ] 🟡 **B3.12.** Bugs inside `_`-prefixed dead files (`+stats/_loadStatisticsSettings.m`, `_compute_edges.m`, `_compute_edge_strengths_multiscale.m`, `_fit_edge_model.m`, `_fit_edge_model_old.m`, `_computeThreshold_trials.m`, `_changepower.m` — the last silently overwrites data with no backup).
- [ ] 🟡 **B3.13.** `lib.edge_measures.m:6` hardcodes default boundary ribbon size, evaluated even when unused.
- [ ] 🟡 **B3.14.** `lib.target_mask.m:45-46` swaps row/col in non-circular branch, latent since `target_loc` always `'center'`.
- [ ] 🟡 **B3.15.** `lib.edge_props_stim` computes PCA rotation and discards it — promotes to severity-1 once B2.2 fixed.
- [ ] 🟡 **B3.16.** `stimulus_interval.m:41,52` returns offset time mislabeled as onset.
- [ ] 🟡 **B3.17.** `sample_patches_for_experiment.m:15,19` — duplicated `nargin<9` guard silently discards `simTypeStr`; no live callers.
- [ ] 🟡 **B3.18.** `generate_camouflage_stimuli_texture_exponent.m:14` writes `.alpha`, `lib.stimulus` reads `.exponent` — manipulation a no-op; promotes to severity-1 once B2.9/B2.4 fixed.
- [ ] 🟡 **B3.19.** `compute_nll_edge_model.m:18,35,52-53` — 3 of 4 outputs unreliable (loop-index bug, unassigned branch).
- [ ] 🟡 **B3.20.** `analyze_search_exps.m` writes `.hitRate`/`.dPrime` under the same field names for scalar vs. 19-vector quantities — unverified whether both cells ever run against the same struct.
- [ ] 🟡 **B3.21.** `+tinker/pink_noise_stimuli_autocorrelations.m:66-92` (2nd and 3rd cells) reference `corr_blank_cross`, `corr_target_cross`, `terms`, and `corr_same` — none defined, loaded, or saved anywhere in this file; only runnable if a prior manual run happened to leave them in the workspace.
- [ ] 🟡 **B3.22.** `scratch.m:97` sets `texture.alpha = 2` where `lib.stimulus` reads `texture.exponent` (`stimulus.m:122-123,201`), so the brown-noise setting is silently ignored and the cell falls back to exponent 1 — a second site of B3.18's pattern. Latent rather than silent-wrong today for two reasons: cell 2 also calls `lib.edge_vector`, which resolves to nothing (B2.9), so it errors first; and if cell 1 was run beforehand, `texture` already carries `.exponent = 2` from `scratch.m:51` and the cell works by accident. Promotes with B3.18 and B2.9.
- [ ] 🟡 **B3.23.** `scratch.m` cells 4–8 read `ExpSettings`, `SubjectExpFile`, `stims_all`, `stims_miss` and `bdry_strip`, none of which this file creates, loads or saves — same shape as B3.21, and the reason those five names were deliberately left unrenamed in tranche 0.1.12. Within that, one concrete size bug: `scratch.m:141` preallocates `nan(256, 256, length(hit_idx))` but `:143` loops over `size(stims_miss, 3)`, two unrelated counts, so the classification image at `:147` averages trailing NaN pages (or the array grows) whenever they disagree.

- [ ] 🟡 **B3.24.** `lib.embed_image_in_center` errors on its own default path. `bAdditive` defaults to 0 (`:17-19`), and the `else` branch that default selects reads `target_window` at `:74`, which the defaults block at `:33-35` never assigns — its whole body is a commented-out warning. So any call with fewer than 7 arguments that does not opt into the additive branch dies with "Not enough input arguments", including the two-argument call the function's own header advertises. Latent rather than reachable: the one live caller, `+lib/difference_of_gaussians_2d.m:89`, passes `bAdditive = 1` and takes the other branch. Found by S3.5's minimal-argument call sweep, which now carries the call as an expected failure citing this id.
- [ ] 🟡 **B3.25.** `check_fixation_cross.m:24-28` — the dummy-mode branch (`SessionSettings.el.dummyconnected`) reads the mouse position and builds `evt`/`event_type` locals, but neither is read again on that path — the branch has no observable effect beyond consuming `GetMouse`'s return. Unclear whether this is an incomplete implementation (the polling/fixation-check loop below is written only for the real-EyeLink `else` branch) or a deliberate no-op for dummy mode. Latent: only reachable when `dummyconnected` is true, and doesn't error either way. Found while checking tranche 0.2.3's `checkcode`-flagged unused-assignment hits; left untouched rather than converted to `~` because the whole branch, not one local, looks like the real issue.

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
- [ ] 🟡 **O3.2.** Unpreallocated array growth by repeated concatenation (`var = [var; ...]`), ~40 instances across ~20 files, heaviest in `+experiment/+analysis/` threshold-computation family (`compute_threshold_edge_power.m:72-76`, `compute_threshold_edge_response.m:90-97`, `compute_threshold_texture_exponent.m:73-77`, `compute_bootstrapped_threshold.m:70,72`) and `+general/` edge-power scripts (`_compute_edge_measures_ideal.m:9`, `_compute_edges.m:17,213`, `compute_edge_powers_camo.m:39`, `compute_noise_colour.m:99,154`). Several of these co-occur with the `parfor` loops in O3.3 below — worth profiling together. Unprofiled.
- [ ] 🟡 **O3.3.** 24 `parfor` loops repo-wide, spot-checked (not exhaustively) as writing to sliced/accumulator outputs, consistent with safe `parfor` use — none confirmed as a reduction-variable hazard beyond O2.1/O2.2 above. Full list in 2 (survey). Unprofiled — no per-loop timing exists to say which, if any, are worth parallelizing differently or at all.
- [ ] 🟡 **O3.4.** `+lib/gauss_llr.m:19` — `det(cov_b)/det(cov_a)`, a ratio of determinants rather than a solve, so `inv`/`\` substitution doesn't directly apply; flagged for a numerics look, not a confirmed win. Unprofiled.
- [ ] 🟡 **O3.5.** Storage vs. seed trade for stimulus caching (paired with S1.1 in Structure — this is the same finding wearing its Speed hat): regenerating from seeds instead of storing ~100GB needs a caching strategy for the expensive Portilla-Simoncelli path (~25 iterations/texture); pink noise regeneration is cheap. Unprofiled — no timing on PS synthesis cost exists yet.
- [ ] 🟡 **O3.6.** Two `checkcode` AGROW hits in `+lib/` examined for tranche 0.2.1's Stage-2 preallocation pattern and declined as unsafe to fix mechanically: `find_spot_centers.m:25` (`centers(end+1, :)`) grows both within a loop and across the function's own recursive calls to itself, so the final size isn't known until the recursion actually runs; `trace_contours.m:66` (`contours{end+1, 1}`) grows once per contour found by a data-dependent `while` loop over a link map built from the input image, so the contour count isn't known until the trace completes. Neither has a size obtainable from an RNG-free pre-pass without duplicating the traversal itself, so Stage 2's "size it from a pre-pass, then fill by index" recipe doesn't apply without restructuring the algorithm — a Structure-sized change, not a Tidying one. Unprofiled.
- [ ] 🟡 **O3.7.** `+tinker/whitening_tinker.m:219` — `checkcode` flags `mismatch_template_image` as a broadcast variable inside a `parfor` (unnecessary per-worker communication overhead). Found during tranche 0.2.5's pattern check; not one of Stage 2's four whitelisted patterns, so recorded here rather than touched. Unprofiled — the enclosing cell also depends on `lib.mismatch_template`/`lib.whiten_pink_noise_square`, so this loop's own cost hasn't been isolated from the rest of the cell.

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

**Stage 2's extra requirement: runtime golden output.** `tools/golden_harness.m` + `tools/golden_ref.mat` capture/replay **57 fields across 26 entry points**, seeded explicitly via `rng(cfg.seed)`, never through the top-level driver:

- `+lib/` (13): `lib.stimulus`, `lib.edge`, `lib.edge_vector_ideal`, `lib.edge_measures_ideal`, `lib.steerable_grad`, `lib.steerable_filter`, `lib.local_sd`, `lib.target_mask`, `lib.create_pink_noise_square`, `lib.whiten`, `lib.compute_p_clipped`, `lib.autocorr`, `lib.csf_fitted`.
- `+experiment/+analysis/` (5): `psychometric_fun`, `compute_neg_log_likelihood`, `fit_psychometric`, `compute_neg_log_likelihood_edge_response`, `compute_template_response_sigma`.
- `+experiment/` (2): `gamma_correct`, `generate_target_present_matrix`.
- `+general/` (1): `compute_nll_edge_model` — the package's only `function` file.
- `+tinker/` (5): `pink_noise_dist`, `pink_noise_line`, `pink_noise_line_dist`, `pink_noise_square_manual`, `spatial_pattern` — the package's only `function` files.

Everything else is pattern-check only, decided explicitly per file (0.2.0's log entry), not an oversight. The measured reason, repo-wide: of the 31 in-scope `+general/` files exactly 1 has a `function` line and of the 13 `+tinker/` files exactly 5 do — the rest are top-level scripts with no callable entry point; the remaining `+experiment/+analysis/`, `+experiment/`, `+experiment/+main/`, `+vis/` and `+tests/` files either load session `.mat` files from `exp_files/`, open figures, are Psychtoolbox-bound, or error on their first statement against a recorded bug. `tools/smoke_test.m` is the does-it-run-at-all backstop for that set. `parfor` baseline: all 24 loops write to sliced outputs, none is a reduction — except two no-op cases now filed as O2.1/O2.2.

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

**Scope, precisely.** Excluded: `por_sim_tx_synth/` (105 files — vendored `matlabPyrTools`/`textureSynth`, own `Contents.m`/license), and 29 `_`-prefixed known-dead files (7 in `+experiment/+analysis/`, 10 in `+general/`, 12 in `+stats/` — i.e. **all** of `+stats/`). This exclusion is carried forward unchanged from the original survey; a raw `git ls-files` count without it gives 204 files / ~16,340 lines, materially larger, because it counts the dead files as if in scope. With the exclusion applied: **156 files, 9,717 lines** across `+experiment/` (41 files, 2,396 lines), `+general/` (31 files excl. dead, 2,474 lines), `+lib/` (56, 2,967), `+stats/` (0 in-scope, 12 excluded), `+tests/` (2, 107), `+tinker/` (13, 1,040), `+vis/` (8, 377), root (5, 356). *(Originally 164 files, 10,212 lines — 7,554 code, 2,659 comment. S2.3 collapsed 10 `+experiment/` files, 958 lines, into 2 files, 463 lines; the code/comment split has not been re-measured since.)*

Concentration: 41 files under 25 lines, 81 more under 75; 8 files ≥150 lines hold 2,503 lines (25% of code): `+lib/edge_props_stim.m` (535), `+tinker/pink_noise.m` (366), `+general/compute_nat_img_eff_coding_bins.m` (355), `+general/fit_edge_model_with_exps.m` (309), `+tinker/whitening_tinker.m` (283), `+lib/stimulus.m` (252), `+general/plot_contour_props.m` (213), `+experiment/+main/run_camouflage_experiment_search.m` (190).

**What is actually wrong with the files:**

- **Lint.** `checkcode`: 222 messages, 90/164 files clean (measured at tooling time; not re-run for this update). Split: Stage 1/2 mechanical (~117: `NOPTS` 37, `AGROW` 30, `NOSEMI` 20, `SAGROW` 19, `LOAD` 9, `ISCL` 5, `LOGSUM` 3, `NANMEAN`/`NANSUM` 4), judgement-needed (~44: `NASGU` 24, `ASGLU` 12, `INUSD` 5, `USENS` 3, `STRNU` 1), bug signals (~40: `STOUT` 22, `PFBNS` 6, `GVMIS` 3, `NODEF` 2, singletons).
- **Formatting.** 19 files tab-indented (fresh re-scan: 13 confirmed still tab-indented, concentrated in `_`-prefixed excluded files plus `compute_bootstrapped_threshold.m` and 3 `_computeNegLogLikelihood*`/`_fitPsychometric*` siblings — all pre-existing, none touched by a completed tranche). 718 lines with trailing whitespace (at tooling time). 45 files with a line >100 chars; worst `edge_props_stim.m` (13 over-length lines). Assignment spacing: 2,309 unspaced vs 1,102 spaced (pre-cleanup baseline); fresh spot-check on remaining untouched dirs (`+tinker/`, root, `+stats/`-excluded) shows the same unspaced-`=` pattern still dominant — 62 hits by a rougher single-pattern grep, concentrated in `test.m` (12), `+tinker/pink_noise.m` (4), `edge_power_demo.m` (3).
- **Header docs.** 116/164 begin with `function`; 39 originally had `Inputs`/`Output`, 18 had `See also`, 33 had none — all since improved by tranches 0.1.2–0.1.10's header rewrites (fresh count across the whole 204-file raw set, including excluded files: 90 have an Inputs/Output block, 156 have `See also` — the jump from 18→156 is almost entirely tranches 0.1.2–0.1.10's work). No `Contents.m` existed anywhere pre-cleanup; now 7 packages have one (`+experiment/`, `+experiment/+analysis/`, `+experiment/+main/`, `+general/`, `+lib/`, `+tests/`, `+vis/`). **Still missing: `+tinker/` and `+stats/`** (the latter excluded by design).
- **Names, inside files.** Most-used opaque identifiers pre-cleanup: `stim` 157, `x` 150, `d` 94, `seed` 82, `n` 73, `cont` 62, `ml` 59, `N` 56, `S` 52, `z` 51, `len` 51, `idx` 49, `y` 47, `r` 47, `c` 43, `a` 37, `mask` 35, `p` 34, `u` 33, `img` 33, `f` 29, `th` 24, `b` 24, `e` 23, `amp` 22, `ppd` 21 — the bulk of these have since been expanded per the rename map (3.1.1) in whichever tranche their file fell into; `+tinker/` was expanded in 0.1.11, root (0.1.12, not started) still carries them unrenamed.
- **Names, of files.** *(Census below is the original pre-rename one; see the two bracketed updates at its end for current state.)* All 204 raw filenames (i.e. including the 29 excluded): 107 snake_case, 54 camelCase (concentrated in `+experiment/+analysis` 11, `+experiment/+main` 10, `+experiment/` root 18, `+lib/` 10, plus `gaborSimilarity.m`, `spatialPattern.m`, `examplePatches.m`), 8 TitleCase, 29 leading-underscore (the excluded dead set), 6 other (`2D`/`1D`-suffixed: `gabor2D.m`, `haar2D.m`, `spot2D.m`, `pink_noise_1D.m`, `pink_noise_1D_dist.m`, `test_Erlang.m`). Families with a broken pattern: `compute_*`/`computeX` (24 files) splits hard on directory — `+general/` uniformly snake, `+experiment/+analysis/` uniformly camel; `compute_edge_props_exp*` sprawl (5 siblings — `_exp`, `_exp_eq`, `_exp_full`, `_exp_pca`, `_exp_raw` — no enumeration scheme distinguishing precedence); `plot_*`/`show_*`/`view*` (6 files) split three ways by directory with no rule for which verb a given visualization gets; `fit_*` (camel in `+experiment/+analysis/fit_psychometric.m`, snake elsewhere); `gamma_correct` triplicated (already flagged in README.md:209, unconsolidated — tracked as S1.14). **Superseded by tranche 0.1.1 for the in-scope set:** the counts above are the pre-rename census; 38 files were renamed and every family break listed here was resolved or explicitly deferred (map and rules in 3.1.1). **Superseded again by S2.19:** `+experiment/`'s remaining camelCase filenames — 42 as measured, not the 43 first recorded — were converted in a second step-2a pass, so **no in-scope `.m` file has a camelCase name any more**; the only camelCase filenames left in the repo are the 29 excluded `_`-prefixed dead ones. Filename/`function`-line mismatches, re-checked repo-wide: one in scope (`compute_threshold_edge_response.m`, fixed, B3.9) and 21 in `_`-prefixed dead files, including `+general/_changepower.m` declaring `function e=newpower(...)` — all left for S3.6.
- **Casing census.** Pre-cleanup: 107 snake / 54 camel / 8 TitleCase / 29 underscore-dead / 6 other filenames, and a camelCase assignment-target rough count of 574 across in-scope dirs. **Re-measured after S2.19:** filenames are 163 snake / 0 camel / 8 TitleCase (the `Contents.m` files) / 29 underscore-dead / 5 other; camelCase assignment targets are down to **69**, of which 16 are the five TitleCase settings/data structs S2.19 deliberately kept (`ExpSettings`, `SubjectExpFile`, `SessionSettings`, `SessionData`, `SettingsOut` — reasons in 3.3) and 49 are the leftover in `+vis/`/`+tests/`/`+general/`/`+lib/` now tracked as S2.20.
- **Names diverge across call boundaries.** `compute_nat_img_eff_coding_bins.m:73` passes `patch_rgb`→`ptch`(`ptch_norm.m`)→caught as `ptchout`→`ptch_rgb` (3 names, 1 quantity, pre-cleanup — since partly addressed in 0.1.8's vocabulary); `set_up_experiment_search.m:67` passes `'bg_size', Stimulus.stimulus_sz` and `'ml_b', Stimulus.ml`.
- **Convention splits.** As surveyed: `+lib/`, `+general/`, `+tinker/` broadly snake_case; `+experiment/` (both subpackages) camelCase, Psychtoolbox heritage, preserved as found by 0.1.5/0.1.6/0.1.7 because those tranches predate the snake_case mandate; `+vis/`/`+tests/` (0.1.10) per-file mixed, harmonized only within each file. **The `+experiment/` split is closed by S2.19**; the per-file `+vis/`/`+tests/` residue and the scattered camelCase in `+lib/`/`+general/` are what S2.20 still has to take.
- **Builtin shadows.** Pre-cleanup: `mask` 18×, `filter` 12×, `contrast` 8×, `edge` 7× (`lib/edge.m` shadows Image Processing Toolbox `edge` — deliberate, same name as the concept), `alpha` 4×, `type` 2×, `output` 2× — all fixed in zone-1 renames by whichever tranche touched them. Fresh scan of *remaining untouched* files (`+tinker/`, root): essentially clean except `type` as a loop variable in `+tinker/pink_noise_seed_multiple_energies.m:43` and a comment echo in `whitened_pn_stim_edge_energy.m:43`.
- **Commented-out code.** 780 of 2,659 comment lines were dead code pre-cleanup (~29% of comments); by directory `+general/` 297, `+lib/` 282, `+experiment/` 116, `+tinker/` 55, root 18, `+vis/` 12, `+tests/` 0. 37 contiguous ≥5-line blocks form the real worklist (triaged in 3.1.4); the rest are scattered 1–2-line fragments triaged in passing. `edge_props_stim.m` alone held 197 lines (19 separate blocks, since triaged in tranche 0.1.3). **`+tinker/` (0.1.11, not started) still carries its full 55 lines untriaged.**
- **Argument validation.** Originally 0 `arguments` blocks and 9 `inputParser` files, repo-wide. A later full-repo scan said 11; S1.12 re-measured on contact and the extra two (`+general/video_demo.m`, `+tests/block_jumping.m`) are header prose written by a Stage 1 tranche, not code — the survey's 9 was right. **Now: 6 `arguments` blocks** (`+lib/detect_edge_pixels.m`, `edge.m`, `edge_measures.m`, `edge_vector_ideal.m`, converted by S1.12; plus `+experiment/set_up_experiment.m` and `session_settings.m`, written with one by S2.3) and **5 `inputParser` files left**, all of them coupled by `KeepUnmatched`-dependent `varargin` forwarding and carried as S2.21.
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

**Casing.** snake_case everywhere, with no directory exceptions left. `+lib/`, `+general/`, `+tinker/` were already snake_case by established convention (tranches 0.1.2–0.1.4, 0.1.8–0.1.9); `+experiment/` (both subpackages) was camelCase by Psychtoolbox heritage until S2.19 retrofitted it, filenames and in-file identifiers together. Every filename in scope is snake_case; the camelCase that survives anywhere is either zone-3 frozen, an external API name, or the 49 in-file leftovers in `+vis/`/`+tests/`/`+general/`/`+lib/` that S2.20 still has to take.

1. **File-local variables — free.** Cumulative vocabulary tables, one per completed tranche:
   - **0.1.2** (`+lib/` core): `theta`/`theta_grid`/`theta_field`/`theta_edge`/`theta_lags`; `filter_kernel`; `stim_grad`; `grad_normal`; `edge_amplitude_spectrum`/`edge_power_spectrum`/`edge_phase_spectrum`; `white_noise_bg`/`white_noise_target`; `stim_bg`; `source_image`; `boundary_`/`texture_` prefixes; `n_scales`/`n_orientations`/`neighborhood_size`/`n_synthesis_iter`; `disc_mask`/`disc_size`/`disc_center`/`disc_radius`.
   - **0.1.4** (`+lib/` remainder): `spatial_freq`/`pupil_diameter`/`wavelength`/`surround_shape_exponent`/`surround_strength`/`surround_size`/`center_size`/`params`/`atf`/`human_atf` (CSF family); `pink_noise`/`white_noise`/`pink_noise_filter`/`white_noise_fft`/`white_noise_filtered_fft`; `n_obs`/`mean_x`/`mean_y`/`mean_xy`/`mean_x2`/`mean_y2`/`corr_coeff` (+`_list`); `patch_coords_rc`; `x_grid`/`y_grid`/`envelope_radius`/`gabor_sd`/`amplitude`; `i_pixel`/`j_pixel`/`pixel_idx`/`next_pixel_idx`.
   - **0.1.6** (`+experiment/+analysis/`): `threshold_scale`, `slope`, `bias`, `d_prime`, `p_hit`/`p_correct_rejection`/`p_correct`, `n_blanks`/`n_targets`/`n_hits`/`n_correct_rejections`, `log_likelihood`/`neg_log_likelihood`, `exponent` (split `threshold` vs `edge_threshold` across sibling files — see B3.10), `edge_response`/`response_blank_means`/`response_blank_sds`/`response_target_means`/`response_target_sds`.
   - **0.1.7** (`+experiment/` top level): `luminance`/`contrast` (overriding the original prediction of `mean_lum`/`contrast_rms`, per decision A below); `mask_strip`; `shape_exponents`/`texture_exponents`; `filePathOut`; `patchIndex`; `n_scales`/`n_orientations`/`neighborhood_size`/`n_synthesis_iter`; `source_image`/`source_image_path`; `kernel_sigma`.
   - **0.1.8** (`+general/` live model chain): `d_prime`/`d_primes`/`d_primes_model`/`d_prime_subj`/`d_prime_contributions`; `noise_sd`; `edge_count_z`; pooled response moments (as 0.1.6); `d_prime_hit_false_alarm`/`false_alarm_rate`; `error_rates_model`/`error_rates_subj`/`error_rate_sd_subj`; `efficiency_scalar`/`squared_error`; `overall_boundary`; `norm_mean`/`norm_contrast`/`norm_type`; `patch_row_start`/`patch_col_start`; `patch_size`/`patch_padded_size`/`max_filter_size`/`source_image_size`/`n_elements`; `kernel_sigma_list`/`kernel_sigma_max`/`kernel_n_sigma`; `source_image_rgb`/`_grey`/`_otf`/`_path`; `filter_kernel`; `corr_raw`/`corr_pca`; `trial_grid`/`level_grid`/`session_grid`.
   - **0.1.9** (`+general/` remainder): `perf`→`accuracy`; `hitRate`/`faRate`/`dPrime`→`hit_rate`/`false_alarm_rate`/`d_prime`; `t`/`h`/`c`→`target_present`/`hits`/`correct_rejection`; `ep`→`edge_power`; `bd_strip`/`bd_pixels`→`mask_strip`/`boundary_edge_pixels`; `input_img`/`im0`→`source_image_path`/`source_image_grey`; `th`/`th_bin`→`theta`/`theta_bin`; `thislevel`→`this_level`.
   - **0.1.10** (`+vis/`+`+tests/`): per-file only, no shared cross-file vocabulary.
   - **0.1.11** (`+tinker/`): abbreviations expanded per established vocabulary where a repo-wide precedent existed (`ml`/`cont`→`luminance`/`contrast` per 0.1.7 decision A; `x`/`y`→`x_grid`/`y_grid` for coordinate grids per 0.1.4; `d_prime`/`hit_rate`-style snake_case for `dPrime`-family locals per 0.1.9), plus new `+tinker/`-local vocabulary: `klist`/`kmin`/`kmax`/`log_kmin`/`log_kmax`/`d_logk`→`k_list`/`k_min`/`k_max`/`log_k_min`/`log_k_max`/`d_log_k`; `d_alph`/`alph`→`angle_step`/`angle`; `fil1f`/`fil_whiten`/`fil_pinken`/`fil_1f`→`pink_noise_filter`/`whitening_filter`/`pinkening_filter`/`freq_filter`; `wn`/`wnf`→`white_noise`/`white_noise_fft` (matches 0.1.4's `white_noise_fft`); `img_*`→`pink_noise_*`/`conv_test_*`/`noise_image` per context (never bare `img`); `z`→`value` (theoretical-distribution support) or `distance` (norm computation, same file, minority use commented); `r`/`r_num`/`r_cont`→`corr_coef`/`corr_coef_sum`/`corr_coef_continuous` (not `correlation*` — collides with a pre-existing string literal, see 3.1.3); loop counters `i_<thing>`, with `n`'s majority ensemble-index role kept at its minority pixel-index site via an explanatory comment (rand_boundary.m precedent). The abbreviation list's `XX`/`YY`/`mnv`/`grad`/`haar`/`filt`/`N_b` tokens were not found in the current 13 files — stale from an earlier version; `th`/`S`/`p`/`idx` likewise absent.
   - **S2.19** (`+experiment/`, retrofit): the casing conversion reused each tranche's own vocabulary rather than re-deciding it — 0.1.6's `threshold`/`threshold_sd` family absorbed `threshC`/`threshStdC`/`threshCDist` (and `thresholdsStd`→`thresholds_sd`, `pcBoot_sds`→`p_correct_boot_sds`), 0.1.2/0.1.6/0.1.8's `n_<thing>` absorbed `nLevels`/`nTrials`/`nSessions`/`numSamples`, 0.1.8's `i_<thing>` loop counters absorbed `iLevel`/`iTrial`/`iSession`/`iBoot`/`bootIndex`/`blockIndex`, and 0.1.4's `x_grid`/`y_grid` absorbed `X`/`Y`. New where nothing existed: `stim_edge_powers` (the per-stimulus edge power, kept distinct from the frozen `edge_powers` lookup table it is read from), `tone_high`/`tone_low`, `reaction_time` (was `RT`), `file_path_out` (was `fpOut`, matching its `filePathOut` siblings). Everything else is a plain casing change.
   - **0.1.12** (root): established vocabulary reapplied wherever it fit — `ml`/`cont`→`luminance`/`contrast` (0.1.7 decision A), `bd_strip`→`mask_strip` and `bd_pixels`→`boundary_edge_pixels` (0.1.9), `tx_*`→`texture_*` on the same pattern, `X`/`Y`→`x_grid`/`y_grid` (0.1.4), `i`→`i_<thing>` (convention 2). New root-local vocabulary: `bd_contour_props`/`tx_contour_props`→`boundary_contour_props`/`texture_contour_props` (+`mean_` forms); `bdry_contours`/`txtr_contours`→`boundary_contours`/`texture_contours`; `stim_grads_all`→`stim_grad_magnitudes`; `class_img`→`classification_image`; `idx`→`hit_idx`, `iTrial`/`iLevel`/`iSession`→`trial_idx`/`level_idx`/`session_idx`, `stims`→`hit_stimuli`; `th`→`threshold` and `n`→`exponent` (the callee's own output names); `edge`→`edge_profile` (builtin shadow). In `setup.m`: `commons`→`vislab_dir`, `fetch_commons`→`fetch_vislab_common`, `target`→`vislab_package`, `out`→`cmd_output`, `tb_dir`→`toolbox_root`, `d`→`toolboxes_dir`, `root`→`install_root`, `cand`→`candidate`, `w`→`which_path`, `probe`→`probe_name`, `i`→`i_folder`. `config.m` needed no rename at all (checked with an empty map). **Kept, with reasons:** `ppd` (it is the name of the `cfg.optics.ppd` field), `stim`, `contour` (mirrors the frozen `contour_props` struct field, 0.1.3 precedent, despite shadowing the `contour` builtin), `por_sim` (mirrors `cfg.paths.por_sim`), `folder` (the honest output name of a generic `locate_folder`), and every name-value mirror (`mask`, `mask_edge`, `mask_normal`, `kernel_size`, `target_radius`, `seed`, `texture`) per convention 3.

2. **Cross-file vocabulary — repo-wide, or not at all.** Three kinds:
   - **Function and file names** — tranche 0.1.1, **done**; 38 renames, map and family rules below.
   - **Function arguments named consistently across the repo** — 37 distinct parameter names, 55 declaration sites (full call-site table: `target_radius` 34 sites, `texture` 24, `ml_b`/`cont_b` 23 each, `bg_size` 20, `kernel_size` 13, `seed` 8, plus 13 declared-but-never-passed names). **Deferred to Stage 3 (S1.9)** — high value, everywhere, but a half-done rename is worse than none.
   - **The config struct** — 33 `ExpSettings` fields + 8 `SubjectExpFile` fields, dot-qualified so `check_stage1` can't see them. **Deferred to Stage 3 (S3.10)**.

3. **Serialised variable names — frozen.** `ExpSettings`, `SubjectExpFile`, `Stimulus`, `edge_powers`, `edgePowerBlockEdges`, `edge_props`, `seed_energy`, `stim_energy`, `d`, `corr_cross`, `corr_blank_cross`, `corr_target_cross`, `LLR_blank`, `LLR_target`, plus `cdfs.mat`'s `ea,Na,eb,Nb,er,Nr,egm,Ngm,coeff`. Plus **all 33 `ExpSettings` fields and all 8 `SubjectExpFile` fields** — struct fields evade the rename regex, the trap `check_stage1` cannot catch.

**Function and file rename map** (step 2a — tranche 0.1.1, done). 38 file renames plus one `function`-line-only fix. The rules came first; the map is their application.

**Family rules (binding on every rename in this repo; written for 0.1.1, applied again by S2.19).**

- **R1 · Every filename this repo owns is snake_case.** As written for tranche 0.1.1 this rule read "snake_case unless its package is camelCase", which exempted `+experiment/` (see R2). S2.19 removed the exemption: the rule is now unconditional, and no in-scope `.m` file has a camelCase name.
- **R2 · `+experiment/` filename casing was S2.19's, not 0.1.1's — and S2.19 has now done it.** Its casing was inseparable from the in-file camelCase that tranches 0.1.5–0.1.7 preserved, so converting the filenames alone would have produced `set_up_experiment.m` with a camelCase body. 0.1.1 therefore changed names in `+experiment/` only where the *casing was not the problem* (`plotThresholdvsCondition_mine` → `plotThresholdVsCondition`, and the two run-on all-lowercase `testscripts/` names), and S2.19 later converted all 42 of them, those three included, in one pass together with the in-file half. **Its map is the second table below; the first table is 0.1.1's, left as the record of what that tranche did rather than of current filenames.**
- **R3 · Two display verbs, split by what is drawn, not by directory.** `show_<noun>` renders **images** (pixels on screen); `plot_<noun>` renders a **graph** of data (axes with quantities). Everything else — `view*`, `present*`, and a bare noun with no verb at all — is retired. This is why `show_image` and `show_example_stimuli` were already right and kept, while `viewpatches`/`presentpatches`/`examplePatches` became `show_*` and `edge_strength_dists`/`psychometrics_vs_*` gained a `plot_` prefix.
- **R4 · A variant family's suffix names the axis it varies, and the same axis always spells the same way.** For `compute_edge_props_exp*` the two axes are the gradient-bin basis (`pca`, `eq`, `rescaled`) and, when it is not the default per-level `classify_normals` fit, the cross-scale combination (`_sum`). The canonical live-chain member is `_pca`; `_pca_all` is transparently "the same, over all 14 experiment paths." **Precedence is expressed by the canonical member having the shortest suffix, never by a filename swap** — a swap puts a name on both sides of the rename map, which `assert_rename_bijection` rejects and which can turn a real change into a false pass.
- **R5 · One token per concept across filenames.** "Experiment" is `exp`/`exps`, never `expt`/`expts` (`exp_paths`, `exp_files/`, `exp_settings.mat` already settle it). "Camouflage" is `camo`, never `cam`. "Pink noise" is spelled out, never `pn`. A 1-D/2-D suffix is `_1d`/`_2d`, except where the repo already has a better word — `+lib/create_pink_noise_line/_square/_cube` is that better word, so `+tinker/pink_noise_1D*` joined it as `pink_noise_line*` rather than becoming `pink_noise_1d*`.
- **R6 · No ad-hoc abbreviation where a sibling spells the word out**, and no `get` prefix on a function that just returns a value. Hence `diff_of_gaussians_filter` → `difference_of_gaussians_filter` (its sibling is `laplacian_of_gaussian_filter`), and `getTargetIndexFromString` → `target_index_from_string`.
- **R7 · The `function` line always agrees with the filename**, even where dispatch does not care. One in-scope violation existed and was fixed (B3.9).
- **R8 · `fit_*` needed no rename in 0.1.1.** The camel/snake "split" the survey flagged was entirely R1: `fitPsychometric` was camel because `+experiment/+analysis/` was camel, while `fit_csf`/`fit_edge_model_with_exps`/`fit_hyperexp_dist` are snake because `+general/` is snake. The verb and word order were already consistent, and the split dissolved on its own when S2.19 made it `fit_psychometric`.

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

**S2.19's filename map** (the second step-2a pass; 42 renames, all under the rules above). Every new name was checked for collisions with `which('<name>', '-all')` — 42 of 42 clear — and every one adds at least one underscore, so none needed the temporary-name two-step that a case-only rename does. **These are the current filenames.**

| old file | new file | why |
|---|---|---|
| `+experiment/gammaCorrect.m` | `+experiment/gamma_correct.m` | R1; the *word* stays open for S1.14 |
| `+experiment/generateTargetPresentMatrix.m` | `+experiment/generate_target_present_matrix.m` | R1 |
| `+experiment/loadCurrentSession.m` | `+experiment/load_current_session.m` | R1 |
| `+experiment/loadStimuliCamouflage.m` | `+experiment/load_stimuli_camouflage.m` | R1 |
| `+experiment/sampleNoisePatchForExperiment.m` | `+experiment/sample_noise_patch_for_experiment.m` | R1 |
| `+experiment/samplePatchesForExperiment.m` | `+experiment/sample_patches_for_experiment.m` | R1 |
| `+experiment/sampleUniformPatchForExperiment.m` | `+experiment/sample_uniform_patch_for_experiment.m` | R1 |
| `+experiment/saveCurrentLevel.m` | `+experiment/save_current_level.m` | R1 |
| `+experiment/sessionSettings.m` | `+experiment/session_settings.m` | R1 |
| `+experiment/sessionSettings_all.m` | `+experiment/session_settings_all.m` | R1 |
| `+experiment/sessionSettings_diff_bg.m` | `+experiment/session_settings_diff_bg.m` | R1 |
| `+experiment/sessionSettings_shape_exponent.m` | `+experiment/session_settings_shape_exponent.m` | R1 |
| `+experiment/sessionSettings_texture_exponent.m` | `+experiment/session_settings_texture_exponent.m` | R1 |
| `+experiment/setUpExperiment.m` | `+experiment/set_up_experiment.m` | R1 |
| `+experiment/setUpExperiment_all.m` | `+experiment/set_up_experiment_all.m` | R1 |
| `+experiment/setUpExperiment_diff_bg.m` | `+experiment/set_up_experiment_diff_bg.m` | R1 |
| `+experiment/setUpExperiment_search.m` | `+experiment/set_up_experiment_search.m` | R1 |
| `+experiment/setUpExperiment_shape_exponent.m` | `+experiment/set_up_experiment_shape_exponent.m` | R1 |
| `+experiment/setUpExperiment_texture_exponent.m` | `+experiment/set_up_experiment_texture_exponent.m` | R1 |
| `+experiment/subjectExperimentFile.m` | `+experiment/subject_experiment_file.m` | R1 |
| `+experiment/+main/checkFixationCross.m` | `+experiment/+main/check_fixation_cross.m` | R1 |
| `+experiment/+main/configureEyetracker.m` | `+experiment/+main/configure_eyetracker.m` | R1 |
| `+experiment/+main/displayLevelStart.m` | `+experiment/+main/display_level_start.m` | R1 |
| `+experiment/+main/fixationInterval.m` | `+experiment/+main/fixation_interval.m` | R1 |
| `+experiment/+main/giveFeedback.m` | `+experiment/+main/give_feedback.m` | R1 |
| `+experiment/+main/responseInterval.m` | `+experiment/+main/response_interval.m` | R1 |
| `+experiment/+main/runCamouflageExperiment.m` | `+experiment/+main/run_camouflage_experiment.m` | R1 |
| `+experiment/+main/runCamouflageExperiment_search.m` | `+experiment/+main/run_camouflage_experiment_search.m` | R1 |
| `+experiment/+main/stimulusInterval.m` | `+experiment/+main/stimulus_interval.m` | R1 |
| `+experiment/+main/testscripts/getTestExperimentStruct.m` | `+experiment/+main/testscripts/test_experiment_struct.m` | R1, R6 — drops the `get` prefix, as `getTargetIndexFromString` did in 0.1.1 |
| `+experiment/+main/testscripts/runSingleTrialTest.m` | `+experiment/+main/testscripts/run_single_trial_test.m` | R1 |
| `+experiment/+analysis/computeBootstrappedThreshold.m` | `+experiment/+analysis/compute_bootstrapped_threshold.m` | R1 |
| `+experiment/+analysis/computeNegLogLikelihood.m` | `+experiment/+analysis/compute_neg_log_likelihood.m` | R1 |
| `+experiment/+analysis/computeNegLogLikelihood_edgeResponse.m` | `+experiment/+analysis/compute_neg_log_likelihood_edge_response.m` | R1 |
| `+experiment/+analysis/computeTemplateResponseSigma.m` | `+experiment/+analysis/compute_template_response_sigma.m` | R1 |
| `+experiment/+analysis/computeThreshold_edgePower.m` | `+experiment/+analysis/compute_threshold_edge_power.m` | R1 |
| `+experiment/+analysis/computeThreshold_edgeResponse.m` | `+experiment/+analysis/compute_threshold_edge_response.m` | R1 |
| `+experiment/+analysis/computeThreshold_texture_exponent.m` | `+experiment/+analysis/compute_threshold_texture_exponent.m` | R1 |
| `+experiment/+analysis/computeThresholdsVsStatistic.m` | `+experiment/+analysis/compute_thresholds_vs_statistic.m` | R1 |
| `+experiment/+analysis/fitPsychometric.m` | `+experiment/+analysis/fit_psychometric.m` | R1 |
| `+experiment/+analysis/plotThresholdVsCondition.m` | `+experiment/+analysis/plot_threshold_vs_condition.m` | R1 |
| `+experiment/+analysis/psychometricFun.m` | `+experiment/+analysis/psychometric_fun.m` | R1 — `fun` kept, not expanded: it is MATLAB's own word for a function handle argument, not an ad-hoc abbreviation |

**Deliberately not renamed, with the reason** (documented negatives, so a later pass does not re-open them):

- ~~**All 43 camelCase filenames in `+experiment/`** — R2, deferred to S2.19.~~ **Done by S2.19** — 42 as measured, map above.
- **`+experiment/gammaCorrect.m`** — the survey's "triplicated `gammaCorrect`" is one file, one inline anonymous function (`run_camouflage_experiment_search.m:36`), and one sibling-repo function. With a single file there is nothing to disambiguate by suffix, and picking a *different word* for it is entangled with S1.14's choice of which implementation survives. S2.19 still snake_cased it to `gamma_correct.m`: that entanglement is about the word, not the casing, and leaving one camelCase filename behind would have defeated the retrofit.
- **`+experiment/+analysis/compute_thresholds_vs_lum_cont.m`** — already snake_case, so outside S2.19's casing scope. `lum_cont` is an abbreviation where the sibling vocabulary spells the words out (`luminance`/`contrast`, 0.1.7 decision A), which is an R6 case, but expanding it is a fresh naming judgement rather than a casing fix and the file's own live variable is spelled `lum_cont` too. Left for whoever next opens a naming pass on `+experiment/+analysis/`.
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

**"Done" checklist** — as in the skill's Step 3, plus: every identifier the repo owns is snake_case except external-API/frozen/class names (satisfied in `+experiment/` by S2.19; 49 in-file leftovers elsewhere are S2.20's); each file's `function` line agrees with its filename (checked repo-wide in 0.1.1 — one in-scope violation found and fixed, the rest are `_`-prefixed dead files).

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
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.11 — `+tinker/` (13 files, 1040 lines)</h5></summary>

<div style="margin-left:1.5em">

**Baseline.** HEAD, for all 13 files (working tree was clean at tranche start). Verified via `check_stage1` per file, MATLAB R2024b Update 6:

```
pink_noise                                    true
spatial_pattern                               true
pink_noise_line                               true
pink_noise_dist                               true
pink_noise_line_dist                          true
pink_noise_square_manual                      true
new_psychometric                              true
coloured_noise_cubes                          true
pink_noise_seed_multiple_energies             true
whitened_pink_noise_edge_energy               true
pink_noise_stimuli_autocorrelations           true
show_example_stimuli                          true
whitening_tinker                              true

ALL_OK: true
```

`assert_rename_bijection` passed for all 13 per-file rename maps (checked internally by `check_stage1`). Renames are file-local only (zone 1); no function/file names touched (that was 0.1.1's job) and no zone-2/zone-3 name touched.

**String-literal collision, caught by the check, not by inspection.** `+tinker/pink_noise.m` initially renamed the file-local `r`/`r_num`/`r_cont` (analytical correlation coefficient) to `correlation`/`correlation_sum`/`correlation_continuous`. `check_stage1` failed: the file already contains the pre-existing string literal `'correlation coefficient r(d)'` (two `ylabel` calls, present before this tranche), and the reverse-rename regex — which cannot know a match sits inside a string it never touched — turned it into `'r coefficient r(d)'` on reversal. Renamed to `corr_coef`/`corr_coef_sum`/`corr_coef_continuous` instead, which do not collide with any existing string or comment text; re-ran a repo-wide-style collision sweep (grep each candidate new name against every string literal in its own file) before finalizing every other file's map, which caught no further instances. This is the general hazard the skill's "short name eats a longer one" warning is about, one level removed: here the collision isn't with another *identifier*, but with an English word that already existed as prose inside the file, coincidentally identical to a chosen replacement name.

**Comment-text renames.** Unlike the step-2c commented-out-*code* triage (verdict only, nothing rewritten), ordinary prose comments and even the text of commented-out code lines were renamed alongside the code, wherever a renamed identifier appeared inside them — since `canon` strips all comments before comparing, this is invisible to `check_stage1` and keeps comments referring to live identifiers by their live names. Two renames were caught and hand-reverted because they hit ordinary English words rather than code: `whitening_tinker.m`'s cell titles "whitening **a** sine" / "whitening **a** single plane wave..." (the bare rename target `a`→`filter_shifted` ate the English article), and two comments describing a Fourier filter "1/**f**" (mathematical frequency notation, unrelated to the file's *other*, code-only `f`→`curve` rename) — rephrased to "1/frequency" to keep the intended meaning without reintroducing the abbreviation.

**Multi-role loop/scratch variables, same token reused for a different meaning within one file.** `pink_noise.m`'s `n` is the ensemble-sample index almost everywhere (10 occurrences) but is reused as a pixel-row index in the one FFT-filter-building loop (2 occurrences); kept the majority name `i_ensemble` throughout and added an explanatory comment at the minority site, following the `+general/rand_boundary.m` precedent (0.1.9) for exactly this situation. `whitening_tinker.m`'s bare `f` plays three different roles across three cells (an analytical-formula check, a continuous filter, and a constructed two-sine test edge) and was mapped to one generic name, `curve`, judged close enough in all three to skip a repeat of the comment treatment.

**Convention followed: `ml`/`cont`→`luminance`/`contrast`** (0.1.7 decision A) applied in `+tinker/` too, everywhere both appear (`pink_noise_seed_multiple_energies.m`, `whitened_pink_noise_edge_energy.m`, `whitening_tinker.m`). `img_pink_b`/`img_pink_t`/`img_whitened_b`/`img_whitened_t` renamed identically across all three files that share them (`pink_noise_blank`/`pink_noise_target`/`whitened_blank`/`whitened_target`), matching the "blank"/"target" spelled-out convention from 0.1.6.

**Headers.** All 13 rewritten to the exemplar shape (summary line, signature or `Script, no arguments`, `Inputs`/`Output` with units, `See also`). `spatial_pattern.m`'s pre-existing attribution (Jon Yearsley, 2004) kept per convention 6, moved into the new header rather than left as a separate block. `new_psychometric.m` and `+tinker/`'s other already-not-renamed names (per 0.1.1's deliberately-not-renamed list) are unchanged.

**`+tinker/Contents.m` written** (package had none; `+lib/`, `+general/`, `+vis/`, `+tests/` all have one — same convention applied here).

**Line-length exceptions: 4, all commented-out dead lines** (same category as 0.1.2's and 0.1.3's dead-line exceptions): `coloured_noise_cubes.m:21` (116, garbled pre-existing comment), `pink_noise.m:370` (104), `pink_noise_stimuli_autocorrelations.m:90` (123), `whitened_pink_noise_edge_energy.m:69` (102). Every live-code line that came out over 100 characters after renaming (~28, mostly `lib.stimulus`/`edge_energy` calls with many positional args, and a few `legend`/`corrcoef` calls) was reflowed with a 4-space-hanging-indent `...` continuation per step 2b, not left as an exception.

**Bugs found: B2.26, B3.21** (below). Neither fixed, per Stage 1 rules.

**Commented-out code: 20 blocks triaged**, T9.1–T9.20 (3.1.4). All are short (1–20 lines); none of the tranche's files carry an untriaged block afterward.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.1.12 — root (5 files, 356 lines)</h5></summary>

<div style="margin-left:1.5em">

**Baseline.** HEAD, for all five files — the working tree was clean at tranche start, including the two `+general/` files the 0.1.0 entry flagged (their `colorbarpzn` repoint was committed in `chore: carry forward pre-existing uncommitted edits`, so that caveat is now spent and no longer constrains any baseline). Verified via `check_stage1` per file, MATLAB R2024b Update 6:

```
config.m                 true
setup.m                  true
edge_power_demo.m        true
scratch.m                true
test_erlang.m            true

ALL_OK: true
```

All five passed first try. `assert_rename_bijection` passed for each per-file map (run inside `check_stage1`). Renames are file-local only (zone 1); no zone-2 name-value parameter and no zone-3 frozen name was touched, and no file was renamed (0.1.1 already did `test.m`→`scratch.m` and `test_Erlang.m`→`test_erlang.m`).

**`config.m`'s two extra checks, both clean.** Per the skill's "config files get an extra check": (a) `check_stage1` passed with an **empty** rename map, which is the stronger statement — the file's AST is byte-identical, so the returned struct cannot have moved; (b) belt-and-braces, `config()` was run before and after from separate folders and compared field by field, with each struct's own `repo_root` prefix stripped from the paths (they necessarily differ, since the paths are built from `mfilename('fullpath')`): `paths`, `optics`, `norm`, `seed` and the field-name lists all `isequal`-identical. The golden harness, which calls `config()` and seeds from `cfg.seed`, replayed clean: `golden_harness: replay matched all 32 fields`. `checkcode` unchanged across all five files — three messages, all on `scratch.m`'s one deliberately-unsuppressed line, same ids as before.

**S2.2 re-checked: `config.m` still has zero callers, with one correction to record.** A repo-wide grep for `config()`, `= config`, and `cfg.` finds exactly two references outside `config.m` itself: `tools/golden_harness.m:43` and the `cfg = config;` example at `README.md:53`. So the substance of S2.2 stands — no production code reads it — but the flat phrase "zero callers" is now slightly wrong, and in an ironic direction: the only thing calling the config is the cleanup tooling this plan added in 0.1.0. S2.2's entry has been amended to say so.

**Decision — no column-aligned assignments, anywhere.** `config.m` and `setup.m` were the last two files in the repo written as aligned tables (`cfg.paths.repo_root      = ...`). A grep across every already-cleaned package found **zero** surviving aligned assignments, so single-space is the established convention and was applied here rather than preserved. Alignment is also fragile in exactly the way step 2b warns about for continuations: one longer field name re-indents nine lines. Aligned columns are kept *inside header comments*, where every file in the repo aligns its `Inputs`/`Output` descriptions.

**Decision — the trailing-comment table in `config.m` became a documented `Output` block.** Nine of `config.m`'s fifteen assignments carried a trailing `% what this is` comment, six of which pushed the line past 100 characters. Rather than reflow nine comments, the descriptions moved into the header's `Output` block as the field-by-field list the exemplar shape asks for, with units attached (`optics.ppd` pixels per degree, `pupil_diameter` mm, `wavelength` nm, `norm.target_mean` mean grey level in image units — 128 implies an 8-bit 0–255 range, cross-checked against `lib.ptch_norm`'s `m0` — and `norm.target_contrast` dimensionless RMS contrast). Net effect: `config.m` now has **no** line over 100 characters, down from six. The one comment kept inline-as-prose is the 555-vs-550 nm note, because it is a live discrepancy (B1.10), not a description.

**Multi-role loop variable, `scratch.m`'s `i`.** Six loops: four index contours (`:81`, `:89`, `:163`, `:168`), two index stimuli (the hit-trial loop at `:132` and the gradient loop at `:143`). One token gets one name per file (convention 1), so the majority name `i_contour` was applied throughout and an explanatory comment added at each of the two minority sites — the `+tinker/pink_noise.m` (0.1.11) and `+general/rand_boundary.m` (0.1.9) precedent for exactly this. The split here is 4-vs-2 rather than 10-vs-2, so this is the least comfortable application of that rule so far; it was still preferred over inventing a meaning-neutral counter name, which would have made all six loops worse to read instead of two.

**Decision — `scratch.m`'s undefined workspace variables are left unrenamed, deliberately.** `ExpSettings` and `SubjectExpFile` are zone-3 frozen. `stims_all`, `stims_miss`, `bdry_strip` and the `edge_vector` at `:92` are neither frozen nor defined anywhere in the file: they are a de-facto interface to whatever a previous manual run left in the workspace. Renaming them would both break that (already broken) contract and erase the evidence for B3.23/B2.27 — the same reasoning that kept `mean_subj_acc` untruthful in 0.1.6. The header now says outright which cells are self-contained and which are not.

**Names kept, with reasons** (so a later pass does not re-open them): `ppd` — it is the spelling of the `cfg.optics.ppd` field, and expanding it in one file only would desynchronise them; `contour` — mirrors the frozen `contour_props` struct field and follows 0.1.3, accepted despite shadowing the `contour` builtin, since the file never plots a contour map; `por_sim` — mirrors `cfg.paths.por_sim` and the `por_sim_tx_synth/` folder; `folder` — the honest output name of a deliberately generic `locate_folder`; and every name-value mirror (`mask`, `mask_edge`, `mask_normal`, `kernel_size`, `target_radius`, `seed`, `texture`, `stim`) per convention 3.

**`setup.m`'s two same-meaning locals could not share a name.** `tb_dir` (in `ensure_addon_on_path`) and `d` (the output of `addons_toolboxes_dir`) hold the same thing in two different local functions, but a map sending both to `toolboxes_dir` is not injective and `assert_rename_bijection` rejects it. Split as `toolbox_root` and `toolboxes_dir` — both accurate, neither abbreviated. Worth knowing for any later tranche that hits the same shape: the bijection constraint is per *file*, so two local functions in one file cannot converge on a name.

**Local subfunction renamed, and why that is still zone 1.** `fetch_commons` → `fetch_vislab_common`. A local subfunction is invisible outside its file, so it is a file-local name, not a step-2a file rename; `check_stage1` covers it as a bare identifier at its one call site. `commons` was a token used nowhere else in the repo, while `vislab-common` is the actual repo being cloned (R5, one token per concept). `locate_folder` was **not** renamed — it takes a `name` argument and its generality is real, even though it is only ever called with `'+vislab'`.

**Header docs.** All five rewritten to the exemplar shape. The two scripts (`edge_power_demo.m`, `scratch.m`) and `test_erlang.m` use `Script, no arguments` with `Output: none (side effect: ...)`, per 0.1.5/0.1.11. `setup.m`'s four local functions each got their own `Inputs`/`Output` block too, since three of them return a value whose empty case is meaningful. `scratch.m`'s header enumerates its eight cells and states up front which ones depend on workspace state. **No root `Contents.m`** — the root is not a package, so the per-package `Contents.m` convention does not apply; `+lib/`, `+general/`, `+vis/`, `+tests/`, `+tinker/`, `+experiment/` and its two subpackages all have theirs.

**Line-length exceptions: 3.** `setup.m:82` (111) and `:83` (104) are elements of a `[...]` string concatenation in the `noData` warning; re-splitting them would change the string literals, a real AST change Stage 1 forbids — both were already over the limit before this tranche (111/105 at the old `:60`/`:61`). `scratch.m:99` (103) is a commented-out dead line, T10.2, the same category as 0.1.2/0.1.3/0.1.11's dead-line exceptions. Everything else that came out long was reflowed with a 4-space hanging-indent `...`, including six lines in `config.m` (103–119 characters in the original) and five in `scratch.m` (101–138; the sixth is T10.2's exception above). One pre-existing tab, inside T10.1's commented block (`% Niter = 25;<TAB>%`), was converted to two spaces — whitespace inside a comment, invisible to `canon`, and the "never tabs" rule admits no exception.

**Bugs found: B2.27, B3.22, B3.23**, plus a second site recorded against the existing **B3.6**. None fixed, per Stage 1 rules.

**Optimizations: none — a documented negative.** All seven survey patterns were checked over the 356 lines: no loop-invariant work (the four contour loops and two stimulus loops each do genuinely per-iteration work), no file I/O in any loop, no `inv`/`pinv`/`det`, no `parfor`, no whole-array recomputation, and no vectorizable elementwise loop. The one array that grows, `stims_all = cat(3, stims_all, hit_stimuli)`, grows once per manual cell invocation rather than inside a loop, which the skill excludes explicitly. No structural opportunity was acted on either; S2.2 was annotated with what this tranche learned about it.

**Commented-out code: 3 blocks triaged**, T10.1–T10.3 (3.1.4), all in `scratch.m`. The other four files carry none.

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
| T4.1 | `+experiment/+main/display_level_start.m:39-45` | 0.1.5 | **alternative** — draw-order branch |
| T4.2 | `+experiment/+main/give_feedback.m:20,23,26` | 0.1.5 | **alternative** — `sound()` vs `Beeper()` |
| T5.1 | `compute_neg_log_likelihood.m:17-18,24-30,32-33,38,40` | 0.1.6 | **alternative** ×3 |
| T5.2 | `compute_neg_log_likelihood_edge_response.m:50-54` | 0.1.6 | **alternative** — bias-aware model, same as T7.18 |
| T5.3 | `fit_psychometric.m:16-28` | 0.1.6 | **superseded** — old API computed `target_means` itself |
| T5.4 | `compute_threshold_edge_power.m:62-64,96-97` + `compute_threshold_texture_exponent.m:96-97` | 0.1.6 | **superseded** — mu-fixed-at-0 decision |
| T5.5 | `compute_threshold_edge_response.m:8,33,67-69` | 0.1.6 | **unfinished** ×2 |
| T6.1 | `set_up_experiment.m:21,52-64` → after S2.3, `:95,128-140` | 0.1.7 | **alternative** — automatic bin-edge rule; preserved verbatim by S2.3, still S1.16's to convert |
| T6.2 | `set_up_experiment.m:26,29` → after S2.3, `:101,104` | 0.1.7 | **superseded** by exp_type-derived path |
| T6.3 | `set_up_experiment.m:71-77,81,84,90` → after S2.3, `:196,199-203,207,210,215` | 0.1.7 | **alternative** / **superseded** (hardcoded subject list). The `%subject_str` line existed in all five set-up files; the collapse leaves one copy, the same block |
| T6.4 | `save_current_level.m:24-33` | 0.1.7 | **alternative** — per-subject storage the author stopped keeping |
| T6.5 | `load_stimuli_camouflage.m:29-30,78-81,99` | 0.1.7 | **alternative** / **superseded** (edge-power reads) |
| T6.6 | `generate_camouflage_stimuli.m:6,36,41,51-54` | 0.1.7 | **superseded** ×3 / **unfinished** ×1 |
| T6.7 | `generate_camouflage_stimuli_shape_exponent.m:2-5,19,22` | 0.1.7 | **superseded**, all 4 |
| T6.8 | `set_up_experiment_shape_exponent.m:25,30-31` | 0.1.7 | **superseded**, ties to S2.3 — **discharged by S2.3**: the commented `kernel_size` and `global bdry_ribbon`/`lib.circular_mask` lines went with the file, which is what a *superseded* verdict prescribes. Nothing left for S1.16 |
| T6.9 | `set_up_experiment_search.m:12-16` | 0.1.7 | **alternative** — per-paradigm session count |
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
| T9.1 | `+tinker/coloured_noise_cubes.m:5-8` | 0.1.11 | **alternative** — per-frame `exportgraphics` GIF writer, superseded by the live `getframe`/`imwrite` approach below |
| T9.2 | `+tinker/pink_noise.m` (1D autocorrelation cell) | 0.1.11 | **alternative** — `autocorr()` builtin vs. the manual double-loop computation used live |
| T9.3 | `+tinker/pink_noise.m` (1D autocorrelation, corrected cell) | 0.1.11 | **alternative** — same as T9.2, second occurrence |
| T9.4 | `+tinker/pink_noise.m` (2D autocorrelation, corrected cell) | 0.1.11 | **alternative** — continuous hypergeom lag-response formula, superseded by the discrete-sum plot just above it |
| T9.5 | `+tinker/pink_noise.m` (test properties of filtered noise cell) | 0.1.11 | **scaffolding** — stray histogram diagnostic |
| T9.6 | `+tinker/pink_noise_seed_multiple_energies.m` (figure/imagesc + `reverse_pink_noise_square` lines) | 0.1.11 | **alternative** — a whiten-and-visualize diagnostic path, disabled |
| T9.7 | `+tinker/pink_noise_seed_multiple_energies.m` ("Only compute perp_ratio energy") | 0.1.11 | **superseded** — single-measure version, superseded by the live multi-type energy loop below it |
| T9.8 | `+tinker/pink_noise_stimuli_autocorrelations.m` (`corr_same`-related lines throughout) | 0.1.11 | **alternative** — a same-side (non-crossing) correlation measure, abandoned in favor of computing only the cross-boundary one; ties to B3.21 |
| T9.9 | `+tinker/pink_noise_stimuli_autocorrelations.m` (`%xlim([0 150])`) | 0.1.11 | **scaffolding** — display-range tweak |
| T9.10 | `+tinker/pink_noise_stimuli_autocorrelations.m` (commented `save(...)`) | 0.1.11 | **alternative** — a fuller checkpoint save including the LLR fields, not currently produced |
| T9.11 | `+tinker/pink_noise_stimuli_autocorrelations.m` (final commented plot) | 0.1.11 | **scaffolding** — diagnostic plot, ties to B3.21 |
| T9.12 | `+tinker/show_example_stimuli.m` (three commented `edgeEnergyLevels`/`edgeEnergyBlockEdges` lines) | 0.1.11 | **alternative** — three other edge-energy-measure calibration ranges (mag+dir, dir, mag), switched away from the live ratio-of-perp-gradients one |
| T9.13 | `+tinker/spatial_pattern.m` (final commented line) | 0.1.11 | **alternative** — real-part-only output, an alternative to returning the complex pattern |
| T9.14 | `+tinker/whitened_pink_noise_edge_energy.m` (figure/imagesc lines) | 0.1.11 | **scaffolding** — stray diagnostic plot lines |
| T9.15 | `+tinker/whitened_pink_noise_edge_energy.m` ("Compute multiple types of energies") | 0.1.11 | **alternative** — multi-type energy computation, superseded by the single grad_by_norm measure live above it |
| T9.16 | `+tinker/whitening_tinker.m` (split-half noise draft, early in the file) | 0.1.11 | **superseded** — redone properly in the "examples of whitened stimuli" cell later in the file |
| T9.17 | `+tinker/whitening_tinker.m` (commented complex-exponential formula lines) | 0.1.11 | **alternative** — a complex-exponential formulation of the same analytical check |
| T9.18 | `+tinker/whitening_tinker.m` ("whitening a sine" cell, commented tail) | 0.1.11 | **unfinished** — a sinusoid-whitening sketch, never completed |
| T9.19 | `+tinker/whitening_tinker.m` (`%plot([50 50],ylim,'k')`) | 0.1.11 | **scaffolding** — marker-line diagnostic |
| T9.20 | `+tinker/whitening_tinker.m` (`%title(sprintf(...))`) | 0.1.11 | **scaffolding** — debug title |

| T10.1 | `scratch.m:35-46,48` | 0.1.12 | **alternative** — a Portilla-Simoncelli texture source (`textureAnalysis` on `foliage.jpg`, `Nsc`/`Nor`/`Na`/`Niter`, then `lib.stimulus`), switched away from in favour of the live pink-noise texture two lines below, which reuses the same seed 35096. Complete and runnable, given the vendored toolbox and the image on disk |
| T10.2 | `scratch.m:99-100` | 0.1.12 | **superseded** by the live `:102-105` — literally the same two calls (`lib.stimulus`, `lib.edge_vector`), with the mask outputs threaded through instead of discarded |
| T10.3 | `scratch.m:110` | 0.1.12 | **alternative** — quivers `edge_field` where the live `:111` quivers `mask_normal`; same plot, different vector field |

`+tinker/`'s dead-code lines (0.1.11) are triaged above, T9.1–T9.20. Root's (0.1.12) are T10.1–T10.3; `config.m`, `setup.m`, `edge_power_demo.m` and `test_erlang.m` carry **no** commented-out code at all, only prose comments.

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.2 · Stage 2 · Tidying</h3></summary>

<div style="margin-left:1.5em">

Harness extension (0.2.0) done; tranches 0.2.3, 0.2.4 done. Coverage now 26 entry points / 57 fields, with the pattern-check-only residue enumerated per file below.

**Per-tranche work log.**

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.0 — extending the golden harness (<code>tools/golden_harness.m</code>, <code>tools/golden_ref.mat</code>)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: clean HEAD (`593639e`), working tree clean, nothing else changed in this step. **16 entry points / 32 fields → 26 entry points / 57 fields.**

**How the candidate set was found, so the negative is measured and not an impression.** `grep -c '^function'` over every in-scope file in each directory, then a read of each hit. `+general/`: 31 in-scope files, **exactly 1** has a `function` line. `+tinker/`: 13 files, **exactly 5**. `+vis/`: 5 of 8. `+tests/`: 1 of 2. Everything else in those four packages is a top-level script — no callable entry point exists to add, so "pattern-check only" there is a fact about the files, not a choice.

**Ten entry points added, one line of reason each.**

| entry point | tranche | why it qualified |
|---|---|---|
| `experiment.analysis.compute_neg_log_likelihood_edge_response` | 0.2.2 | Pure: takes synthetic contour-group cell arrays and count vectors, calls only `lib.edge_response`/`normcdf`/`binopdf`. It is the objective `compute_threshold_edge_response` minimizes, so it is the numerically load-bearing half of that file's chain. Three branches pinned: optimal, subject, out-of-domain `+Inf`. |
| `experiment.analysis.compute_template_response_sigma` | 0.2.2 | Pure, no I/O, no figures; only needs an `ImgStats`-shaped struct, which can be synthesised. Toolbox-free. |
| `experiment.gamma_correct` | 0.2.3 | An easy win the smoke test had already proved safe to call: a pure display-calibration curve whose numbers would move silently if touched. |
| `experiment.generate_target_present_matrix` | 0.2.3 | Same; RNG-driven (`binornd`, `randperm`), so both its branches are worth pinning under an explicit seed. |
| `general.compute_nll_edge_model` | 0.2.4 | `+general/`'s **only** function. Pure given a synthetic `edge_model` struct array. Without it tranche 0.2.4 would have had no runtime check at all. |
| `tinker.pink_noise_dist` | 0.2.5 | Deterministic, no RNG, no I/O; 1-D and 2-D branches both pinned. |
| `tinker.pink_noise_line_dist` | 0.2.5 | Deterministic, no RNG, no I/O. |
| `tinker.pink_noise_line` | 0.2.5 | Pure given a seed (`unifrnd`). |
| `tinker.pink_noise_square_manual` | 0.2.5 | Pure given a seed; kept at 32 px and two frequencies because it is the deliberately slow literal implementation. |
| `tinker.spatial_pattern` | 0.2.5 | Pure given a seed (`rand`); complex-valued output, which `chk` handles unchanged. |

**Declined, explicitly, with the reason — `+experiment/+analysis/`, file by file.** The seven of its twelve files that are not covered:

| file | why not |
|---|---|
| `compute_bootstrapped_threshold.m` | Bare `load` of a hardcoded, machine-specific Dropbox path (B2.11), then delegates the fit to `nm.analysis.fitPsychometric`, which resolves to nothing (B2.9). Not callable at all here. |
| `compute_threshold_edge_power.m` | `load`s `./exp_files/<type>/exp_settings.mat` and `subject_out/<subject>.mat`; no synthetic stand-in without inventing the whole session format, which is S3.7's work. |
| `compute_threshold_edge_response.m` | Same two loads, plus `fminsearch` with `'PlotFcns', @optimplotfval`, which opens a figure. |
| `compute_threshold_texture_exponent.m` | Same two loads. |
| `compute_thresholds_vs_lum_cont.m` | A script — no `function` line — and its loop body calls the unresolved `analysis.computeThresholdInBin` (B2.9). |
| `compute_thresholds_vs_statistic.m` | A function, but its *first* statement calls the same unresolved `analysis.computeThresholdInBin`, and the rest is plotting. |
| `plot_threshold_vs_condition.m` | A script that errors on its first line on an undefined `dur` (B2.17). |

**Declined elsewhere, en bloc, each with its measured reason.** `+general/`: the 30 files without a `function` line — top-level scripts, most of them doing real image I/O. `+tinker/`: the 8 files without a `function` line. `+vis/`: all 8 — the five functions (`plot_edge_energy_hists`, `show_example_patches`, `show_image`, `show_patch_grid`, `show_patches_one_by_one`) exist only for their figure side effect and return nothing to fingerprint. `+tests/`: both — `block_jumping.m` is a script and `gabor_similarity.m` errors on its first call (B2.24/B2.25). `+experiment/` and `+experiment/+main/`: the remainder are Psychtoolbox/display-bound, write into `exp_files/`, or need a loaded session; the two easy wins above were taken and nothing else was, per this step's brief.

**Three conventions set here, binding on anything that touches the harness later.**

1. **New golden field names are snake_case, mirroring the function name**, with a short suffix per extra output (`compute_nll_edge_model_pc`, `..._d`, `..._resp`). The six pre-existing camelCase field names — `compute_pClipped`, `compute_pClipped_clipped`, `computeNegLogLikelihood`, `computeNegLogLikelihood_out_of_range`, `psychometricFun_*`, `fitPsychometric` — are **zone-3 frozen**: they are serialised inside `tools/golden_ref.mat`, and 0.1.1 and S2.19 each already had to rescue one of them from a blanket rename. Do not harmonize them; add new ones in snake_case.
2. **`compute_template_response_sigma`'s synthetic bin grid is deliberately non-cubic (3×4×5).** B3.4 is that its `i_similarity` loop bound is `size(template_sigma, 1)` rather than `(..., 3)`; on a cube that bug is invisible, on 3×4×5 the last two similarity slices stay zero and the fingerprint records it. **This means fixing B3.4 must fail replay** — that is intended, and its Stage-4 log entry should recapture deliberately rather than treat it as drift.
3. **Toolbox gating is now three-way, not two.** A new `if has_stats` section sits between the toolbox-free block and the existing `has_stats && has_ipt` block, because the entry points added here need `binornd`/`unifrnd`/`normcdf`/`binopdf` but not Image Processing. Each section warns rather than errors when its toolbox is missing.

**Capture-then-replay, verified against the old reference before overwriting it.** Because a reflex recapture can bless a bad edit, the new harness was first captured to a scratch file and all 32 pre-existing fields compared field by field against the committed `tools/golden_ref.mat`: `old fields 32, drifted 0, new total 57`. Only then was `tools/golden_ref.mat` recaptured. Verbatim, MATLAB R2024b Update 6:

```
golden_harness: captured 57 fields to tools/golden_ref.mat
=== REPLAY ===
golden_harness: replay matched all 57 fields
```

`checkcode('tools/golden_harness.m')`: no messages. `canon` parses it (9816 chars).

**One pre-existing oddity, checked and cleared.** A capture run prints five bare `ans = <n>` lines. They are **not** from anything added here: the HEAD copy of the harness, run unchanged from a scratch directory, prints the same five, in a different order each time — they are the parallel-pool worker ids from `lib.autocorr`'s `parfor`. Noted, not fixed, not a new finding.

**No bug, optimization, or structural item was found or acted on.** This step adds harness code and reads repo code; the three bugs it leans on (B2.9, B2.17, B3.4) were all already recorded.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.1 — <code>+lib/</code> (tranches 0.1.2–0.1.4, golden-checked, 13 entry points)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: HEAD (clean at start; scope was the 53 `+lib/` files listed by `git ls-files '+lib/*.m'`, no `_`-prefixed files in this directory). `checkcode` run across all 53 files first, then each of the four whitelisted patterns checked by hand against the messages and a direct grep.

**Pattern 1 (missing suppressing `;`): 1 hit, fixed.** `+lib/autocorr.m:26` — a bare `i_row_shift` inside the `parfor` loop, read again at `:28,32`, so not the "deliberate final print" case; added the semicolon. This is a golden-checked entry point (`lib.autocorr`). A second candidate, `+lib/edge_props_stim.m:122`'s bare `randi(10)`, was found and **declined**: it is B2.2's recorded debug scaffolding (RNG-advancing, slated for deletion by S1.13), so suppressing its display now would edit a line already earmarked for removal rather than tidy a real omission — left untouched.

**Pattern 2 (`find` → logical indexing): none found.** Four `find(...)` call sites in scope (`edge.m:110`, `edge_vector_ideal.m:98`, `target_index_from_string.m:15`, and three single-match `find(..., 1)` calls in `trace_contours.m:44,46,57`). All four are excluded by the pattern's own carve-outs: the first two are two-output `[rows, cols] = find(mask)` forms whose numeric subscripts index a second array (`theta_field(edge_rows(i_row), edge_cols(i_row))`) and feed `knnsearch`; `target_index_from_string.m` returns its `find` result as the function's own scalar index output; the `trace_contours.m` calls all pass an explicit `1` (first-match), which needs a single index, not a mask.

**Pattern 3 (unpreallocated growth): 2 `checkcode` AGROW hits, both examined and declined.** `find_spot_centers.m:25` (`centers(end+1, :)`) and `trace_contours.m:66` (`contours{end+1, 1}`). Neither fits the whitelist's fix recipe: `find_spot_centers` grows `centers` both within its loop and across its own recursive calls, so the eventual size depends on the recursion's own results; `trace_contours` grows `contours` once per contour found by a data-dependent `while` loop, so the count isn't known until the trace over the link map finishes. A "pre-pass with no RNG draws" would have to re-run the same traversal to count first — duplicating the algorithm, not tidying it. Filed as **O3.6** instead of fixed.

**Pattern 4 (unused assignments `checkcode` flags): 3 hits fixed, 1 declined.** `+lib/edge_props_stim.m:114` (`mask_strip_xy = repmat(mask_strip, [1, 1, 2])`, NASGU) and `:143` (`grad_hist_thresh = parser.Results.grad_hist_thresh`, NASGU) — both confirmed by grep to have no other read in the file, deleted. `+lib/haar_2d.m:67` (`y_over_x = y_grid./x_grid`, NASGU) — deleted; this made the file's dead `%% Envelope` block's `[x_grid, y_grid] = meshgrid(x, y)` (flagged ASGLU, both outputs unused since `envelope = haar_grid` per the function's own header doc) provably dead too, so its 4 lines (the two `x`/`y` builds and the `meshgrid` call) were removed along with it; `checkcode('+lib/haar_2d.m')` is clean after. `+lib/stimulus.m:255` (`[mask_tight, mask_edge_tight, mask_normal_tight, mask_strip_tight] = lib.target_mask(...)`, ASGLU ×3) — the three unused outputs replaced with `~`, keeping `mask_tight`; this is a golden-checked entry point (`lib.stimulus`). **Declined:** `+lib/edge_props_stim.m:225-233`'s `stim_grads_pca` chain (NASGU at the final line) is the exact subject of the already-recorded **B3.15** ("computes PCA rotation and discards it") — its surrounding comment cites B3.15 by name. Deleting it now would erase the in-file pointer to an open bug under cover of a Tidying tranche, so it was left exactly as found.

**Golden harness, verbatim (MATLAB R2024b Update 6):**
```
golden_harness: replay matched all 57 fields
```
No recapture — output unchanged, as expected for all four patterns above (semicolon/`~`/dead-line changes are display- or read-only, never load-bearing).

**A stale attribution in the 0.2.0 log entry, corrected here rather than edited there.** That entry (above) attributes a capture run's five bare `ans = <n>` lines to "the parallel-pool worker ids from `lib.autocorr`'s `parfor`." Fixing pattern 1's `i_row_shift` hit makes those five lines disappear from a fresh capture-mode run (checked, not committed — capture wasn't re-run for real since nothing here needed a recapture) — they were this line's unsuppressed display all along, one per loop iteration on the 5-shift golden call, not worker-pool chatter. Left as a note here since 0.2.0's own entry is another tranche's record.

**`check_stage1`-style diff check.** No rename map involved (Stage 2, not Stage 1); verified by hand instead that each file's diff is exactly one of the four patterns — a `;` insertion, an output arg replaced with `~`, or a whole-statement/whole-block deletion with no other line touched — via `git diff` on each of the four changed files (`autocorr.m`, `stimulus.m`, `edge_props_stim.m`, `haar_2d.m`). No other `+lib/` file was touched.

**Verification split.** 13 files are golden-checked entry points (list in section 1); two of the four edited files (`autocorr.m`, `stimulus.m`) are on that list and are covered by the replay above. `edge_props_stim.m` and `haar_2d.m` are pattern-check only — confirmed via `checkcode` (both clean of the targeted messages after edit) and, for `haar_2d.m`, `tools/smoke_test.m`'s `lib.haar_2d()` default-argument call (unchanged code path — the deleted lines were unreachable from any output).

**Bugs found: none new.** (The haar_2d `%% Envelope` dead block was checked against its own header doc — `envelope` is documented as `haar_grid`, so the dead lines are leftover scaffolding, not a functional bug, and were removed under pattern 4 rather than recorded.)

**Optimization found: O3.6** (above), declined per Stage 2's closed list.

**Working-directory note.** `docs/repo-cleanup.md` and several files outside `+lib/` (`+experiment/`, `+general/`, `+vis/`) were under concurrent edit by other tranches (0.2.2–0.2.4) while this tranche ran; this entry and the 0.2.1 checklist tick are the only edits made here, and no other tranche's in-progress changes were touched or reverted.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.2 — <code>+experiment/+analysis/</code> (tranche 0.1.6, 12 files)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: clean HEAD, working tree clean at the start of this step. Scope: the 12 in-scope files (`Contents.m` and the 7 `_`-prefixed dead files excluded per 2). 5 golden-covered (`psychometric_fun`, `compute_neg_log_likelihood`, `fit_psychometric`, `compute_neg_log_likelihood_edge_response`, `compute_template_response_sigma`), 7 pattern-check-only (`compute_bootstrapped_threshold.m`, `compute_threshold_edge_power.m`, `compute_threshold_edge_response.m`, `compute_threshold_texture_exponent.m`, `compute_thresholds_vs_lum_cont.m`, `compute_thresholds_vs_statistic.m`, `plot_threshold_vs_condition.m`), per 0.2.0's log entry.

**Pattern 1 (missing suppressing semicolons): none found.** Every candidate line surfaced by grep was a false positive of one of two shapes: a trailing `%` comment after an already-present `;` (`correct_reject = logical([]); % mirrors...`, `p_correct = mean(correct); % prob. of correct`, in all three `compute_threshold_*` files), or a void-output plotting/axis call (`xline`, `ylim`, `xlim`, `zlim`, `xlabel`, `set(gca, ...)`) called with no output captured — these print nothing regardless of the trailing `;`, so there is no suppression to add.

**Pattern 2 (`find(...)` → logical indexing): none found.** No file in the tranche calls `find` at all.

**Pattern 3 (unpreallocated growth, `x(end+1)`/`x{end+1}`): none found.** No file uses that idiom. Four files do grow arrays by repeated `var = [var; new_data]` concatenation in a loop (`compute_bootstrapped_threshold.m:72,74`; `compute_threshold_edge_power.m:72-76`; `compute_threshold_edge_response.m:94-100`; `compute_threshold_texture_exponent.m:73-77`) — but that is a different AST shape from the whitelisted `end+1` idiom, and the plan's own survey already filed exactly these instances as **O3.2** (0.5, Speed), not a Stage 2 target. Two more instances of the same concatenation/direct-index-growth shape turned up under `checkcode` in files O3.2 doesn't enumerate — `compute_template_response_sigma.m:43,44,47,49` (golden-covered) and `compute_thresholds_vs_statistic.m:41,87` (pattern-only) — consistent with O3.2's own text ("~40 instances across ~20 files, heaviest in...", not exhaustive); noted here, not added as a new O-item, and not touched.

**Pattern 4 (unused assignments `checkcode` flags): 4 hits, all fixed.** `checkcode` flagged "Value assigned to variable might be unused" at 4 sites, all in pattern-only files, all confirmed by a repo-wide grep for the variable name to have no other read and no output-argument role:

| file | line | statement removed | why safe |
|---|---|---|---|
| `compute_threshold_edge_power.m` | 157 | `mu_sd = std(mu_boot);` | `mu_boot` is always `zeros(1, n_boot)` (never reassigned before this line), so `mu_sd` is deterministically 0 and never read again; not an output. |
| `compute_threshold_edge_response.m` | 198 | `mu_sd = std(mu_boot);` | same shape/reasoning. |
| `compute_threshold_texture_exponent.m` | 65 | `blank_mean = 0;` | only other reference is inside a commented-out line (`%     mu_init=blank_mean;`, dead); not an output. |
| `compute_threshold_texture_exponent.m` | 158 (156 pre-edit) | `mu_sd = std(mu_boot);` | same shape/reasoning as the other two. |

Removing `compute_threshold_texture_exponent.m:65` left two adjacent blank lines; the following blank line was removed with it to keep formatting consistent with Stage 1's blank-line rule — the only edit in this tranche not itself one of the four literal statement deletions.

Two other `checkcode` message families showed up repeatedly and were left alone as out of the closed list: "Function return value might be unset" (`x_pmf`/`y_pmf` and friends — pre-existing, already documented in each file's header, B3.10-adjacent) and "Input argument might be unused" (`compute_neg_log_likelihood_edge_response.m`'s `n_blanks`/`n_targets` — a signature-level question, Stage 3 territory, already explained in the header). `compute_bootstrapped_threshold.m:104`'s `'hist' is not recommended, use 'histogram' instead` was also left alone — a deprecation nit, not a missing-semicolon/find/growth/unused-assignment hit, and changing it risks a real behaviour difference (bin edges) that is a judgment call, not a Stage 2 edit.

**Verification.** `check_stage1` with an empty rename map, baseline = clean HEAD for all 12: the 9 untouched files matched (`match=1`) confirming no accidental edits; the 3 edited files did not match (`match=1` was not expected — deleting a statement is a real, whitelisted AST change), and the `canon(old)` vs `canon(new)` diff was inspected directly for each and confirmed to be exactly the deleted line(s), nothing else:

```
compute_bootstrapped_threshold.m              match=1 expect=1 true
compute_neg_log_likelihood.m                  match=1 expect=1 true
compute_neg_log_likelihood_edge_response.m    match=1 expect=1 true
compute_template_response_sigma.m             match=1 expect=1 true
compute_threshold_edge_power.m                match=0 expect=0 true
compute_threshold_edge_response.m             match=0 expect=0 true
compute_threshold_texture_exponent.m          match=0 expect=0 true
compute_thresholds_vs_lum_cont.m              match=1 expect=1 true
compute_thresholds_vs_statistic.m             match=1 expect=1 true
fit_psychometric.m                            match=1 expect=1 true
plot_threshold_vs_condition.m                 match=1 expect=1 true
psychometric_fun.m                            match=1 expect=1 true
ALL AS EXPECTED: 1
```

Golden-harness replay (5 golden-covered functions among the 57-field/26-entry-point set): `golden_harness: replay matched all 57 fields` — clean, verbatim. The other 7 files are pattern-check-only, as stated above and per 0.2.0's log entry; none of the 4 edits touched them.

No new bug, structural item, or optimization was found (the `checkcode` growth hits duplicate/extend O3.2, already on file; the `hist`/deprecation nit and the header-documented undefined-output/unused-argument messages are pre-existing and out of the closed pattern list, not new findings).

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.3 — <code>+experiment/</code> and <code>+experiment/+main/</code> (tranches 0.1.5, 0.1.7)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: clean HEAD, working tree clean at the start of this step. Scope: 26 files under `+experiment/` (root, incl. `Contents.m`) and 10 files under `+experiment/+main/` (incl. `Contents.m`), all snake_case per S2.19. `+experiment/+main/testscripts/` (`run_single_trial_test.m`, `test_experiment_struct.m`) is not assigned to any 0.2.x row — not addressable under any package-qualified name (3.1.3's step-S2.19 note) — but was included in this tranche's pattern sweep anyway, out of caution; `checkcode` found nothing in either file.

**Pattern 1 — missing suppressing semicolons: 1 hit, fixed.** `+experiment/+main/check_fixation_cross.m:88`, `t0 = GetSecs()` inside the `'c'`-key recalibration branch — the same statement appears twice more in the file (`:32`, `:66`), both already suppressed with `;`. `t0` is read again on the next loop iteration (`:43`), so an unsuppressed `GetSecs()` here would print a bare timestamp to the console on every manual recalibration during a live session — not the kind of "deliberate interactive feedback" this scope is supposed to be conservative about, since its two sibling statements are suppressed and this one has no comment marking it as intentional. Fixed: added `;`. One additional candidate was found and **left alone as deliberate**: `+experiment/set_up_experiment_search.m:103`, `[i_session i_trial target_loc_index]` — already carries an inline comment, `% unsuppressed on purpose: progress report`, from an earlier tranche. Not touched.

**Pattern 2 — `find(...)` that could be logical indexing: none found.** Six `find(...)` calls in scope, all excluded by the rule: `generate_camouflage_stimuli.m:72` (result fed to `randsample` as a population of indices, not a mask target); `load_current_session.m:49` (two-output `find` for row/col subscripts — no logical-indexing equivalent); `load_current_session.m:56,58-59` (index used to index two other arrays, `not_completed_bin`/`not_completed_session`); `load_current_session.m:66` (result stored as `SettingsOut.currentBin`, a bin-identifier label, not used for indexing); `sample_patches_for_experiment.m:78-79` (index used to index `patch_index_bin`, flagged by `checkcode` itself but excluded by this pattern's own carve-out for indexing a second array); `run_camouflage_experiment_search.m:29,81` (used as a `for`-loop's scalar start bound).

**Pattern 3 — unpreallocated growth: none found.** No `x(end+1)`/`x{end+1}` anywhere in scope (`grep -n 'end+1\|end + 1'`, zero hits).

**Pattern 4 — unused assignments `checkcode` flags: 4 sites fixed, several considered and left alone.** Full `checkcode` sweep of all 38 in-scope files (36 `+experiment/`/`+main/` files + 2 `testscripts/`), reproduced verbatim below. Fixed, all pure renames/deletions with no side effects lost:

- `check_fixation_cross.m:69` — `[key_is_down, secs, key_code] = KbCheck;`, only `key_code` read → `[~, ~, key_code] = KbCheck;`.
- `configure_eyetracker.m:22` — `[status, dummy] = EyelinkInit();`, only `dummy` read → `[~, dummy] = EyelinkInit();`.
- `display_level_start.m:31-32` — `fix_pos_xy = fix_pos_pix_xy;` and `fixation_interval_s = SessionSettings.fixationIntervalS;`, neither read again anywhere in the file → both lines deleted.

Considered and **left alone**, each for a specific reason:

- `generate_camouflage_stimuli_all.m:3` (unused input argument) — deleting or `~`-ing a function argument is a signature change, Stage 3, not Stage 2.
- `sample_noise_patch_for_experiment.m:2,45,48,49` (`sample_method` input, `target_key_index`, `n_patches`) — already documented as dead in this file's own header ("`n_patches` is likewise computed and never used"). `target_key_index`'s right-hand side, `lib.target_index_from_string(...)`, may have a validation side effect independent of its return value, and the function cannot currently run at all (`lib.pink_noise_2d` doesn't exist, B2.9) so there is no way to verify a deletion by running it. Left untouched; no verification path exists for this file.
- `give_feedback.m:30-32` (`correct_tone`/`incorrect_tone`/`error_tone`) — these feed the commented-out `sound(...)` calls already triaged as **alternative** in T4.2 (3.1.4); deleting them now would pre-empt that Stage 3 conversion.
- `check_fixation_cross.m:24,27,28` (`x`/`y`/`button` from `GetMouse`, `evt.genx`/`evt.geny`) — not a single dead local but a whole dummy-mode branch with no observable effect; recorded as **B3.25**, not fixed here.
- `stimulus_interval.m:61` (`stimulus_onset_time`, overwritten at `:73` before being read) — already recorded as **B3.16**, the file's own header names this exact line pair as a known, deliberately-unfixed latent bug.

Verbatim `checkcode` output that this section's reasoning is based on (38 files; only files with messages shown):

```
== generate_camouflage_stimuli.m ==
  L91: The entire array or structure 'edge_powers' is a broadcast variable...
== generate_camouflage_stimuli_all.m ==
  L3: Input argument might be unused...
== load_current_session.m ==
  L41: To avoid conflicts with functions on the path, specify variables to load from file.
  L44: Explicitly initialize this variable to avoid a potential uninitialized variable...
  L75: To avoid conflicts with functions on the path, specify variables to load from file.
== sample_noise_patch_for_experiment.m ==
  L2, L45, L48, L49: Input argument / value assigned might be unused.
== sample_patches_for_experiment.m ==
  L79: For array or cell array, performance can be improved using logical indexing instead of 'find'.
== save_current_level.m ==
  L35: To avoid conflicts with functions on the path...
  L44: Variable might be used before it is defined.
== session_settings_all.m ==
  L54: To avoid conflicts with functions on the path...
== set_up_experiment.m / _diff_bg / _texture_exponent ==
  Global variables are inefficient...
== set_up_experiment_search.m ==
  L103: Add a semicolon after the statement to hide the output (in a function). [deliberate, commented]
== transform_camouflage_stimuli.m ==
  L37: To avoid conflicts with functions on the path...
== +main/check_fixation_cross.m ==
  L24, L27, L28: unused/changed-but-unused (B3.25) — L69: fixed — L88: fixed (semicolon)
== +main/configure_eyetracker.m ==
  L22: fixed
== +main/display_level_start.m ==
  L31, L32: fixed
== +main/give_feedback.m ==
  L30-32: alternative, T4.2, left alone
== +main/stimulus_interval.m ==
  L61: B3.16, left alone
```

None of these lines involve `save`/`load` string literals, function/file names, config struct field paths, or anything else outside this tranche's Stage 2 mandate; every message not listed as "fixed"/"left alone" above (the `checkcode` conflicts-with-path-functions and global-variable warnings) falls outside the four whitelisted patterns and was not acted on.

**Golden-harness replay: matched, all 57 fields**, including `gamma_correct` and `generate_target_present_matrix`/`generate_target_present_matrix_fixed` — both entry points needed no pattern-2/3/4 edit (already clean: semicolons present throughout, no `find`, no growth, no dead locals). Verbatim: `golden_harness: replay matched all 57 fields`.

**Bug found: B3.25** (new, 🟡 — `check_fixation_cross.m`'s dummy-mode branch has no observable effect; see 0.4). Not fixed, per Stage 2 rules. No optimization or structural opportunity was acted on.

**Baseline used for verification.** HEAD, working tree clean at this step's start (confirmed by `git status`). `check_stage1` with an empty rename map correctly returns `false` for the 3 edited files (a real AST change, expected — Stage 2 diffs are not empty); the diff for each was read line by line and confirmed to contain only the patterns above, with nothing else changed.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.4 — <code>+general/</code> (tranches 0.1.8, 0.1.9)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: HEAD, working tree clean under `+general/` at this step's start (unrelated in-progress edits elsewhere in the repo, under other 0.2.x tranches, were left untouched and excluded from this tranche's `git add`). Scope: all 32 in-scope `+general/` files (`git ls-files '+general/*.m' | grep -v '/_'`) — `Contents.m`, the 30 scripts, and `compute_nll_edge_model`, the package's only function (per 0.2.0's log entry).

**Pattern 1 — missing suppressing semicolons: 19 candidate sites found across 12 files, all judged deliberate, none fixed.** This scope is almost entirely scripts meant to be run cell-by-cell rather than end-to-end, and every hit is one of two idioms already seen elsewhere in this repo (e.g. B2.21's own header, `set_up_experiment_search.m:103` in 0.2.3): a loop-progress echo (the loop index or the current item, unsuppressed, read again later in the same iteration or not at all) or a final/intermediate diagnostic value left unsuppressed for the person running the script to inspect. Each site now carries an inline `% deliberate: ...` comment so a later pass doesn't "fix" it. Comments are invisible to `canon`, so this produces no AST change (`check_stage1` with an empty rename map returns `true` for all 32 files, confirmed below).

- Progress echoes (loop index/current item, read again inside the same iteration): `camo_ability_vs_samples.m:25` (`sample_size`), `check_camo_texture.m:31` (`i_tex`), `compute_avg_acc_for_texture.m:46` (`subj_name`), `compute_edge_powers_pink_noise.m:62` (`seed`), `compute_edge_props_pink_noise.m:32` (`seed`), `compute_edge_props_exp_eq.m:68`, `compute_edge_props_exp_eq_sum.m:70`, `compute_edge_props_exp_pca.m:77`, `compute_edge_props_exp_pca_all.m:68`, `compute_edge_props_exp_rescaled.m:80` (all `exp_path`, identical shape across these 5 sibling files), `fit_edge_model_with_exps.m:336` (`this_texture`), `fit_edge_model_with_exps.m:375` (`i_texture_display`).
- Diagnostic/result displays (printed for interactive inspection, not read again, or read again only as an accumulator): `compute_noise_colour.m:99,154` (`alphas = [alphas; alpha]`, two cells of the same script), `compute_texture_autocorrelation.m:63` (`corr_lengths = [corr_lengths; corr_length]`), `fit_hyperexp_dist.m:26` (`initial_lambda(2)`, a sanity check before the fit), `fit_hyperexp_dist.m:28` (`lambda` — the script's documented output, "left in the workspace" per its own header), `compute_edge_props_exp_eq.m:149`, `compute_edge_props_exp_eq_sum.m:154`, `compute_edge_props_exp_pca.m:161`, `compute_edge_props_exp_pca_all.m:150`, `compute_edge_props_exp_rescaled.m:164` (all `feature_name = field_names{3}`, same 5-sibling family), `fit_edge_model_with_exps.m:280,287` (two differently-defined `var_exp` diagnostics sharing one variable name — the first is overwritten by the second before ever being read back, but both are printed to the console for the user, so neither is "unused" in the sense this pattern targets; noted as a naming collision, not fixed, since renaming one is a Stage 3 call).

**Three additional candidates considered and explicitly left untouched, distinct from the above:**

- `plot_shape_exponent_exps.m:20` (`correct = nan()`) — the file's own header already documents this script as an unfinished stub ("never reads `correct`"); this print is part of that already-recorded state, not a fresh finding, so left exactly as found.
- `shuffle_unshuffle_exp.m:42` (`i_stim = i_stim+1`) — this is **B2.21** itself (the missing semicolon is what makes the mis-incremented loop counter visible on the console); suppressing it would hide the bug's symptom without fixing it, so left alone pending Stage 4.
- Four bare unsuppressed prints inside `parfor` bodies — `video_demo.m:36,43` (`i_sample`, `stim_energy(i_sample,:)`), `compute_edge_powers_camo.m:64` (`seed`), `compute_edge_powers_camo_large.m:67` (`seed`), `compute_edge_group_measures.m:56` (`[i_session i_level i_trial]`) — `checkcode` itself does not flag any of these (confirmed: it flags the ordinary broadcast-variable warning inside the same `compute_edge_group_measures.m` `parfor` at `:51`, so it is reading inside the loop body, just not for this message), consistent with per-worker console output being unreliable/order-dependent under a real parallel pool. `video_demo.m`'s two sites are additionally unreachable today (the script errors on its first `lib.stimulus` call per **B2.20**). Left alone rather than guessed at.

**Pattern 2 — `find(...)` that could be logical indexing: none found.** One `find` call in scope, `compute_nat_img_eff_coding_bins.m:429`, `bin_idx = find(Na>cdf_array(i_cdf), 1)` — excluded by the rule's own carve-out: `bin_idx` indexes two other arrays (`ea`, `Na`) on the next two lines, not a logical-indexing target.

**Pattern 3 — unpreallocated growth (`x(end+1)`/`x{end+1}`): none found.** `grep -nE '\(end\s*\+\s*1\)|\{end\s*\+\s*1\}'` across all 32 files, zero hits. `checkcode`'s `AGROW`/`SAGROW` warnings (variable changes size every iteration) fired in 8 files — `compute_edge_powers_pink_noise.m:67`, `compute_edge_props_exp_pca.m:63,65,67`, `compute_edge_props_exp_rescaled.m:66,68,70`, `compute_edge_props_pink_noise.m:48,63`, `compute_nat_img_eff_coding_bins.m:270,272,274,277,279,281`, `compute_texture_autocorrelation.m:63`, `plot_contour_props.m:227,228,230,231` — but every one is indexed assignment (`arr(i, :) = ...`) or concatenation (`x = [x; ...]`) without preallocation, not the `end+1` syntax this pattern targets. These are the same shape as the already-recorded **O3.2** (unpreallocated growth by concatenation, `+general/compute_edge_powers_camo.m:39`/`compute_noise_colour.m:99,154` among its cited examples); the new locations found here extend O3.2's already-acknowledged "~40 instances across ~20 files" rough count rather than needing a new id, so none was filed.

**Pattern 4 — unused assignments `checkcode` flags: 1 hit, considered, left alone.** `fit_edge_model_with_exps.m:280` (`NASGU`, "Value assigned to variable might be unused") — this is the same `var_exp`-name-collision site discussed under pattern 1: the value is not dead, it is printed to the console (a real use, just one `checkcode`'s static analysis can't see), and it is overwritten by a second, unrelated diagnostic of the same name three lines below. Not a provably-unused assignment safe to delete; left as found.

**Golden-harness replay: matched, all 57 fields**, including `compute_nll_edge_model`/`_pc`/`_d`/`_resp`/`_optimal`/`_out_of_range` — `compute_nll_edge_model` needed no pattern-1/2/3/4 edit itself (already clean; none of the 14 edited files is the golden-covered one). Verbatim: `golden_harness: replay matched all 57 fields`.

**`check_stage1`, empty rename map, all 32 in-scope files: all `true`.** Every edit this tranche made was a comment-only annotation (no semicolon added, no line deleted, no logical-indexing rewrite, no preallocation) — comments are stripped by `canon`, so the canonical AST is unchanged and the check correctly reports no diff, unlike 0.2.3 (which did make real AST edits and correctly saw `false`). Verbatim (32 lines, `ALL_OK: 1`):

```
+general/Contents.m: 1
+general/analyze_search_exps.m: 1
+general/analyze_shape_exps.m: 1
+general/analyze_shuffled_exp.m: 1
+general/camo_ability_vs_samples.m: 1
+general/check_camo_texture.m: 1
+general/compare_edge_energy_defs.m: 1
+general/compute_avg_acc_for_texture.m: 1
+general/compute_edge_group_measures.m: 1
+general/compute_edge_powers_camo.m: 1
+general/compute_edge_powers_camo_large.m: 1
+general/compute_edge_powers_pink_noise.m: 1
+general/compute_edge_props_exp_eq.m: 1
+general/compute_edge_props_exp_eq_sum.m: 1
+general/compute_edge_props_exp_pca.m: 1
+general/compute_edge_props_exp_pca_all.m: 1
+general/compute_edge_props_exp_rescaled.m: 1
+general/compute_edge_props_pink_noise.m: 1
+general/compute_nat_img_eff_coding_bins.m: 1
+general/compute_nll_edge_model.m: 1
+general/compute_noise_colour.m: 1
+general/compute_texture_autocorrelation.m: 1
+general/fit_csf.m: 1
+general/fit_edge_model_with_exps.m: 1
+general/fit_hyperexp_dist.m: 1
+general/flip_hard_easy.m: 1
+general/pick_edge_power_bins.m: 1
+general/plot_contour_props.m: 1
+general/plot_shape_exponent_exps.m: 1
+general/rand_boundary.m: 1
+general/shuffle_unshuffle_exp.m: 1
+general/video_demo.m: 1
ALL_OK: 1
```

**Bugs found: none new** — a documented negative. Every candidate that looked bug-shaped on first read (the `var_exp` name collision, the `plot_shape_exponent_exps.m` stub, `shuffle_unshuffle_exp.m`'s loop counter) turned out to already be covered by this file's own header note or by an existing id (B2.21). No optimization was made; the growth sites found under pattern 3 extend O3.2's existing scope rather than needing a new id. No structural opportunity was acted on.

**Baseline used for verification.** HEAD, working tree clean under `+general/` at this step's start (confirmed by `git status` — other files elsewhere in the repo were dirty from a concurrent, unrelated tranche and were neither read for this decision nor included in this tranche's commit). `check_stage1` with an empty rename map correctly returns `true` for all 32 files (a real, expected result — this tranche made no AST-visible change anywhere in scope).

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0.2.5 — <code>+vis/</code>, <code>+tests/</code>, <code>+tinker/</code>, root (tranches 0.1.10–0.1.12)</h5></summary>

<div style="margin-left:1.5em">

MATLAB R2024b Update 6. Baseline: HEAD for all 28 in-scope files (`+vis/` 8, `+tests/` 2, `+tinker/` 13, root 5) — working tree was clean under all four at this step's start; other files dirty elsewhere in the repo belonged to the four sibling 0.2.x tranches running concurrently and were neither read nor touched here. Scanned via `checkcode(-id)` over the full 28-file set plus a repo-wide `grep` for `find(` and `end+1`/`{end+1}` across the same set, then each hit read in context.

**Pattern 1 — missing suppressing semicolons: 9 candidate sites found, all judged deliberate, none suppressed except one.** `+vis/plot_edge_strength_dists.m:133` (`az`, inside the GIF-frame loop) is the one exception: unlike every other hit below, it is not documented anywhere as intentional and reads as leftover debug noise from building the rotating-scatter GIF, so it now carries a suppressing `;` and an inline comment. Every other site is a progress echo or a final-result display, each now carrying an inline `% deliberate: ...` comment (comments are invisible to `canon`, so `check_stage1` with an empty rename map still returns `true` for these files): `+tests/block_jumping.m:60` (`[i_trial i_block]`, progress through the nested trial/block loop — the file's other unsuppressed line, `:91`, is already documented in its own header as "prints the fraction... out of block order," so left alone); `+tinker/pink_noise.m:68,181,205,336` (loop-progress echoes — `freq_u`/`i_ensemble`/`i_ensemble`/`[row, col]` — three paired with a live `drawnow` or `surf` plot) and `:400` (a final real-vs-imaginary variance comparison, printed at the end of a cell, the point of that cell); `+tinker/pink_noise_stimuli_autocorrelations.m:79` (`seed`, same progress-echo shape, inside the cell **B3.21** already records as referencing undefined variables — left alone, matching the sibling files' treatment of code that's moot until that bug is fixed); `+tinker/whitening_tinker.m:165` (a final `[sum(curve) sum(curve.^2)]` result display). `scratch.m:122-123`'s unsuppressed 3-output assignment was already flagged by `checkcode` (`ASGLU` ×2) but is already covered by its own preceding comment ("No semicolon: this cell exists to print...") from tranche 0.1.12 — read, confirmed still accurate, left untouched.

**Pattern 2 — `find(...)` that could be logical indexing: none found.** One `find` call in the whole 28-file scope, `scratch.m:127` (`hit_idx = find(ExpSettings.bTargetPresent & SubjectExpFile.response)`) — excluded by the rule's own carve-out: `hit_idx` is passed to `ind2sub` (needs actual indices, not a logical mask) and `length(hit_idx)` is used as a scalar bound in three places below it (`:129,132,141`).

**Pattern 3 — unpreallocated growth: 2 hits, both fixed.** `+vis/plot_psychometrics_vs_angle.m:40` and `+vis/plot_psychometrics_vs_duration.m:41` each grow `thresholds(i_ppd)`/`thresholds(i_dur)` by loop-counter index inside a `for` whose bound (`numel(ppd_values)`/`numel(dur_values)`) is a literal known before the loop starts — no RNG draw is involved in that size, and the loop fills every index in order, so each now carries a `nan(1, numel(...))` preallocation line immediately before the loop, verified safe by reading (both files already error on their first `analysis.computeThresholdInBin` call per the files' own documented B2-level bug, so no golden entry point exists to replay against; `checkcode`'s `SAGROW` warning on both lines is gone after the edit). No `end+1`/`{end+1}` growth anywhere in the 28-file scope (`grep` returned zero hits after excluding the pattern-2 `find`).

**Pattern 4 — unused assignments `checkcode` flags: 4 real hits in one file, deleted; 2 more considered and left alone.** `+vis/show_patches_one_by_one.m` had `bSave`/`imgDir` (set in its `nargin==1` defaulting block but not among the function's actual parameters, and never read anywhere in the file) and `target`/`envelope`/`targetSize` (computed from real inputs but, after the file's one live use of `targetSize` was replaced by a hardcoded `513` at some earlier point, never read again either — `target` cascaded into the same category once `envelope`/`targetSize` were removed and `checkcode` re-run confirmed it). All five deleted; `checkcode` on the result is clean. Two further `NASGU` hits were considered and explicitly **not** deleted, both in `+tinker/` cell-scripts: `whitening_tinker.m:46` (`x_whitened`, unused within its own cell but reassigned and plotted in a later cell — read the whole file before ruling this out, since deleting it would also have cascaded into `x_pink_noise`/`x_white_noise` upstream) and `pink_noise_stimuli_autocorrelations.m:80` (`corr_this_seed`, assigned then overwritten without being read — but this sits inside the same already-broken cell **B3.21** records, where `nansum(terms(20:end))` uses a `terms` that is itself undefined; this looks like it should have fed the `nansum` call rather than a genuine tidy-up target, so it is left as further detail on B3.21 rather than either deleted or filed as a new bug). Both exploratory `+tinker/` cells follow the same "kept for interactive inspection, not for later code" reasoning that pattern 1 already applies to missing semicolons in this package — `checkcode`'s static unused-variable analysis can't see that reasoning, so it flags cases the skill's own conservative-`+tinker/` guidance is written for.

**Golden-harness replay: matched, all 57 fields**, including the five `+tinker/` entry points this tranche is golden-checked against (`tinker.pink_noise_dist` — both its 1-D and 2-D fields — `tinker.pink_noise_line_dist`, `tinker.pink_noise_line`, `tinker.pink_noise_square_manual`, `tinker.spatial_pattern`); none of the five needed a pattern-1/2/3/4 edit, so the match confirms no other tranche's concurrent work touched them either. Verbatim: `golden_harness: replay matched all 57 fields`.

**`check_stage1`, empty rename map, all 6 edited files:** `+tests/block_jumping.m` and `+tinker/pink_noise.m` both `true` (comment-only edits, invisible to `canon`); the other four correctly return `false`, each confirmed by inspecting `canon`'s printed diff to be exactly the one whitelisted edit described above and nothing else — `+vis/plot_edge_strength_dists.m` (one `;` inserted), `+vis/plot_psychometrics_vs_angle.m` and `_duration.m` (one preallocation line inserted each), `+vis/show_patches_one_by_one.m` (five unused-assignment lines removed). The other 22 in-scope files were not edited at all, so their pattern-check result is a documented negative rather than a `check_stage1` run.

**Bugs found: none new.** `pink_noise_stimuli_autocorrelations.m:80-81`'s `corr_this_seed`/`terms` shape is additional detail on the already-recorded **B3.21**, not a new id — `terms` was already listed there as one of the four undefined names in this cell.

**Optimizations: one found, filed as O3.7, not made.** `+tinker/whitening_tinker.m:219` — `checkcode`'s `PFBNS` (broadcast-variable) warning on `mismatch_template_image` inside a `parfor`. Not one of Stage 2's four whitelisted patterns.

**Structural opportunities: none found.** **Commented-out code: none newly triaged** — this tranche edited files 0.1.10–0.1.12 already fully triaged (3.1.4); no file here was read for the first time.

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.3 · Stage 3 · Structure</h3></summary>

<div style="margin-left:1.5em">

One entry below per item done; section 0.3 is the live list. Commented-out code triaged in 3.1.4; the only verdict acted on so far is T6.8, discharged by S2.3 when the file holding it was collapsed away.

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S2.19 &mdash; snake_case retrofit of <code>+experiment/</code> (59 files, 5 commits)</h5></summary>

<div style="margin-left:1.5em">

**The open question, answered: retrofit, not grandfather.** The item was recorded with the grandfather-vs-retrofit choice still open and no tier consensus. It is settled in favour of the retrofit, on three grounds. First, the casing rule is the user's standing preference and is explicitly not a per-repo or per-directory judgement call — a camelCase majority does not earn an exemption. Second, grandfathering would have had to be permanent rather than temporary: the seam runs through function names that `+general/`, `+vis/` and the root all call, so "leave `+experiment/` alone" really means "keep a camel/snake seam down the middle of the repo forever". Third, it turned out cheaper than the plan feared, because the whole thing is mechanically checkable — `check_stage1` covers bare identifiers and, via R0's widened map, package-qualified call sites too — so the real risk sat in the frozen-name triage, not in the renaming.

**Baseline.** HEAD at each part's start; the working tree was clean throughout. The filename half compared against a copy of every tracked `.m` file taken before the first `git mv`, so each renamed file was checked against its own old path.

**Verification — verbatim checker output**, MATLAB R2024b Update 6.

Part 1 (filenames), run over **all 205 `.m` files** in the repo (in-scope, plus the 29 `_`-prefixed dead ones, plus `tools/`), excluding only the vendored `por_sim_tx_synth/` tree:

```
bijection OK (336 rows)

CHECK_STAGE1: 205 passed, 0 failed, 205 total
```

```
RESOLUTION SWEEP: 47 of 47 new names resolve
```

Parts 2-4 (in-file identifiers), each file against its own map:

```
CHECK_STAGE1: 59 passed, 0 failed, 59 total
ALL_OK: true
```

`golden_harness('replay', ...)` after every part: `golden_harness: replay matched all 32 fields`. The item was meant to be output-preserving and is. `checkcode` over the 59 files: **99 messages before, 99 after** — no lint introduced, none removed.

**Decision A — the four sweeps, again, for the filename half.**

1. **Package-qualified call sites.** R0's technique applied unchanged: the map was widened from 42 bare pairs to **336 rows** by adding, for each rename, every qualifier that occurs in the tree (`experiment.`, `experiment.analysis.`, `analysis.`, `experiment.main.`, `main.`, `experiment.main.testscripts.`, `testscripts.`). The regex was not loosened, and `assert_rename_bijection` passes on all 336. The whole 70-file, 388-line diff was then read line by line; every changed line is one old name replaced by its new one and nothing else. Three things only diff-reading caught, all handled: `golden.computeNegLogLikelihood` and `golden.fitPsychometric` in `tools/golden_harness.m` are **frozen golden-reference struct fields serialised into `tools/golden_ref.mat`**, so they were protected while the calls beside them were repointed (the same trap 0.1.1 hit with `golden.compute_pClipped`); `lib.gammaCorrect` resolves to nothing and is a *different* name from `experiment.gammaCorrect`, so it was left alone rather than swept along, preserving the evidence for B2.9 and S1.14; and `nm.analysis.fitPsychometric` likewise names a package that does not exist here.
2. **References outside `.m` files — 8 hits, all fixed.** `README.md` (quick-start block, call-graph diagram, psychometric-model paragraph, the "not done" list), `CLEANUP.md` (5 lines), and this plan document throughout. Two aligned ASCII blocks had to be re-laid-out by hand because longer names broke them: README's call-graph arrows, and `+experiment/Contents.m`'s description column. `.gitignore` and `CITATION.cff`: no hits. No `.mlx`, shell or batch file exists in the repo, and no data filename derives from a renamed function name. Left deliberately: `CLEANUP.md`'s `saveCurrentSession` and `subjectExperimentFile_alpha`, both files deleted before this plan began, and its two `lib.gammaCorrect` mentions.
3. **Dynamic references — a documented negative.** Grepping every old name as a quoted string across all `.m` files returns nothing. The only `exist` calls in `+experiment/` test `'bPlot'` and `'nBootIter'` (local variables, renamed together with their string literal in part 3) and a filename variable; there is no `feval`, `str2func`, `which` or `help` reference to a renamed function anywhere.
4. **Case-only renames — none.** All 42 new names insert at least one underscore, so the Windows temporary-name two-step was not needed. Git recorded all 42 as renames (`R`), not delete-plus-create.

**Decision B — 42, not 43.** The plan recorded 43 camelCase filenames in `+experiment/`; the measured number is **42**. This is not a missed file: a fresh census of every in-scope `.m` name finds zero camelCase afterwards. The recorded 43 was simply off by one, and section 2's number has been corrected rather than reconciled.

**Decision C — what keeps its camelCase, and why.** Four categories, none of them ours to move:

- **Zone-3 frozen `save`/`load` names:** `ExpSettings`, `SubjectExpFile`, `Stimulus`, `edgePowerBlockEdges` (in `set_up_experiment.m` it arrives from `load(..., 'edgePowerBlockEdges')`, so the *variable* name is frozen too), and `trialInfo` in `compute_bootstrapped_threshold.m`, injected by a bare `load` — 0.1.8's decision B, and the one thing this item got wrong before catching it (Decision F).
- **Frozen struct-field names, in both of their forms:** dot-qualified accesses (`ExpSettings.nLevels`) and the string literals that create them (`struct('nLevels', n_levels, ...)`). The substitution protected every quoted occurrence of a mapped name, and a before/after diff of all single-quoted identifier-shaped literals across all 59 files confirms **not one literal changed**, except the two `exist('...','var')` pairs that were meant to. The resulting `'nLevels', n_levels` mismatch is exactly the one the skill sanctions and S3.10 closes.
- **External API names:** Psychtoolbox and EyeLink functions and option strings (`Screen`, `Eyelink`, `CenterRectOnPointd`, `'TickDir'`, `'FontSize'`, and so on), plus `textureAnalysis` and `prepareSurfaceData`.
- **The five TitleCase settings/data structs** — `ExpSettings`, `SubjectExpFile`, `SessionSettings`, `SessionData`, `SettingsOut`, and the parameter-only `ImgStats`, `BlockStimuli`, `Stimulus`. Three of the eight are zone-3 frozen and cannot move at all, so converting the rest would have split the family rather than unified it; `SessionSettings` to `session_settings` would additionally have **shadowed the package function `experiment.session_settings`** inside `load_stimuli_camouflage.m`, trading a casing problem for a resolution problem; and all of them are zone-2 cross-file argument names, whose identity is S1.9's to settle rather than this item's. The cost of the carve-out was measured before it was taken: 20 of the 408 camelCase assignment-target occurrences, under 5%.

**Decision D — the typo that existed only to avoid a collision is gone.** 0.1.7 kept the local `responseInvervalMs` misspelled in all five `session_settings*` files, because correcting it to `responseIntervalMs` would have made it identical to the frozen field-name string literal in the same file. Snake-casing the local to `response_interval_ms` dissolves that collision, so the typo went with it; the in-file note that recorded the constraint now records its removal. The other frozen misspelling, the field `.moniter_brightness`, is untouched and still S3.10's.

**Decision E — `edgePowers` could not become `edge_powers`.** In `generate_camouflage_stimuli.m` the per-stimulus output `edgePowers` sits beside the frozen lookup table `edge_powers` loaded from disk, so the obvious casing target was already occupied. One name per concept: the per-stimulus quantity became `stim_edge_powers` in all six files that carry it, which also makes the two readable apart. A scripted collision guard ran the same check on every candidate name in every file; this was its only hit.

**Decision F — one self-inflicted regression, caught and fixed before it could matter.** Part 3 snake_cased `trialInfo` in `compute_bootstrapped_threshold.m`, missing that the name is injected into the workspace by the bare `load(file_path)` two lines above it. `check_stage1` cannot see this class of error at all: the reverse-rename restores the name, so a broken file still passes. It was caught by a systematic re-read of every bare `load` in the tranche, reverted in commit 3a, and the file now carries an in-line note saying why that one name stays camelCase. **The general lesson, worth the next tranche's attention: `check_stage1` is blind to a wrongly-renamed name that the map itself reverses — bare `load`, `exist('x','var')`, and struct-field string literals each need their own sweep, not the checker.**

**Line endings, and a second self-inflicted slip.** The `+experiment/` root files are CRLF while `+main`/`+analysis` are LF. Eight root files briefly acquired bare-LF line breaks from a reflow, leaving them mixed; caught by a per-file CRLF/LF count and normalised back before committing. 0.1.9's decision B, rediscovered the hard way.

**Formatting carried by the retrofit.** The renames pushed 24 lines past 100 characters; 22 were reflowed with a 4-space hanging-indent `...`, and three MATLAB H1 summary lines that cannot be split were shortened instead. Header `Inputs`/`Output` blocks were re-aligned wherever a longer name broke the dash column (26 files), and `+experiment/Contents.m`'s description column was re-laid-out. `compute_bootstrapped_threshold.m`'s one tab and its column-aligned assignments were fixed in passing, per 0.1.12's no-aligned-assignments decision. **Line-length exceptions: 9 in scope**, unchanged in kind from earlier tranches — `display_level_start.m:41` (169 characters, an unbreakable `DrawFormattedText` string literal, inherited from 0.1.5) and eight commented-out dead lines (`compute_threshold_edge_response.m:132`, `compute_threshold_texture_exponent.m:165`, `run_camouflage_experiment_search.m:75`, `generate_camouflage_stimuli.m:107`, `generate_camouflage_stimuli_shape_exponent.m:71`, `load_current_session.m:70`, `set_up_experiment.m:84` and `:119`).

**Commented-out code: nothing triaged, nothing deleted.** Every block in these files already carries a verdict from 0.1.5/0.1.6/0.1.7 (T4.1-T6.9 in 3.1.4) and none was acted on here — acting on them is S1.16's job. Identifiers *inside* commented-out code were renamed alongside their live counterparts (0.1.11's precedent), which is invisible to `canon` and keeps the dead lines naming live identifiers correctly; `displayMask` and `pcBoot_sds`, which exist only inside dead blocks, were snake_cased for local consistency and are recorded here rather than mapped, since they have no live occurrence to map.

**Bugs found: none new** — a documented negative. Nothing in the 2,891 lines turned up that was not already recorded. B2.9's `analysis.compute_template_response_sigma` had its tail renamed along with the function it (fails to) name, so the reference is still broken in exactly the way B2.9 describes. No optimization and no structural opportunity was acted on. One new structural item was **recorded, not done**: **S2.20**, the same retrofit for the 49 camelCase identifiers still in `+vis/`, `+tests/`, `+general/` and `+lib/`, which this item's closing census made visible.

**Commits: four, plus a fix.** Split on tranche boundaries so each is separately reviewable and separately verified — part 1 filenames (70 files), part 2 `+experiment/+main/` (11 files, 123 renames), part 3 `+experiment/+analysis/` (12 files, 103 renames), part 3a the `trialInfo` revert, part 4 `+experiment/` root (26 files, 308 renames) together with the plan update.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S3.5 &mdash; the smoke test (<code>tools/smoke_test.m</code>, 1 new file)</h5></summary>

<div style="margin-left:1.5em">

**Where it lives, and why there rather than `+tests/`.** `tools/smoke_test.m`, beside `canon`, `check_stage1` and `golden_harness`, run the same way they are:

```
matlab -batch "addpath('tools'); smoke_test"
```

`+tests/` was the other candidate and was rejected: its two members are ad-hoc, un-asserted eyeball scripts that both error on the first call (B2.24, B2.25), it is itself part of the file set the smoke test sweeps, and a `tests.smoke_test` would only be reachable through the very package resolution it exists to check. This is cleanup tooling, so it sits with the cleanup tooling. `+tests/Contents.m` previously pointed forward to "the plan to add a real, assertion-based smoke test"; that line now points at the file.

**What it is for, next to the golden harness.** The golden harness answers *did the numbers move*, and cannot answer anything without `tools/golden_ref.mat`. The smoke test answers *does the code resolve, parse and run at all*, from a clean checkout with no reference data. Coverage is deliberately disjoint where it can be: the call sweep leaves out the entry points the harness already pins, except where one is needed as an input or where 0.2.0 later promoted a swept function to golden coverage too.

**The four checks.**

1. **Seed → edge power.** One fixed seed (35096) through `lib.stimulus` at 128 px with a 32 px target, then `lib.edge`. Eleven assertions: shape, finiteness, `theta_grid` spanning (-π, π], `edge_power` a finite positive scalar, and `edge_power == mean(edge_vector.^2)` — the relation `+lib/edge.m`'s own header states, worth pinning because outputs 3 and 4 of that same function already silently stopped meaning what a caller thought (B1.5). Two determinism assertions bracket it in both directions: the same seed under a *different* ambient RNG state must give a bit-identical stimulus, and a different seed must give a different one. The second is what catches an argument that is quietly ignored, the shape of B1.3.
2. **Round trips.** `lib.whiten` must invert `lib.create_pink_noise_square` at exponent 1 (they multiply and divide by the same 1/f filter), to 1e-9 relative. And `lib.stimulus` forwards its whole `varargin` to `lib.target_mask` at `+lib/stimulus.m:251`, so its four mask outputs must be `isequal` to an independent `lib.target_mask` call with the same arguments — a destructure shifted by one slot, which is what B2.4 records, shows up here as a mismatch instead of as silence.
3. **Minimal-argument call sweep.** 33 curated functions from `+lib/` and `+experiment/`, called with trivial arguments and asserted only to run and return something finite of the documented size. Curation criteria: pure, cheap, no plotting, no file I/O, no `rng('shuffle')`. This is where a signature that no longer accepts what its own header advertises shows up — B2.3 and B2.20 are both "called positionally against a name-value-only signature".
4. **Package-resolution sweep.** Two halves. (a) All **162** in-scope files with a callable name — the plan's 164, minus the two under `+experiment/+main/testscripts/` — resolve under their package-qualified name to their own file, with a NOTE for any that is shadowed but still wins. (b) All **98** distinct package-qualified references written in in-scope source resolve to something. Half (b) is the one that would have caught B2.9, and it does: all fifteen of B2.9's dead references are found by it and accounted for.

**Both known-broken lists are two-way, on purpose.** Checks 3 and 4 each carry a list of things expected to be broken, every entry citing its bug id. An unlisted breakage fails the check; a listed one that has *started working* also fails it, with a message naming the bug to tick and the entry to drop. A one-way list rots silently the first time someone fixes a bug, which is exactly when you want to be told. Today those lists hold `lib.mismatch_template` and `lib.embed_image_in_center` (check 3) and B2.9's fifteen references (check 4).

**The `which_sweep.m` question from step 0.1.0, answered.** That entry deferred a `which_sweep.m` to "S3.5(d)". The file exists nowhere — not in this repo, not in the skill's `tools/`, not in history — so it was a scratch script that was never kept. Check 4 is written fresh and supersedes the deferral; nothing is owed.

**Verification. A green run proves nothing on its own, so the test was broken deliberately, five ways, one per assertion class**, each reverted afterwards (`git checkout --`; the tree was clean throughout and is clean again):

| injected fault | expected to fire | fired |
|---|---|---|
| `+lib/edge.m`: `mean(v.^2)` → `mean(abs(v))` | check 1's documented-relation assertion | `FAIL edge_power == mean(edge_vector.^2)` |
| `+lib/whiten.m`: filter `1/z` → `1/z^1.05` | check 2's inverse round trip | `FAIL whiten inverts create_pink_noise_square` |
| `+lib/deg2rad.m`: a second required argument | check 3's call sweep | `FAIL lib.deg2rad errored: Not enough input arguments` (and `lib.gabor_2d`, which calls it) |
| `+vis/show_image.m`: a call to `lib.no_such_function` | check 4(b), unlisted dead reference | `FAIL reference lib.no_such_function resolves to nothing, and is not a known bug` |
| a synthetic `lib.definitely_not_here` in the sweep's own name list | check 4(a) | `FAIL lib.definitely_not_here does not resolve` |
| `lib.whiten` added to the known-dead list | the two-way rule's second direction | `FAIL reference lib.whiten now resolves -- ... looks fixed; tick it` |

**Verbatim output on the clean tree**, MATLAB R2024b Update 6:

```
--- summary ---
  passed  50
  failed  0
  xfail   2  (broken as a recorded bug says it should be)
  skipped 0
smoke_test: PASS
```

with, inside check 1, `edge power at seed 35096: 1808.24`. `checkcode('tools/smoke_test.m')`: no messages. `canon` parses it. `golden_harness('replay', ...)`: `replay matched all 32 fields` — expected, since this item adds a file and changes no repo code.

**What it caught on its first run: one new bug, B3.24.** `lib.embed_image_in_center`'s default path (`bAdditive` unset, so 0) reads `target_window`, which the defaults block leaves unassigned because its body is a commented-out warning; the two-argument call the header advertises therefore errors. Latent — the only live caller passes `bAdditive = 1`. Recorded in 0.4, **not fixed**, and carried in check 3 as an expected failure citing B3.24.

**Three findings recorded here rather than as items, with the reason.**

- **`+experiment/+main/testscripts/` is not addressable.** MATLAB does not put a non-package subfolder of a package folder on the path, so `run_single_trial_test.m` and `test_experiment_struct.m` cannot be called under any qualified name; they can only be run by `cd`-ing to them or pressing Run in the editor. That is a layout fact, not a defect in the code, and moving them is S3.6's kind of work, so it is printed as a NOTE by check 4 and left here rather than filed.
- **162, not 164.** The in-scope count the sweep derives from the filesystem is the plan's 164 minus exactly those two files, which is the expected agreement, not a discrepancy.
- **No optimization and no structural opportunity was acted on**, and none new was found — the item adds a file and reads others.

**A limitation worth stating.** Check 4(b) scans text, not the AST: it drops whole-line comments and then requires a `(` or a leading `@`, which is what keeps a `See also` line or a commented-out call from counting. An inline comment containing something that looks like a call would be a false positive, and a reference built at runtime by `str2func` is invisible to it. Neither occurs today — the 98 references it finds include all fifteen of B2.9's, which is the evidence that the scan is not missing the class of thing it is for.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S1.12 &mdash; <code>arguments</code> blocks (4 files converted, 5 deferred to S2.21)</h5></summary>

<div style="margin-left:1.5em">

**The item's premise was wrong, and the first job was re-measuring it.** It was recorded as "add `arguments` blocks repo-wide; 11 files use `inputParser`". Two of the eleven — `+general/video_demo.m` and `+tests/block_jumping.m` — contain no parser at all; they contain a *header note* written by Stage 1 tranches 0.1.9 and 0.1.10 explaining that their positional calls to `lib.stimulus` fail because that function is `inputParser`-driven. The grep that produced 11 counted that prose. The original survey's 9 was correct, and section 2 now says so.

**What actually blocks the item: `KeepUnmatched` is load-bearing, and `arguments` has no equivalent.** All nine parsers set `parser.KeepUnmatched = true`, and three live `varargin{:}` pass-through chains depend on it:

| forwarding call | sink | names the sink does not declare |
|---|---|---|
| `+lib/stimulus.m:251` `lib.target_mask(varargin{:})` | `target_mask` | `texture`, `texture_bg`, `seed`, `ml_b`, `cont_b`, `ml_t`, `cont_t`, `target_or` |
| `+lib/steerable_grad.m:100` `lib.local_sd(stim, kernel_size, varargin{:})` | `local_sd` | `kernel_size`, `filter`, `normalize` |
| `+lib/edge_props_stim.m:203,205` `lib.steerable_grad(..., varargin{:})` | `steerable_grad` | `stim_type`, `otf_ppd`, `pca_coeffs`, `grad_*_bins`, `edge_pixels`, `target_normal`, … |

MATLAB has no `KeepUnmatched` for `arguments` blocks and forbids a trailing `varargin` after a name-value block, so a sink cannot be converted without breaking its callers — and the first row is the live, golden-checked stimulus path. A *source* is no easier: converting it deletes the `varargin` the forward is built from, and rebuilding it with `namedargs2cell(options)` would forward the source's own defaults too, so `target_mask` would start receiving `'target_radius', 0` (stimulus's default) instead of falling back to its own 64. Declaring all thirteen options default-less and hand-defaulting them in the body would preserve that, at the cost of code plainly worse than the `inputParser` it replaced.

So the five coupled files were left alone and the real question — whether the flat one-bag-of-pairs pass-through design stays — is recorded as **S2.21**, to be settled with S1.9 and B2.4. That is a design call, and turning it into a change here was not this item's to make.

**Converted: the four files with no forwarding on either side.** `+lib/detect_edge_pixels.m`, `edge.m`, `edge_measures.m`, `edge_vector_ideal.m`. Argument order, names, and defaults are unchanged; the `parser.Results.x` reads became `options.x`.

**Three translation decisions.**

1. **`@isscalar` became a `(1, 1)` size constraint** (`detect_edge_pixels`'s `thresh`). Equivalent: `isscalar` is true exactly when the size is 1×1, and a 1×1 input triggers no scalar expansion.
2. **Two validators have no builtin equivalent, so each file got a local validator function.** `mask`'s `@(x) isscalar(x) || islogical(x)` became `must_be_scalar_or_logical`; an arguments block cannot take an anonymous handle, so a named local function is the only faithful form. `mask_edge`'s `@islogical` became `must_be_logical_or_empty`, and the difference matters: **`inputParser` does not validate defaults, but an `arguments` block does**, and `mask_edge`'s own default is `[]`, a double. A literal `mustBeA(…, 'logical')` would therefore have made `lib.edge(stim, 'mask', 32)` — the golden-checked call — error immediately. Admitting empty is the minimum widening that keeps the default legal; the only value newly accepted is an explicit `'mask_edge', []`, which is what the default already was, and no caller passes it. The reason is written into the validator's own comment in both files.
3. **`edge_measures`'s `bdry_strip` default needed a local function**, `default_bdry_strip`, because an arguments-block default must be a single expression and this one is the fourth output of `lib.target_mask()`. Side effect, recorded rather than hidden: the default is now built only on calls that do not supply one, instead of on every call. No caller supplies one, so nothing changes today, and `lib.target_mask()` with its own defaults takes the circular branch and makes no RNG draws — checked, because a lazily-skipped default that drew from the stream would have shifted every downstream result. The header sentence that said "computed on every call" was corrected.

**Call-site sweep — how it was made exhaustive.** Every one of the four names was grepped across the whole repo including the 29 `_`-prefixed dead files, `tools/`, and non-`.m` files, and every hit read. `lib.edge` is called at `edge_power_demo.m:37,50,64`, `compute_edge_group_measures.m:52`, `generate_camouflage_stimuli_shape_exponent.m:76`, `golden_harness.m:251`, `smoke_test.m:122,123`; `lib.edge_vector_ideal` at `generate_camouflage_stimuli_diff_bg.m:80`, three `compute_edge_powers_*.m`, `golden_harness.m:258`; `lib.edge_measures` at `generate_camouflage_stimuli_texture_exponent.m:83`, `scratch.m:117,158` and eight `_`-prefixed files; `lib.detect_edge_pixels` at `compute_edge_props_pink_noise.m:38,53` and `scratch.m:65`. **Every name-value used is a declared one, spelled in full and in the declared case**, so neither `inputParser`'s partial matching nor its case-insensitivity was being relied on anywhere — and nothing in the repo forwards a `varargin` into any of the four. Two pre-existing breakages are unchanged in kind: `_compute_edges.m:131` passes `lib.edge_measures` a second positional argument and `_compute_edge_measures_ideal.m` calls the long-gone `lib.edge_vector`; both errored before and error now, with a different message.

**Verification**, MATLAB R2024b Update 6. `golden_harness('replay', …)`:

```
golden_harness: replay matched all 57 fields
```

`tools/smoke_test.m`:

```
--- summary ---
  passed  50
  failed  0
  xfail   2  (broken as a recorded bug says it should be)
  skipped 0
smoke_test: PASS
```

`checkcode` on the four files: no new messages — only the two pre-existing `nanmean` notices at `edge.m:137` and `edge_vector_ideal.m:133`, on lines this item did not touch.

Neither of those two reaches the logical-mask branch of `lib.edge`/`lib.edge_vector_ideal`, or `lib.edge_measures` at all, so a **17-value probe** covering every argument path of all four functions — both mask branches, each name-value alone, and the bare-default call — was run against the edited tree and against `HEAD` (the four files stashed), on the same seed. **All 17 values agree to ten significant figures.** That, not the harness, is the evidence for the branches the harness does not visit. `check_stage1` was not run and is expected to fail by design: signature changes are what Stage 3 is for.

**One finding, recorded rather than filed as a bug.** `tools/smoke_test.m:174` passes `'seed', 35096` to `lib.target_mask`, which has no `seed` parameter — it was commented out at `target_mask.m:54` — so `KeepUnmatched` silently swallows it. Harmless today (the assertion it supports compares two calls that both ignore it) and deliberate-looking, since it mirrors what `lib.stimulus` forwards, so no `B` id: it is noted in S2.21 instead, because it is one more thing that would start erroring the moment `target_mask` gets an `arguments` block. The wider version of the same worry is a **documented negative**: `KeepUnmatched = true` on all nine parsers means a misspelled name-value anywhere in `+lib/` is silently dropped, which is exactly B1.8's failure mode — but every call site of all nine was read, and apart from the three deliberate forwards and this one `'seed'`, no undeclared name is passed anywhere in the repo.

**Nothing else acted on.** No commented-out block was deleted or converted — `detect_edge_pixels.m`'s alternative-filter line moved with the default it annotates, into the arguments block, and is otherwise untouched (its verdict is 3.1.4's, and acting on it is S1.16's). No optimization, no bug fix, no other structural change. The tree also carried unrelated in-flight S1.14 work while this item ran; the commit names only this item's files.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S1.14 &mdash; one gamma-compression implementation (4 files, 1 commit)</h5></summary>

<div style="margin-left:1.5em">

**The item's premise was right about the math and wrong about the target.** All three spellings really are the same power law, confirmed by algebra rather than by eye:

- `experiment.gamma_correct(x, γ, b)` = `round((2^b − 1)·x^(1/γ))`, input normalised to [0, 1].
- the anonymous `gamma_correction(x, bit, γ)` at `run_camouflage_experiment_search.m:36` = `(2^bit − 1)·(x/(2^bit − 1))^(1/γ)`, input in pixel values, no rounding.
- `vislab.lib.gamma_compress(x, γ)` = `(x·255^(γ−1))^(1/γ)`, which simplifies to `255·(x/255)^(1/γ)` — i.e. *identical* to the anonymous function at `bit = 8`, which is what `set_up_experiment_search.m:47` sets `monitorBit` to.

So the answer to "did the anon function actually match `gamma_correct`'s math?" is **yes as a transform, no as a function**: same `x^(1/γ)` compression, but a different input scale (pixel values vs. [0, 1]) and no quantisation. It is not the *inverse* operation, which the dispatch flagged as worth checking — all three compress.

**Why the consolidation did not go onto `vislab.lib.gamma_compress`.** Three reasons, in order of weight. (1) The shared function fixes its white level at 255 and never rounds, while every call site here is parameterised by bit depth and wants an integer pixel value — `+vis/show_patch_grid.m` asks for 14 bits. Expressing `round((2^b − 1)·x^(1/γ))` through it needs `round((2^b − 1)/255 · vislab.lib.gamma_compress(255·x, γ))`: two compensating rescalings by an unrelated constant, wrapped around a one-token power law. That is duplication-avoidance theatre, and it makes the code harder to read, not easier. (2) `vislab.lib.gamma_compress` has **zero live callers anywhere in the lab tree** — grepped across `vislab-common`, `texture-learning`, `texture-segmentation`, `IntClassNorm`, `gx2` and here, excluding the `Bill's old code*` ancestral trees; only `gamma_expand` is called, once, at `vislab.nat_stat_bayes.source_to_lms:69`. Nothing is diverging yet, so the urgency the 🔴 tier implies is about *this repo's* three copies, not about the lab-wide one. (3) Repointing would put the live Psychtoolbox experiment path behind a vislab-common dependency that `setup.m` only warns about when it is missing. The right cross-repo fix — an optional white-level argument on `vislab.lib.gamma_compress`, then a genuine one-line wrapper here — needs a commit in a sibling repo and a signature decision that is the user's, so it is re-filed as **S3.19** rather than forced through here.

**What changed.** Three copies to one, `experiment.gamma_correct`, whose math and signature were left exactly as they were.

- `+experiment/set_up_experiment_search.m:118` — `lib.gammaCorrect(stim, monitorGamma, monitorBit)` → `experiment.gamma_correct(...)`, same three arguments in the same order. The dangling name matched the surviving signature exactly, and `lib.stimulus`'s `ml_b`/`cont_b` are documented as fractions of the monitor maximum, so `stim` is already the normalised [0, 1] input `gamma_correct` wants. This file could not run at all before.
- `+experiment/+main/run_camouflage_experiment_search.m:36` — the inline formula replaced by an anonymous *binding* (not a reimplementation) that fixes this monitor's gamma and bit depth and scales pixel values into [0, 1]. Its four call sites each shrink from two lines to one.
- `+experiment/gamma_correct.m` — header rewritten; it also cited the item as "S3.14", which is not an id that exists.
- `tools/smoke_test.m` — `lib.gammaCorrect` dropped from `known_dead`, since it is no longer written anywhere. The sweep now reports 97 package-qualified references rather than 98, which is the expected arithmetic.

**One behaviour change, deliberate and disclosed.** `experiment.gamma_correct` rounds; the anonymous function did not. Of the run script's four sites, `:117` already wrapped the call in `round(...)` and is bit-identical; the other three (the window clear colour, the blank luminance sheet, the start screen) are now rounded where they were not. The difference is at most half a pixel value, and all three go straight into Psychtoolbox, which quantises a double texture to 8 bits regardless. Stated in that file's header too, so the next reader does not have to rediscover it.

**Verification.** No mechanical check applies — `check_stage1` fails by design here, since call sites moved. Instead:

- **Exhaustive call-site search, the claim and how it was made.** `gammaCorrect` grepped across every file type in the repo including the excluded `_`-prefixed dead set and the non-`.m` docs; the only hits left are prose. The power law itself grepped as `^(1/gamma…)` and `.^(1./…)` repo-wide: exactly **one** live occurrence remains, `gamma_correct.m:35`. `gamma_correct(` grepped repo-wide for callers before deciding whether to delete the file — five call sites (`load_current_session.m:81`, `load_stimuli_camouflage.m:91,106,119`, `show_patch_grid.m:37`), which is why it survives as a function rather than being inlined. The sibling repos and the archived root `+lib` (`retired_root_lib_backup.zip`, 69 files) were searched too: `gammaCorrect` never existed in either, which is the origin of B2.9's dead reference.
- **Golden harness, replay**, MATLAB R2024b: `golden_harness: replay matched all 57 fields` — including `gamma_correct: [10984 2125250 427351 0 64]`. Expected, since the function's math is untouched. Neither edited experiment file has a golden entry point (both are Psychtoolbox- or `exp_files/`-bound).
- **Smoke test:** `passed 50 / failed 0 / xfail 2 · smoke_test: PASS`, with `ok experiment.gamma_correct` and the reference sweep down to 97 as expected.
- **Line endings** re-checked per the 0.1.9 decision: all four files were 100% CRLF before and after.

**One new bug found and recorded, not fixed: B2.28** — `+vis/show_patch_grid.m:37` calls `experiment.gamma_correct` with four arguments. Git history explains it exactly: the function was written in 2016 as `(imgIn, gammaValue, bitDepthIn, bitDepthOut)` and commit `b38c8e7` dropped `bitDepthIn` in Nov 2021 without updating this caller. Nothing in this item changed any signature, so it is not a regression introduced here.

**B2.9 partially closed.** Its `lib.gammaCorrect` entry is resolved by this item and annotated as such in 0.4; the entry itself is kept, and the other 14 references stand. No optimization and no other structural change was made.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S2.3 &mdash; collapsing the experiment-variant families (15 files examined, 10 collapsed to 2, 1 commit)</h5></summary>

<div style="margin-left:1.5em">

**The item asked for three collapses; two were worth making and the third was not.** The three layers are a chain with fan-in 1 at every step — each `set_up_experiment_*` calls exactly one `session_settings_*`, which calls exactly one `generate_camouflage_stimuli_*` — so they could have been merged in any combination. They were read line by line and diffed against each other before anything was written, and the three layers turn out to be duplicated to very different degrees.

- **`set_up_experiment` (5 → 1).** Of ~220 body lines across the five, ~90 were the same save-and-subject-loop tail copied five times. What actually varies is six constants, which level description to build, and one `-v7.3`.
- **`session_settings` (5 → 1).** Of ~380 body lines, ~180 were boilerplate: the same eight display and timing constants, the same `p_target`, loader handle and position arrays, and the same twenty trailing struct fields, five times over. What varies is six lines per variant.
- **The five generators: left alone, five files.** This is the part of the item that was declined, and the reason is not squeamishness about size. Their bodies (58, 48, 35, 39, 33 lines) share about four lines each — the progress `fprintf` and the `seeds`/`stimuli`/`p_clipped` write-back. Everything that matters differs: where the boundary-ribbon mask comes from (`lib.target_mask`, `lib.circular_mask`, or `lib.stimulus`'s own return), whether the seed is chosen here or drawn inside `lib.stimulus`, the class of the `seeds` array (`double` vs `single`), the `lib.stimulus` argument set, how edge power is obtained (looked up in a table / `lib.edge_vector_ideal` / `lib.edge` / `lib.edge_vector`), the output arity (four outputs, or five for `_all`), and the loop nesting itself — `_all` has no level loop at all and `_shape_exponent` puts its `parfor` on levels where the others put it on trials. **That last one is decisive:** in four of the five variants the seed is drawn by `lib.stimulus` inside the `parfor`, so moving the `parfor` axis changes which worker draws which stimulus and therefore changes the stimuli. A unified generator could not have been behaviour-preserving without carrying the `parfor` axis as a parameter, at which point it is a switch statement wearing a trenchcoat. Recorded here as a closed decision, not a deferral.

**The design chosen, and the one it was chosen over.** `variant` is the **first** argument of both collapsed functions, one of `'edge_power'`, `'all'`, `'diff_bg'`, `'shape_exponent'`, `'texture_exponent'`, validated by `mustBeMember`. The alternative considered was making `variant` the *last* argument with `'edge_power'` as its default, which would have left the README's documented `experiment.set_up_experiment(exp_type, subject_str)` call working untouched. It was rejected: the old family's real defect is that the base variant was the unnamed one, and a default would have preserved exactly that. Naming all five and requiring the name also makes a stale two-argument call fail loudly on `mustBeMember` instead of silently running the base variant. The README call was updated instead.

The variant-specific inputs of `session_settings` are name-value, not a union of positionals: `levels` (the level variable — an n_levels × 2 array of edge-power limits for `'edge_power'`, a vector of 1/f exponents for the three exponent variants, unused by `'all'`), plus `texture_params`, `target_exponent` (`'diff_bg'` only) and `transform_exp_name` (`'edge_power'` only). One concept, `levels`, covers what was four differently-named positional arguments.

**Field order is preserved exactly, per variant, and that drove the struct assembly.** The five `ExpSettings` layouts differ in three places: which fields lead (`texture_params` vs `textures`, plus `target_exponent`/`bg_exponents` or `alphas`), what the level-count fields are called (`nLevels`, or `nTrials_eachtx`/`nLevels`/`nTex`, or `nBlocks`), and which result fields appear (`'all'` has no `edgePowers`; `'texture_exponent'` writes `stimuliSeed` where the others write `seeds`). Writing the struct out five times would have reintroduced the duplication the item exists to remove, and reordering the fields into one uniform layout would have changed the shape of a frozen artifact for no benefit. So the struct is assembled from three per-variant name-value lists — `head_fields`, `count_fields`, `result_fields` — spliced around the two shared runs and passed to `struct(...)`. Verified below: all five field orders come out byte-identical to what HEAD produced.

**The two things the item warned about, and what was done with them.**

- **The `bTargetPresent` landmine** (tranche 0.1.7 nearly dropped it from `generate_camouflage_stimuli_all`'s signature). The generators' signatures were not touched at all by this item, so the dead eleventh parameter is still declared and `checkcode` still reports `INUSD` on it. Confirmed by re-running `checkcode` after the edit.
- **B2.6's frozen-name divergence** (`nLevels`→`nBlocks`, `seeds`→`stimuliSeed` in the `_texture_exponent` chain). Deliberately **not** fixed and deliberately **not** erased: the `'texture_exponent'` case emits exactly those two names and no others, with an in-file comment saying why. The collapse does not resolve the bug, but it does make it legible — the four variants that emit `.nLevels`/`.seeds` are now five lines away from the one that does not. B2.6's file:line pointer in 0.4 was re-pointed.

**Three earlier decisions were checked before renaming anything, and none was reopened.** Decision A (`ml`/`cont` → `luminance`/`contrast`, blocked in three files by string-literal collisions with field names): the collapse dissolves the collision, because the `'luminance'`/`'contrast'` literals now live in one shared list rather than beside a local in every variant, so `session_settings` uses the expanded names throughout — the same target A named, now reachable. Decision B (`global bdry_ribbon` keeps its name, local copies are `mask_strip`): unchanged; the global is declared once and assigned in the two-and-a-half cases that used to assign it. Decision C (the two meanings of `.alphas` get two local names, the field stays `.alphas`): honoured — the shared local is `options.levels`, and the header spells out which quantity `.alphas` holds in which variant.

**One deliberate generalisation, one deliberate reorder, and nothing else changed.** The generalisation: `session_settings`'s `'all'` case loads `exp_files/<exp_type>/texture_list.mat` where `session_settings_all` hardcoded `exp_files/all/`. Identical at the only configuration that variant has ever had (the old function could not be told any other name), and it removes the last hardcoded folder string from a function that now takes `exp_type`. The reorder: the two `zeros(n_trials, n_levels, n_sessions, 2)` position arrays are built after the generator call rather than before it. They make no RNG draws and depend only on three counts fixed before the switch, so no sequence of random numbers moved.

**Verification — no mechanical check applies**, as Stage 3 expects; `check_stage1` fails by design here, since ten files became two and every signature moved. What was done instead:

- **Exhaustive call-site sweep.** All fifteen names, in snake_case, in the pre-S2.19 camelCase spelling, and in the uppercase `See also` spelling, were grepped across the whole repo — every file type, including the 29 `_`-prefixed dead files, `tools/`, and the non-`.m` docs. Every hit was read. Live call sites: five, all inside the family itself (each `set_up_experiment_*` calling its own `session_settings_*`), all now one call. Documentation references: `+experiment/Contents.m`, `README.md:69,139`, `CLEANUP.md:75-77`, and four generator `See also` lines, plus prose in `subject_experiment_file.m:35` and `transform_camouflage_stimuli.m:30-32` — all updated. `+general/pick_edge_power_bins.m` and `load_stimuli_camouflage.m:110` name only `set_up_experiment`/`generate_camouflage_stimuli`, which still exist. After the edit the same sweep returns no hit in any `.m` file; the only remaining hits are historical records (the 0.1.1 rename map, the 0.1.7 tranche log, the 3.1.4 triage table, B2.6, and CLEANUP.md's account of a past removal), which describe what was true then and are left as written.
- **Golden harness.** None of the fifteen is a golden-checked entry point — `tools/golden_harness.m` covers `+lib/`, `experiment.gamma_correct`, `experiment.generate_target_present_matrix` and `+experiment/+analysis/`, and deliberately not these, which do disk I/O and hours of synthesis. Replay was run anyway, before and after, and is unchanged: `golden_harness: replay matched all 57 fields`.
- **Smoke test.** `passed 50 / failed 0 / xfail 2 · smoke_test: PASS`. Its two counts moved exactly as predicted: in-scope callable names 162 → **154** (the eight deleted files), and distinct package-qualified references 97 → **93** (the four `experiment.session_settings_*` calls; the `set_up_experiment_*` names were never called by anything). `lib.circular_mask` is still written, in the `'texture_exponent'` case, so B2.9's `known_dead` list is unchanged and the sweep still reports "except the 14 known dead ones".
- **A field-order and plumbing replica, since the real path cannot be run.** The five generators were stubbed in a scratch `+experiment` package placed ahead of the repo on the path, and the collapsed `session_settings` was called once per variant. Each stub printed the arguments it received; the resulting `fieldnames` were compared against the five field lists extracted mechanically from the HEAD versions of the five deleted files. Result: **all five field orders match, exactly and in order** (29, 28, 29, 28, 28 fields), and every generator received the same arguments its old caller passed — including `n_sessions = 16` for `'shape_exponent'` and `n_trials = n_tex·40/(n_levels·n_sessions)` for `'all'`. The same replica was then run one layer up against a stubbed `session_settings`, confirming each variant's geometry (256/64/60, or 512/128/120 for `'shape_exponent'`), its `texture_params` contents, whether `bdry_ribbon` is set (`[256 256]` for `'edge_power'` and `'diff_bg'`, empty for `'all'` and `'shape_exponent'`), and that only `'shape_exponent'` writes a `-v7.3` file (9,128 bytes vs 230). `'texture_exponent'` failed at `lib.circular_mask`, which is its recorded pre-existing behaviour (B2.9), and a bogus variant name was rejected by `mustBeMember`.
- **`checkcode`** on both new files: two messages, both pre-existing in kind — `GVMIS` for the global (S1.13's) and `LOAD` for the bare `load` of `texture_list` (inherited verbatim from `session_settings_all`, not "fixed", because specifying the variable would be a change). The ten old files carried four such messages between them.

**One real defect was introduced and caught during the work, and it is worth recording because the trap is subtle.** The first draft declared `options.transform_exp_name (1, :) char = ''`. A `(1, :)` size validator coerces the default `''` from 0×0 to 1×0, and `strcmp` requires matching sizes, so the `strcmp(transform_exp_name', '')` guard that decides between synthesising and transforming stopped firing and every `'edge_power'` setup took the transform branch. Caught by the replica on its first run. The validator is now unconstrained in size, with a comment saying why. Note that this is *not* B3.7's stray transpose — the guard fails identically with or without it — so B3.7 remains exactly as recorded, unfixed.

**Commented-out code.** All of tranche 0.1.7's verdicts for these files were honoured as recorded, and none was re-judged. T6.1, T6.2 and T6.3 (in the base `set_up_experiment`, verdicts *alternative*/*superseded*) are preserved **verbatim** in the collapsed file, moved into the branch they belong to; acting on them is still S1.16's, and their line references in 3.1.4 have been updated. T6.8 (`set_up_experiment_shape_exponent`, verdict *superseded*, recorded at the time as tying to this item) went with the file, which is what *superseded* prescribes; 3.1.4 now says so. The un-rowed commented lines in the four non-base set-up files were byte-identical duplicates of T6.1's `% n_levels=10;` and T6.3's `%subject_str = ...`, so the collapse leaves one copy of each rather than five; no distinct block was lost. `session_settings.m`'s `% edge_power_block_centers=movmean(...)` is preserved.

**One new bug found and recorded, not fixed: B2.29** — `+tinker/show_example_stimuli.m:27` calls `experiment.generate_camouflage_stimuli` with 8 arguments where it takes 10. Found by the call-site sweep. The generator's signature is untouched by this item, so the breakage is pre-existing.

**One piece of collateral staleness fixed, one left.** Fixed: the four generators and `Contents.m` cited `S3.3` for this collapse, an id that does not exist in this plan — they now cite S2.3. Left, and noted here rather than acted on: the same stale-id pattern runs through other `+experiment/` headers, which cite `S3.2`, `S3.4` and `S3.13` for what are now S2.2, S1.4 and S1.13. Those files were not in this item's scope and were not touched. `README.md`'s `+experiment/ (56 files)` was decremented by 8 to 48; the basis of the original 56 could not be reconstructed from any count of the directory, so the delta is right and the absolute number is as approximate as it was before.

**No optimization was made**, though one is now visible and is *not* filed, because it is really S1.13's: `mkdir` is called inside the subject loop, so it warns "Directory already exists" once per subject after the first. That is the "duplicate write" S1.13 already enumerates.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">S2.2 &mdash; every path through <code>config.m</code> (33 files, 74 call sites); B2.1 resolved</h5></summary>

<div style="margin-left:1.5em">

**The item's premise was right and its diagnosis of B2.1 was wrong, and that is the main finding.** The item said config had zero callers, which was still true on contact -- the only consumers were `tools/golden_harness.m` and `tools/smoke_test.m`, both reading `cfg.seed` and nothing else. But B2.1 was recorded as "`vislab-common/data/edge_powers/` doesn't exist," and `config.m` had faithfully encoded that non-existent location as `cfg.paths.edge_powers = fullfile(data_root, 'edge_powers')`. Routing the call sites through a field that points nowhere would have changed nothing. The directory is not missing; it is **`<repo>/data/edge_powers/`**, and it has been in the repo all along.

**How that was established, rather than guessed.** `data/edge_powers/` holds `pink_noise.mat` and `natural/` with fifteen per-texture files (`bark`, `camo`, `camo_large`, `coral`, `foliage`, `grass`, `leaf`, `leather`, `moth`, `paper`, `rock`, `sand`, `scales`, `soil`, `spots`). `whos -file` on two of them returns exactly `edgePowerBlockEdges` and `edge_powers` -- the two variable names the three load sites name explicitly. The key the loaders build the filename from is `exp_type`, and `exp_files/natural/` carries the same fifteen names, so `exp_type = 'natural/camo'` resolves consistently in both trees. One line of `config.m` changed; nothing was moved, copied, or created.

**The same stale `vislab-common/data/` prefix turned out to cover two different real locations, and separating them was the only judgement call in the item.** The prefix is a leftover from a layout that predates the split into this repo plus the shared store. Files that exist in the shared store today (`nat_im_eff_coding.mat`, `CPS natural images/`, `textures/natural/*.png|jpg`) route to `cfg.paths.data_root` and its children. Everything else under that prefix is an artifact *this repo computes and writes*, and routes to `cfg.paths.data`. That second claim is not an inference from the file names -- `data/old/` holds old copies of exactly those outputs, and their contents match: `data/old/video_demo.mat` contains `stim_energy`, which is the single variable `video_demo.m` saves, and `data/old/pink_noise_stim_corrs.mat` contains `LLR_blank, LLR_target, corr_blank_cross, corr_target_cross, d`, exactly the five names in `pink_noise_stimuli_autocorrelations.m`'s save list.

**What `config.m` looks like now.** Eight path fields, no new ones:

| field | value | changed? |
|---|---|---|
| `paths.repo_root` | this repo | -- |
| `paths.data_root` | `../vislab-common/data` | -- |
| `paths.natural_images` | `<data_root>/CPS natural images` | -- |
| `paths.textures` | `<data_root>/textures` | -- |
| `paths.exp_files` | `<repo>/exp_files` | -- |
| `paths.data` | `<repo>/data` | -- |
| `paths.edge_powers` | `<repo>/data/edge_powers` | **repointed from `<data_root>/edge_powers`** |
| `paths.por_sim` | `<repo>/por_sim_tx_synth` | -- |
| `paths.images` | *removed* | had zero callers and named `<data_root>/images`, which has never existed |

`paths.images`'s one intended consumer, `set_up_experiment.m`'s Portilla-Simoncelli branch, builds `<root>/<exp_type>.png` -- and `<data_root>/textures/natural/camo.png` exists while `<data_root>/images/natural/camo.png` does not, so that site now uses `paths.textures` and the redundant field is gone. `optics`, `norm` and `seed` are untouched, so `tools/golden_harness.m:50`'s `cfg = config()` and its 22 `rng(cfg.seed)` calls are unaffected -- confirmed by replay, below.

**Scope, and how the sweep was made exhaustive.** Three independent greps over every `.m` file outside `tools/`, `por_sim_tx_synth/`, and the 29 `_`-prefixed dead files: (1) the three literal roots `vislab-common`, `exp_files`, `por_sim_tx_synth`; (2) any `load`/`save`/`imread`/`imwrite`/`dir`/`mkdir`/`addpath`/`genpath` call whose first argument is a string literal containing a separator; (3) any string literal ending in `.mat`/`.png`/`.jpg`/`.csv`/`.txt`/`.avi`/`.mp4` anywhere in the file, to catch bare filenames the first two would miss. **32 production files** carried a hit; after the edit, grep (1) returns only comments, and greps (2) and (3) return only `fullfile(...)` calls already rooted in a `cfg.paths` field, plus the two exceptions below. Field usage: `exp_files` 38 sites, `data` 8, `edge_powers` 7, `textures` 7, `data_root` 6, `por_sim` 6, `natural_images` 2 -- 74 in all, across `+experiment/` (11 files), `+general/` (17), `+tinker/` (3), `+tests/` (1).

**Two literals deliberately left hardcoded, both stated rather than quietly skipped.**

- `+experiment/+analysis/compute_bootstrapped_threshold.m:58-65` -- the `/Users/steve/Dropbox/.../Jared_Project/` and `C:\Users\sebastian\Dropbox\...` pair. These point at another person's machine and a *different* project's data, not this repo's, so there is no config field they belong in and inventing one would be worse than the literal. That is **B2.11**, still open and untouched.
- `+general/analyze_search_exps.m:127` -- `dir('*.mat')`, a bare wildcard over whatever directory the user happens to be in. It has no data root to route to; it is "the current folder" by design. Left, noted here.

**Behaviour.** Every path that resolved before still resolves to the same file, because each rewrite replaces a cwd-relative literal with the absolute path it expanded to when cwd was the repo root -- which the README required until now. The change is that they no longer depend on cwd, so that README requirement was dropped. Paths that never resolved (the `vislab-common/data/*` set) now resolve where the evidence says they should, or, for the handful of write targets that have no file yet (`seed_energy_pink_noise.mat`, `seed_multiple_energies_symmetric.mat`, `seed_energy_pink_noise_whitened.mat`, `pink_noise_stim_blank_autocorr.mat`, `edge_powers_camo*.mat`), point at the directory their own `save` will create them in. Two files still name something absent for an unrelated reason, recorded not fixed: `compute_noise_colour.m` asks for `bark.png` where the store has `bark.jpg`, and `compute_texture_autocorrelation.m`'s list includes `sand`, `coral` and `sand2`, which are not in `textures/natural/`. Both were already broken and are not B2.1.

**Verification.** No mechanical check applies -- `check_stage1` fails by design, since every rewritten call site is a real AST change. What was run instead, MATLAB R2024b Update 6:

- **Existence check on every config path**, after the edit: `edge_powers` yes, `edge_powers/pink_noise.mat` yes, `edge_powers/natural/camo.mat` yes, `textures/natural/camo.png` yes, `exp_files` yes, `natural_images` yes, `seed = 0` unchanged.
- **Golden harness:** `golden_harness: replay matched all 57 fields`.
- **Smoke test:** `passed 50 / failed 0 / xfail 2 / skipped 0 . smoke_test: PASS` -- unchanged from before the item.
- **Parse/canon over all 40 files dirty in the tree:** `checked 40 files, failing parse/canon: 0`. (40 rather than 33 because S2.20 was working in the same tree; its nine files are not part of this commit.)

**Collateral.** `README.md`'s "the working directory must be the repo root" paragraph and its "Not done: the data paths" line are both now false and were rewritten. `+experiment/Contents.m` and the headers of `set_up_experiment.m` and `generate_camouflage_stimuli.m` carried B2.1 warnings and a stale `S3.2` id (the last of the three S2.19 flagged) -- all three updated to describe the config-routed state.

**No bug was fixed beyond B2.1, no optimization made, and no commented-out block touched.** The commented-out path literals in `compute_edge_powers_pink_noise.m`, `compute_nat_img_eff_coding_bins.m:95`, `pink_noise_stimuli_autocorrelations.m:92`, `scratch.m:35-36` and `set_up_experiment.m:206,221` were left exactly as they are; they belong to S1.16 and their 3.1.4 verdicts, not here.

</div>

</details>

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
