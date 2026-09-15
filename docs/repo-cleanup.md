# Repo-wide cleanup plan — camouflage_detection

Readability, then structural cleanup and optimization, then bug fixes.

Read every in-scope `.m` file in the repo and clean it in place — better names, complete header docs, consistent conventions, reflowed long lines. The first phase of this operation is **behaviour-preserving**: no output changes, a constraint that is **mechanically checkable**, so the diff does not need to be trusted, only verified. Four stages of change, defined fully in section 3: Stage 1, Stage 2, Stage 3, Stage 4. Stages 1 and 2 are this behaviour-preserving readability pass; Stage 3 is the next step of the same overall operation — structural cleanups and optimizations, done once the readability pass is complete; Stage 4 is the bug fixes found along the way, done last.

**Provenance.** This plan supersedes the former `CODEBASE.md`, whose survey, bug list, and readability blueprint were folded in here; the descriptive half of that document (what the project is, how it runs, the data model) moved to `README.md`. Findings carried over from it were recorded against `master` @ `ae20cf1` and carry their original verification markers — **[ran]** for a claim checked by executing MATLAB R2024b, **[read]** for a claim checked by reading a specific line. Every count in section 1 was re-measured for this plan against the tree as it stands, not carried over.

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">0. Status</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">0.1 Stage 1 — in progress (tooling done)</h3></summary>

<div style="margin-left:1.5em">

Comments, header docs, whitespace, reflow, file-local renames, and triaging any commented-out code found in each tranche's files (verdict only, nothing deleted). Checked by `isequal` on a canonical AST fingerprint — no execution needed.

- [x] **0.1.0.** Tooling: `canon`/`check_stage1`/`assert_rename_bijection`, golden-output harness, repo-wide rename map. → `matlab-cleanup-lead`
- [x] **0.1.1.** `+lib/` edge & stimulus core — 14 files, 948 lines. **Sets the naming conventions for everything downstream.** → `matlab-cleanup-lead`
- [x] **0.1.2.** `+lib/edge_props_stim.m` — 1 file, 535 lines. → `matlab-cleanup-lead`
- [x] **0.1.3.** `+lib/` remainder — 41 files, 1484 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [x] **0.1.4.** `+experiment/+main/` — 11 files, 714 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [x] **0.1.5.** `+experiment/+analysis/` — 12 files, 787 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [ ] **0.1.6.** `+experiment/` top level, including the variant families — 26 files, 1390 lines. → `matlab-cleanup-lead`
- [ ] **0.1.7.** `+general/` live model chain — 4 files, 833 lines. → `matlab-cleanup-lead`
- [ ] **0.1.8.** `+general/` remainder — 27 files, 1641 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [ ] **0.1.9.** `+vis/` + `+tests/` — 10 files, 484 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [ ] **0.1.10.** `+tinker/` — 13 files, 1040 lines. → `matlab-cleanup-mechanical` (`model: "sonnet"`)
- [ ] **0.1.11.** Root files: `config.m`, `setup.m`, `edge_power_demo.m`, `test.m`, `test_Erlang.m` — 5 files, 356 lines. → `matlab-cleanup-lead`

Full detail, tranche sequencing, and per-tranche findings: section 4.1.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">0.2 Stage 2 — not started</h3></summary>

<div style="margin-left:1.5em">

Semicolon insertion, preallocation, `find`→logical indexing, deleting a provably unused assignment. Checked by a whitelisted-pattern diff **plus** a runtime golden-output match. Only the `+lib/` core chain and the three psychometric functions can be covered by a runtime harness at all — everything else is pattern-check only, for the reasons in section 2.

- [ ] **0.2.0.** Extend the golden harness to cover every entry point listed in section 2.
- [ ] **0.2.1.** `+lib/` (tranches 0.1.1–0.1.3) — golden-checked.
- [ ] **0.2.2.** `+experiment/+analysis/` (tranche 0.1.5) — golden-checked for the three psychometric functions, pattern-only for the rest.
- [ ] **0.2.3.** `+experiment/` and `+experiment/+main/` (tranches 0.1.4, 0.1.6) — pattern-check only.
- [ ] **0.2.4.** `+general/` (tranches 0.1.7–0.1.8) — pattern-check only.
- [ ] **0.2.5.** `+vis/`, `+tests/`, `+tinker/`, root (tranches 0.1.9–0.1.11) — pattern-check only.

Coverage gaps found while extending the harness, and the fixes made, are detailed in section 4.2.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">0.3 Stage 3 — next step, done after the readability pass</h3></summary>

<div style="margin-left:1.5em">

Signature changes, merging duplicate functions, reordering statements — not part of the behaviour-preserving Stage 1/2 pass, done afterward as the next step of the overall cleanup. Bug fixes are their own stage (0.4), done after this one. Left unchecked until actually done. Full rationale in section 3.

Each item names its agent: `matlab-cleanup-stage3` (opus) when a design decision, per-instance safety judgment, or irreversible/high-stakes risk is still open; `matlab-cleanup-stage3-mechanical` (sonnet) when the fix is already fully specified and only needs correct execution. One invocation per item, never a batch (see the skill's "Dispatching tranches" section).

Roughly in value-per-unit-effort order; the first four are the ones that change what the repo can do, the rest are tidying.

- [ ] **S3.1.** **Stop storing stimuli; store seeds (~100 GB → ~10 MB).** `ExpSettings.stimuli` is 0.59 GB per experiment and is fully determined by `ExpSettings.seeds` plus the texture parameters, because `lib.stimulus` does `rng('default'); rng(seed)` at `+lib/stimulus.m:82-83` before every draw **[read]**. Replace the stored array with a `regenerate_stimuli(ExpSettings)` call, cached to a scratch directory at run time. Caveat: Portilla–Simoncelli textures cost ~25 synthesis iterations each, so regeneration is cheap for pink noise and expensive for `natural/*` — keep a local cache for those, or regenerate once per session rather than per trial. This also makes the experiment data archivable and lets the settings half of `exp_files/` enter version control. → `matlab-cleanup-stage3` (caching strategy is a real design choice)
- [ ] **S3.2.** **Route every path through `config.m`.** `config()` exists, is well-formed, and has **zero callers**. Every data path in the repo is relative to the working directory, and the two families are mutually incompatible: `exp_files/...` needs cwd = repo root, while `vislab-common/data/...` would need cwd = the lab root — and that directory does not exist anyway (B2.1). Point `cfg.paths.edge_powers` at the in-repo `data/edge_powers`, drop the non-existent `cfg.paths.images`, add `cfg.paths.textures` → `<data_root>/textures/natural`, and replace the ~40 literal paths. This single change un-breaks the experiment-setup path and most of `+general/`. → `matlab-cleanup-stage3-mechanical` (the target mapping is fully specified above)
- [ ] **S3.3.** **Collapse the experiment-variant families.** `{setUpExperiment, sessionSettings, generate_camouflage_stimuli} × {base, _all, _diff_bg, _shape_exponent, _texture_exponent}` is 15 files implementing one algorithm with five choices of "what varies across levels". Measured duplication in `sessionSettings_*`: 75–81 % of unique non-blank lines are identical to the base. The variant-specific content is 3–5 lines in `setUpExperiment*`, ~6 in `sessionSettings*`, and ~10 in `generate_camouflage_stimuli*`. One function taking a level-variable spec — a closure `@(iLevel) stimulus_args` plus a closure `@(stim) edge_power` — covers all of them. This is not just tidiness: **three of the four non-base generators are broken (B2.4, B2.6) precisely because they were never updated when `lib.stimulus` changed**, and a single call site makes that class of drift impossible. `_search` is a genuinely different paradigm and should stay separate. → `matlab-cleanup-stage3` (the closure abstraction is a design decision, not a specified fix)
- [ ] **S3.4.** **Pick one edge-power definition and make everything else call it** (resolves B1.1). The paper and the deployed `data/edge_powers/*.mat` both use the `rms(edge_mag)` normalisation, so the cleanest move is: keep `lib.edge`'s interface and docstring, change its normalisation to match `edge_vector_ideal`, delete `edge_vector_ideal`/`edge_measures_ideal`/`edge_shape`, and repoint callers. Then decide explicitly whether `lib.steerable_grad`'s `normalize` default should be `false` — it is currently `2e-4`, which is what causes the double normalisation. → `matlab-cleanup-stage3` (the `normalize`-default question is an open decision, and this feeds published numbers)
- [ ] **S3.5.** **Add a real smoke test.** `+tests/` has two ad-hoc scripts, no assertions, and no runner. A single `run_tests.m` that (a) generates a stimulus from a fixed seed and checks edge power against a stored value, (b) round-trips `seeds → stimuli → edge power`, (c) calls every function on the live path with a minimal argument set, and (d) asserts that every package-qualified reference in the repo resolves, would have caught B2.1, B2.2, B2.3, B2.4, B2.5, B2.6 and B2.9 immediately. The resolution check is ~20 lines and already exists as a scratch script from this survey — see section 4.1.3, step 0. → `matlab-cleanup-stage3-mechanical` (spec for (a)–(d) is fully given)
- [ ] **S3.6.** **Quarantine or delete the 29 `_`-prefixed dead files properly.** They are currently renamed in place rather than moved. Decide between an actual `legacy/` folder outside the package tree and outright deletion, and either way fix the two references that the rename broke: `+tests/gaborSimilarity.m:42` calls `stats.computeSceneSimilarityAmplitude`, which no longer resolves. Also confirm the remaining unnamed `+general/` scripts from B3.11 before extending the set. → `matlab-cleanup-stage3-mechanical` (binary choice plus two named reference fixes)
- [ ] **S3.7.** **Make the live `+general/` scripts into functions.** 40 of its 41 files are top-level scripts that silently depend on workspace state (B3.11). Converting the ~8 that are still live into functions with explicit arguments removes the single biggest barrier to anyone re-running the analysis. → `matlab-cleanup-stage3` (which ~8 of 41 are actually live is not yet enumerated — judgment call first)
- [ ] **S3.8.** **Fix the `edge_powers` producer/consumer split.** `+general/compute_edge_powers_*.m` write `vislab-common/data/natural/edge_powers_camo.mat`; consumers read `data/edge_powers/natural/camo.mat`. No producer in the repo currently feeds any consumer, and the block edges are added by hand via `+general/pick_edge_power_bins.m`. Make the producers write the consumed layout and compute `edgePowerBlockEdges` in the same script. → `matlab-cleanup-stage3` (reconciling producer and consumer formats needs cross-file design)
- [ ] **S3.9.** **Rename the zone-2 cross-file name-value parameters listed in section 4.1.1** — its own pass, deferred out of Stage 1 because each one touches a string literal at every call site. → `matlab-cleanup-stage3-mechanical` (the full parameter list and call-site counts are already enumerated in 4.1.1)
- [ ] **S3.10.** **Rename any zone-3 frozen `save`/`load` name listed in section 4.1.1** — only alongside a migration script that rewrites the existing `.mat` files, since ~100 GB of collected human data depends on these names. → `matlab-cleanup-stage3` (irreversible: a migration bug corrupts real collected data)
- [ ] **S3.11.** **Repoint `+lib/ptch_norm.m` and `+lib/watson_otf.m` to `vislab.lib.*` and delete the local copies.** These are the uncleaned ancestors of the shared-library files; the shared `ptch_norm` header explicitly describes this repo's copy as the buggy root `+lib` copy. Note that `vislab.lib.ptch_norm` has a different signature, so this is a call-site change, not a drop-in swap. Resolves B3.3. → `matlab-cleanup-stage3` (differing signature means each call site needs individual adaptation, not a mechanical repoint)
- [ ] **S3.12.** **Add `arguments` blocks.** There are none anywhere in the repo; 9 files use `inputParser` instead. Converting changes validation behaviour, which is why it is not in the readability pass. → `matlab-cleanup-stage3-mechanical` (one conversion pattern applied per file)
- [ ] **S3.13.** **Remove the dead scaffolding found in the live path:** the `global bdry_ribbon` set at `+experiment/setUpExperiment.m:67` that nothing reads (`generate_camouflage_stimuli.m:3` recomputes it locally); the duplicate `bTargetPresent` write at `+experiment/saveCurrentLevel.m:34-35,38`; the unmodified large-file re-save at `+experiment/loadCurrentSession.m:48`; and the debug `randi(10)` and `figure(1); imshow(stim)` in `+lib/edge_props_stim.m:30,152-153`. **Added by tranche 0.1.2:** the same file also fires three unconditional per-scale bar plots inside its main loop — pre-edit `:188-191`, `:217-220`, `:246-249`, each a `figure(n)`/`subplot`/`bar`/`title` group — in a function called once per trial from `arrayfun` over 1200 trials. Same class as the two already listed; they are currently unreached only because B2.2 errors first. → `matlab-cleanup-stage3-mechanical` (seven named sites, each already diagnosed)
- [ ] **S3.14.** **Consolidate the three `gammaCorrect` implementations** onto `vislab.lib.gamma_compress`. Carried over from `CLEANUP.md`. → `matlab-cleanup-stage3-mechanical` (target already named)
- [ ] **S3.15.** **Reorder statements**, wherever a tranche flagged a reorder as wanted — kept out of Stage 1/2 only because the check cannot distinguish a safe reorder from an unsafe one. → `matlab-cleanup-stage3` (safety of each reorder is a per-instance judgment, by definition)
- [ ] **S3.16.** **Act on the Stage 1 commented-out-code triage** — one item per file or block cluster, generated from the triage table in section 4.1.4. Delete the blocks judged *superseded* or *scaffolding*; convert the ones judged *alternative* or *unfinished* into a documented option or header prose. Leave every *unknown* exactly as it is. → `matlab-cleanup-stage3-mechanical` (the judgment call already happened in Stage 1; this only executes the recorded verdict)
- [ ] **S3.17.** **Validate the Psychtoolbox harness on hardware.** The migration onto `vislab.psychframework` was parse-verified only; `../REORGANIZATION_PLAN.md:323` records that runtime validation was waived. Two latent issues to check when you do: `S.targetTypeStr` is read at `runCamouflageExperiment.m:59` but never set (inside a `try`, so the EDF file is silently not retrieved), and `stimulusInterval` returns `stimulusOnsetMs`, which `run_trial.m:14` discards — if the retired `runTrial.m` recorded onset times, that measurement is now lost. Note also that the entire EyeLink layer is currently unreachable because `loadStimuliCamouflage.m:16` hardcodes `bFovea = 1`. → `matlab-cleanup-stage3` (hardware-in-the-loop diagnosis of two open latent bugs; also needs the user's sign-off before any real-hardware run, per the skill's MATLAB authorization limits)
- [ ] **S3.18.** **Repo hygiene.** Ignore `.claude/settings.local.json` (texture-segmentation does); update `.gitignore:2` `vislab_data/` → `vislab-common/`; clean the stale `vislab_data\...` entries out of the user's MATLAB saved path, which currently produce 11 "nonexistent directory" warnings at every startup **[ran]**. → `matlab-cleanup-stage3-mechanical` (three named, fully specified edits)

Stage 3's work log (section 4.3) fills in as each item here is actually done.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">0.4 Stage 4 — bug fixes, done last</h3></summary>

<div style="margin-left:1.5em">

Bugs found anywhere during Stage 1, 2, or 3, recorded here as they're found and fixed here, after Stage 3, so a fix doesn't get clobbered or duplicated by a structural change landing later. **No automatic dispatch here** — unlike Stage 1–3, the user launches each bug fix manually, at their own pace, typically via `matlab-cleanup-stage3` since a bug fix is rarely fully specified in advance.

Each item's id is `B<severity>.<n>`: the severity number, 1 (highest) to 3 (lowest), then the item's position within that severity in the order found. The list is a single flat sequence sorted by severity first and discovery order second — all B1s, then all B2s, then all B3s — and that's also the order it's worked in. A newly found bug gets the next `n` for its severity and is inserted at the end of that severity's run; nothing already in the list is renumbered.

🔴 = severity 1, silently wrong results on a path that has actually been run. 🟠 = severity 2, reachable but not silent — it errors out, or touches only plots, logging, or display. 🟡 = severity 3, latent, not reachable with the current config but a hazard for a plausible future use.

Everything below was found *before* this plan started, during the survey that produced it. The severity scheme here replaces the old S1–S4 scheme in `CODEBASE.md`; the crosswalk is in section 4.4 so that older notes and commit messages still resolve.

**Severity 1 — silently wrong results**

- [ ] 🔴 **B1.1.** **Two incompatible definitions of edge power are both live.** **[ran]** `+lib/edge.m:92` divides the normal gradient by the per-pixel `lib.local_sd`; `+lib/edge_vector_ideal.m:91` divides by the scalar `rms(edge_mag)` along the boundary. On the same stimulus (`seed=35096`, pink noise, `ml=0.5`, `cont=0.15`) `lib.edge` returns 2605.23 while `lib.edge_measures_ideal(edge_vector_ideal(...))` returns 0.840855 — a ratio of about 3098. The `_ideal` value is the dimensionless one that matches the paper's $e = g_\perp/g_{\mathrm{rms}}$ and is what is frozen into `data/edge_powers/*.mat`, but `lib.edge` is what `edge_power_demo.m` teaches and what `generate_camouflage_stimuli_shape_exponent.m:21` uses. Contributing cause: `lib.steerable_grad` already normalises by default (`steerable_grad.m:10`, `normalize = 2e-4`, dividing by $\sqrt{\sigma^2+k}$ at `:69`), and `edge.m:92` then divides by $\sigma$ again, so `lib.edge` scales roughly as $1/\sigma^4$. Call sites that want raw gradients pass `'normalize',false` explicitly (`target_mask.m:98`, `edge_props_stim.m:100`), so the codebase is inconsistent about this. Fixed by S3.4, which must decide which definition is canonical rather than patching one call site.
- [ ] 🔴 **B1.2.** **Level order is reversed in three of the five `compute_edge_props_exp*` scripts.** **[read]** `+general/compute_edge_props_exp_pca.m:18` (and `_full.m:16`, `_raw.m:23`) build `[Itrial, ILevel, ISession] = ndgrid(1:30, 10:-1:1, 1:4)`, while `_exp.m:15` and `_eq.m:16` use `1:10`. `arrayfun` returns an array shaped like `Itrial`, so position `b` along dimension 2 holds level 11−b. The very next stage indexes features and labels with the *same* forward index (`:81` `this_input_array(:,iLevel,:,...)` against `:77` `ExpSettings.bTargetPresent(:,iLevel,:)`), so `classify_normals` is fitted with mismatched target/blank labels and `comb_dv(:,iLevel,:)` is stored under the wrong level. Nothing between `:18` and `:89` compensates, and `+general/flip_hard_easy.m` flips stimuli and `bTargetPresent` together and then flips both back (`:14-15`), so it does not explain the asymmetry either. This affects `edge_props_pca.mat`, the input to the current model fitter. **Confirm the intent before trusting any current model number** — the intent itself is *unverified*; the inconsistency between sibling scripts is the evidence.
- [ ] 🔴 **B1.3.** **`lib.create_pink_noise_line` ignores its exponent argument entirely.** **[ran]** `+lib/create_pink_noise_line.m:4-5` guards with `if ~exist('alpha','var')`, but `alpha` is never a variable in that function, so the guard is always true and the caller's `exponent` is unconditionally overwritten with 1. Verified: with a fixed RNG seed, `create_pink_noise_line(4096,1)` and `(4096,3)` are bit-identical, max absolute difference 0. `+lib/target_mask.m:39` passes `target_shape` into this function, so **`lib.stimulus`'s `target_shape` parameter has no effect on boundary roughness** — every non-circular target is generated with exponent 1. That is the manipulation of the shape-exponent experiment (paper §3.7). Whether the 29 GB of stored `exp_files/shape_exponent/` stimuli predate the regression is *unverified* — check before concluding anything about that experiment.
- [ ] 🔴 **B1.4.** **`lib.stimulus` synthesises the target from the *background's* texture statistics.** **[read]** `+lib/stimulus.m:182-184` analyses the *target* image into `texture.stats` and then discards it, calling `textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter)`. This is silent whenever target and background textures are the same — the maximal-camouflage case, which is most of the experiments — and wrong exactly when they differ, i.e. for the `_diff_bg` family, which was run (`exp_files/diff_bg/` exists on disk). Compare the correct background branch at `:125-127`.
- [ ] 🔴 **B1.5.** **`+general/compute_edge_group_measures.m:20` reads outputs that no longer exist.** **[read]** It calls `[~,~,l_groups,e_groups] = lib.edge(stim)`, but `lib.edge` returns `[edge_vector, edge_power, edge_field, th_grid]`; the contour-group code that produced lengths and energies is commented out at `edge.m:114-134`. Outputs 3 and 4 are now a 256×256 field and a 1×1000 angle grid, and **no error is raised**. The *stored* data is still valid — `ExpSettings.stim_l_groups{1,1,1}` in `exp_files/pink_noise/exp_settings.mat` holds 104 contour lengths summing to exactly 1000 = `n_edge` **[ran]** — so this is a regression: re-running the script would silently overwrite good data with garbage, and `computeThreshold_edgeResponse` consumes it. Filed at severity 1 rather than 3 because the failure is silent and one re-run destroys data that cannot be regenerated from the current code.
- [ ] 🔴 **B1.6.** **Timeout responses corrupt the result arrays.** **[read]** `+experiment/+main/responseInterval.m:25` returns `response = -1` when no key is pressed. `+experiment/saveCurrentLevel.m:38` assigns that into `SubjectExpFile.response`, which is preallocated `false(...)` at `subjectExperimentFile.m:24`. The SDT fields at `:39-49` are computed from the raw double, so a timeout scores `false` in *all four* of hit/miss/false-alarm/correct-rejection — the trial vanishes from every category while still counting in `nTrials`, deflating the correct-rejection rate in `computeThreshold_edgePower.m:41-43`.
- [ ] 🔴 **B1.7.** **Bootstrap resamples the wrong number of observations.** **[read]** `+experiment/+analysis/computeThreshold_edgePower.m:88` calls `datasample(exp_values(:,iLevel), nTrials)` with `nTrials = 30`, but after the concatenation at `:32` `exp_values` has 30 × sessions-completed rows, up to 120. Each replicate therefore draws 30 of 120, inflating `threshold_sd` by roughly $\sqrt{\text{sessions}}$. The same line appears at `_computeThreshold_trials.m:81`, `computeThreshold_texture_exponent.m:87`, and `_computeThreshold_steve.m:73`.
- [ ] 🔴 **B1.8.** **`classify_normals` silently discards `'eff'` and `'precision'`.** **[ran]** `IntClassNorm/classify_normals.m:248` sets `parser.KeepUnmatched = true`, and its parameter list at `:251-267` has no `eff` and no `precision` — only `d_scale`/`d_scale_type`. So `'eff',0.34` in `+general/fit_edge_model_with_exps.m:48` **does nothing**. That script also comments out the post-hoc rescaling at `:204`, so the plotted "model" curve is the **unattenuated ideal observer**, not the 34 %-efficient one the code reads as intending. This is a figure in the paper.
- [ ] 🔴 **B1.9.** **`var_exp` compares the model against itself.** **[read]** `+general/fit_edge_model_with_exps.m:215-217` computes `mean_subj_acc` from `dprimes(:,2)` and `model_acc` from `vertcat(dprimes{:,2})` — both index column 2. Column 1 is the subject (used at `:182`); column 2 is the model. So the variable named `mean_subj_acc` holds model accuracy, and `var_exp` is a within-model dispersion ratio rather than a goodness of fit. This is the headline variance-explained number for the paper's model figure. Related, same file: `numel(~isnan(x))` at `:184` is a no-op, since `~isnan(x)` has the same size as `x`; the intent was `nnz`.
- [ ] 🔴 **B1.10.** **The efficient-coding bins are computed at a different sampling density than the stimuli they are applied to.** **[read]** `+general/compute_nat_img_eff_coding_bins.m:6` sets `ppd = 106` and `:62` passes it plus wavelength 555 into `vislab.lib.otf_filter`, while `config.m:27,29` declares 60 ppd and 550 nm. The bins therefore encode absolute gradient magnitudes at a sampling density the stimuli do not share, and this script is the head of the live model chain. The 550/555 split is already flagged in `CLEANUP.md` §8; the **106 vs 60** mismatch is not.

**Severity 2 — reachable, not silent**

- [ ] 🟠 **B2.1.** **The live experiment-setup path cannot find its data.** **[ran]** `+experiment/generate_camouflage_stimuli.m:2` and `setUpExperiment.m:47` do `load(['vislab-common/data/edge_powers/', exp_type, '.mat'], ...)`. That directory does not exist — not relative to the repo, not relative to the lab root. `git log -L2,2` shows the chain `global_data/` → `vislab_data/` (commit `fecbd73`) → `vislab-common/data/` (commit `4ac1908`): a mass rename moved ~40 path strings into a namespace that was never created, while the files actually live in the repo's own `data/edge_powers/`, whose layout matches `exp_type` exactly. A secondary failure survives fixing the directory: `data/edge_powers/natural/foliage.mat` contains `edge_powers` but **no `edgePowerBlockEdges`**, so `setUpExperiment.m:47` leaves that variable undefined and `:72` errors. Same class: `setUpExperiment.m:32` reads `vislab-common/data/images/<exp>.png`, but the source textures are at `../vislab-common/data/textures/natural/` and most are `.jpg`. Fixed structurally by S3.2.
- [ ] 🟠 **B2.2.** **`lib.edge_props_stim` errors on camouflage stimuli.** **[ran]** `Index in position 4 exceeds array bounds` at `+lib/edge_props_stim.m:162`. For `stim_type='camo'`, the default, `grads` is allocated 4-D at `:96` with no region dimension, so `grad_mags` is 3-D and `(:,:,i_scale,2)` is out of bounds. Only the `'tex'` branch is dimensionally consistent; the camo region split exists only in the commented block at `:78-89`. Since this function is the front end of the whole current model pipeline, **the model feature extraction cannot run as committed.** The same run confirmed two debug leftovers fire: a bare `randi(10)` at `:30`, which prints and **advances the RNG stream**, breaking reproducibility for any seeded caller, and `figure(1); imshow(stim)` at `:152-153`. Removing those two is S3.13; the dimension bug is this item.
- [ ] 🟠 **B2.3.** **`+lib/edge_energy.m` and `+lib/edge_shape.m` call `lib.steerable_grad` positionally.** **[ran]** `steerable_grad` is `addRequired('stim')` plus `addParameter`s, so `lib.steerable_grad(stim,[1 3])` gives `Expected a string scalar or character vector for the parameter name.` Confirmed by running both that call and `lib.edge_energy(stim,64,'center',[1 3],'mag')`. The fix is `,'kernel_size',kernel_size`. `edge_energy` additionally uses `dsp.Normalizer` at `:35` for `type='cos'`, which is **removed** from R2024b — `which dsp.Normalizer` is empty **[ran]**.
- [ ] 🟠 **B2.4.** **`lib.stimulus` output arity: three generators destructure it wrongly.** **[read]** The signature is `[stim, stim_b, seed, mask, ...]`, so `stim_b` is output 2 and `seed` is output 3. But `+experiment/generate_camouflage_stimuli_diff_bg.m:20,22` and `_texture_exponent.m:19,21` write `[stim,seed]=...`, and `_shape_exponent.m:20` writes `[stim,seed,mask,mask_edge,mask_normal,mask_strip]=...` — every output shifted by one. In `_shape_exponent`, `:28` then assigns a 512×512 matrix into one element of a preallocated array. The correct form `[stim,~,seed]` is used in `_all.m:17,19` and `setUpExperiment_search.m:64,66`.
- [ ] 🟠 **B2.5.** **`lib.stimulus` with only one of `ml_b`/`cont_b` errors.** **[ran]** `+lib/stimulus.m:149` guards with `||` but `:150` needs both, so `lib.stimulus('seed',1,'ml_b',0.5,'target_radius',64)` gives `Incorrect dimensions for matrix multiplication.` It should be `&&`, or each should default independently.
- [ ] 🟠 **B2.6.** **The `_texture_exponent` chain renamed `nLevels`→`nBlocks` and `seeds`→`stimuliSeed`.** **[read]** `+experiment/sessionSettings_texture_exponent.m:27` emits `nBlocks` with no `nLevels`, but `subjectExperimentFile.m:18`, `loadStimuliCamouflage.m:48` and `computeThreshold_texture_exponent.m:10` all read `ExpSettings.nLevels`. This is a regression: the on-disk `exp_files/texture_exponent/ecc_0/exp_settings.mat` *does* have `nLevels`, so it was generated by an earlier version of this file.
- [ ] 🟠 **B2.7.** **`SubjectExpFile.binIndex` does not exist.** **[read]** `+experiment/loadCurrentSession.m:35` reads it on the five-argument "redo a specific level" path, but `subjectExperimentFile.m:22-29` never creates it — confirmed against a real subject file **[ran]**. The default two-argument path is unaffected.
- [ ] 🟠 **B2.8.** **`+experiment/generate_camouflage_stimuli_all.m:33,40` — struct field mismatch.** **[read]** `textures` is declared with 4 fields, but `texture_list` on disk now has 8, four `acc_*` fields having been appended by later analysis, giving `Subscripted assignment between dissimilar structures.`
- [ ] 🟠 **B2.9.** **Fifteen package-qualified references resolve to nothing, across 41 call sites in in-scope files.** **[ran]** Measured by a `which()` sweep after `setup`, over the 164 in-scope files only, with comments stripped. `tinker.filter` 11 sites (all in `+tinker/whitening_tinker.m` — it looks like a find-and-replace artifact over bare `filter(` calls); `lib.circular_mask` 7; `lib.whiten_pink_noise_square` 7; `analysis.computeThresholdInBin` 4 (no top-level `+analysis` package exists); `lib.edge_vector` 2; `lib.compute_dPrime_pCorrect` 2; and one each of `analysis.computeTemplateResponseSigma`, `analysis.compute_dPrime_pCorrect`, `experiment.analysis.computeThreshold_new_edge`, `experiment.show_image` (**`vis.show_image` exists** — a one-word fix), `lib.gammaCorrect`, `lib.new_edge`, `lib.pink_noise_2d`, `nm.analysis.fitPsychometric`, and `stats.computeSceneSimilarityAmplitude`. That last one is **new damage from the `_` rename** — `+tests/gaborSimilarity.m:42` used to resolve and no longer does; it is handled by S3.6. `CLEANUP.md` §3 already lists several of the `lib.*` ones as deliberately left alone. Note that the whole-repo count is much larger: `lib.edge_vector` alone has ~31 further call sites inside the `_`-prefixed dead files.
- [ ] 🟠 **B2.10.** **`levelCompleted` is incremented rather than set.** **[read]** `+experiment/saveCurrentLevel.m:20-22` does `levelCompleted(...) = levelCompleted(...) + 1`, so a five-argument re-run of an already-completed level overshoots the true count.
- [ ] 🟠 **B2.11.** **Hardcoded absolute paths on other people's machines.** `+experiment/+analysis/computeBootstrappedThreshold.m:37,41` reference `/Users/steve/Dropbox/...` and `C:\Users\sebastian\Dropbox\...`. Already recorded in `CLEANUP.md` §4 as deliberately left stale; carried here so it is not lost.
- [ ] 🟠 **B2.12.** **`lib.stimulus` with `target_radius = 0` and more than three outputs errors** **[ran]** — `mask` through `wn_t` are never assigned on that branch (`+lib/stimulus.m:158,204`). Reachable from any caller that asks for the mask outputs on a blank stimulus.
- [ ] 🟠 **B2.13.** **`lib.stimulus`'s target branch tests the *background* texture struct to decide how to build the *target*.** **[read]** Found in tranche 0.1.1. Pre-edit `+lib/stimulus.m:159` asks `~isfield(texture_bg,'img')||isempty(texture_bg.img)` to decide whether the target is a synthesised texture or an image reference, and `:186` branches on `strcmp(texture_bg.type,'crop')` inside a block whose own `if` at `:166` already tested `texture.type`. Compare the background branch at `:101`, which correctly consults `texture_bg`. So a call giving an image-referenced `texture` and a plain pink-noise `texture_bg` takes the synthesis branch at `:160-164` and then errors in `textureSynthesis(texture.stats, ...)`, because `.stats` was never computed. Same family as B1.4 (`:182-184`), which is the silent half of the same confusion; this entry is the half that errors. Both are in the `_diff_bg` path, which was run.
- [ ] 🟠 **B2.14.** **`lib.compute_pClipped` always says "boundary ribbon".** **[read]** `+lib/compute_pClipped.m:6` warns `'%.2f%% of boundary ribbon clipped\n'` whatever it is handed, but the function is a general clipping fraction and is called on whole stimuli. Display-only, hence severity 2. Noted in the tooling entry (section 4.1.3, step 0) as "a header/message wording fix, well inside Stage 1" — **that was wrong**: the text is a string literal and therefore part of the syntax tree, so `canon` sees it change and Stage 1 forbids it. It is filed here instead.
- [ ] 🟠 **B2.15.** **`lib.cropImage`'s always-overridden `indColorChannels` (B3.2) is reachable in display code, not just latent.** **[read]** Found in tranche 0.1.3. `+lib/cropImage.m:21` (pre-edit numbering) tests `~exist('indColorChannel','var') || isempty(indColorChannels)` — missing the trailing `s`, so the guard is always true and `indColorChannels` is always overwritten to `1:size(source_image,3)`. `+vis/examplePatches.m:43`, `+vis/presentpatches.m:28` and `+vis/viewpatches.m:39` all pass `indColorChannels = 1` explicitly, intending a single colour channel, and get every channel instead. Confined to `+vis/` display scripts, so severity 2 rather than 1. Filed as its own item rather than relabelling B3.2, per the plan's re-filing rule — B3.2 stays as originally recorded.
- [ ] 🟠 **B2.16.** **`+experiment/+main/testscripts/runsingletrialTest.m` references an undefined variable and errors immediately if run.** **[read]** Found in tranche 0.1.4. Line 18 (pre-edit numbering) does `Screen('Flip', w)` and line 20 `experimentStruct.window = w`, but the window handle opened two lines above is stored in `window`, not `w` — `w` is never assigned anywhere in the script. Running this ad-hoc scratch script as-is throws `Unrecognized function or variable 'w'` at the first `Screen('Flip', w)` call, before anything else in the file executes. Not previously documented; the file is not on any live path (it is one of two ad-hoc scripts in `testscripts/`, never called from anywhere else in the tree), so it errors loudly rather than corrupting anything — hence severity 2, not 1.
- [ ] 🟠 **B2.17.** **`+experiment/+analysis/plotThresholdvsCondition_mine.m` references an undefined variable `dur` and errors immediately if run.** **[read]** Found in tranche 0.1.5. The script's only statement of consequence, `errorbar(dur(:,1),dur(:,2),dur(:,3),...)`, reads `dur` from the calling workspace; nothing in the script or anywhere else in the repo assigns it. Running this ad-hoc, personal ("_mine") scratch script directly throws `Unrecognized function or variable 'dur'` immediately. Same class as B2.16 — an ad-hoc script with no callers, so it errors loudly rather than corrupting anything.

**Severity 3 — latent**

- [ ] 🟡 **B3.1.** **`+lib/edge_props_stim.m:21` calls `lib.target_mask()` with no arguments**, so it always builds a 256×256 mask of radius 64 regardless of the input image, and `:129` hardcodes `reshape(...,[256,256,5,2])`. Currently correct by accident, because every stimulus in the repo is 256×256 with radius 64; it would silently mis-analyse the first stimulus of any other size.
- [ ] 🟡 **B3.2.** **`+lib/cropImage.m:21`** tests `~exist('indColorChannel','var') || isempty(indColorChannels)` — the first name is missing its trailing `s`, so the channel argument is always overridden. Separately, `:33-35` swaps row and column patch sizes for a non-square `patchSize`.
- [ ] 🟡 **B3.3.** **`+lib/ptch_norm.m:15-16` — undefined variable `m`.** **[ran]** `lib.ptch_norm(rand(64),128,0.2,2)` gives `Unrecognized function or variable 'm'.` The `ntype==2` branch, which normalises mean *and* contrast, is broken. Known and documented in `CLEANUP.md` §2; `vislab.lib.ptch_norm` is the corrected version but has a different signature. This repo's only caller passes a variable `ntype`, so it is safe only while that is never 2. Resolved by S3.11.
- [ ] 🟡 **B3.4.** **`+experiment/+analysis/computeTemplateResponseSigma.m:44`** writes `if(size(patchIndexCurr{iLum, iCon, iSim} < 300))`. The comparison is *inside* `size()`, so this is `size(logical_array)`, always a positive vector, so the condition is always true and `smallSample` is always set; it should be `numel(...) < 300`. MATLAB's own linter flags it (`ELARLOG`). Related, same file `:42`: `for iSim = 1:size(tSigma,1)` iterates the third loop index over the size of dimension 1 rather than dimension 3 — possibly harmless if those dimensions happen to match, *unverified*.
- [ ] 🟡 **B3.5.** **`+lib/find_spot_centers.m:7` uses `ismember(...,'row')`** — the valid flag is `'rows'`, so the row-wise membership test silently does something else.
- [ ] 🟡 **B3.6.** **`+lib/hyperexp_nll.m` fits the *hypo*exponential density** (the sum of two exponentials), not the hyperexponential (a mixture). The name and the docstring disagree with the code; decide which is intended.
- [ ] 🟡 **B3.7.** **`+experiment/sessionSettings.m:40` — stray transpose** in `strcmp(transformExpName','')`.
- [ ] 🟡 **B3.8.** **`+experiment/loadStimuliCamouflage.m:34` sets `pixelsPerDeg = ExpSettings.monitor_distance`.** The field is *named* distance but holds 60 pixels per degree (`setUpExperiment.m:22`), so the code is correct today and the name is a trap. Rename the field only with a migration script (zone 3, S3.10).
- [ ] 🟡 **B3.9.** **`+experiment/+analysis/computeThreshold_edgeResponse.m:1` declares `function [...] = computeThreshold(...)`** while the file is `computeThreshold_edgeResponse.m`. MATLAB uses the filename, so it works, but it is an unfinished rename (linter `FNDEF`).
- [ ] 🟡 **B3.10.** **Undefined-variable blocks.** All **[read]**: `+experiment/+analysis/computeThreshold_edgeResponse.m:102-132` (`exp_values`, `a`, `b`, `c`, `target_means`, `target_sds`, `threshold`); `+general/compute_nat_img_eff_coding_bins.m:123` (`pca_coeffs`, used about 20 lines *before* it is computed at `:144`, with the alternative `load` at `:26` commented out) and `:283` (`pca(rgb)` where `rgb` is all-NaN because its only write at `:74` is commented out).
- [ ] 🟡 **B3.11.** **About 15 top-level scripts in `+general/` depend on workspace variables they never define** — `ExpSettings`, `SubjectExpFile`, `edge_powers`, `texture_list`, `seed_energy`, `centers`, `alphas`, and others. Opening one and pressing Run always fails. The individual files were not enumerated in the original survey; enumerating them is part of S3.7.
- [ ] 🟡 **B3.12.** **Bugs inside the `_`-prefixed dead files**, recorded so that reviving one does not reintroduce them unnoticed. `+stats/_loadStatisticsSettings.m:59,60,119,180` hold absolute paths (`D:\sebastian\natural_images\...`, `~/occluding/...`) that make `+stats` **silently produce an all-zeros `ImgStats`** rather than erroring, because `dir()` on a missing path returns empty — these are *not* in `CLEANUP.md`. `+general/_compute_edges.m:152,157,160,165,194,250` and `_compute_edge_strengths_multiscale.m:113-121` pass `'type','samp'` where the parameter is `input_type`, so it silently falls back to `'norm'` and sample matrices are interpreted as distribution parameters; `'bplot',false` at `_compute_edges.m:194` should be `plotmode` and opens 501 figures. `_fit_edge_model.m:184` uses `sqerr`, whose only assignment at `:160` is commented out, so cell 1 dies at its last line after about 20 minutes of work. `_fit_edge_model_old.m` has at least 11 undefined variables including `bBootstrap` on its live path. `_computeThreshold_trials.m:87-96` uses undefined `hit` and `correct_reject` and makes a 9-input/4-output call to an 8-input/3-output `fitPsychometric`. Worst of all, `+general/_changepower.m:17-18` **overwrites `exp_settings.mat` and a subject file in place with no backup** while `edge_powers` is never loaded (`:5`).

- [ ] 🟡 **B3.13.** **`lib.edge_measures` builds its default boundary ribbon from a hardcoded image size.** **[read]** Found in tranche 0.1.1. `+lib/edge_measures.m:6` calls `lib.target_mask()` with no arguments to supply the default for the `'bdry_strip'` parameter, so that default is always a 256-pixel image with a 64-pixel-radius circular target, whatever `stim` actually is — the same failure mode as B3.1 in `edge_props_stim.m`, and correct today only because every stimulus in the repo happens to be 256/64. It is also evaluated on **every** call, including calls that pass `'bdry_strip'` explicitly and throw the result away.
- [ ] 🟡 **B3.14.** **`lib.target_mask` swaps row and column in the non-circular branch.** **[read]** Found in tranche 0.1.1. Pre-edit `+lib/target_mask.m:45-46` does `[x,y]=meshgrid(1:bg_size)` — so `x` is the column index — and then `cart2pol(x-mask_center(1), y-mask_center(2))`, pairing the column with `mask_center(1)`. The circular branch at `:34` pairs `mask_center(1)` with the **row** (`norm([i,j]-mask_center)`). For an off-centre non-circular target the mask is therefore displaced to the transposed location. Latent because `target_loc` is `'center'` everywhere in the repo, where both components are equal. A second, harmless consequence of the same swap: theta runs the opposite way round for a noisy target than for a circular one, which only relabels a noise realisation.

- [ ] 🟡 **B3.15.** **`lib.edge_props_stim` computes the PCA rotation and throws it away, so `'pca_coeffs'` has no effect.** **[read]** Found in tranche 0.1.2. Pre-edit `+lib/edge_props_stim.m:121-131` builds `grads_pca` and never writes it back into `grads`; the very next live line, `:143`, reduces the **unrotated** `grads`. `checkcode` confirms it (`NASGU` at `:130`, "value assigned might be unused"), and the commented-out predecessor at `:112-118` ends with the assignment that is missing here (`grads=grads_pca;` at `:117`), so this looks like a rewrite that dropped its last line. Filed at severity 3 rather than 1 only because the function cannot currently reach a correct return at all: with the default `stim_type='camo'` it errors at the histogram loop (B2.2), and no caller uses `'tex'`. **Fixing B2.2 promotes this to a silent severity-1 fault**, so the two must be fixed together. Separately, the deployed `data`/`edge_props_pca.mat` was produced by some earlier version of this file and it is *unverified* whether that version rotated the gradients — check before trusting any PCA-basis model number.
- [ ] 🟡 **B3.16.** **`experiment.main.stimulusInterval` returns a value labelled "onset" that is actually captured at stimulus offset.** **[read]** Found in tranche 0.1.4. `+experiment/+main/stimulusInterval.m:41` (pre-edit numbering) does `[~, StimulusOnsetTime] = Screen('Flip', ...)` right after the stimulus is drawn — this is the genuine onset flip. But the same variable is overwritten at `:52` by a second `Screen('Flip', ...)` that blanks the stimulus (after the `WaitSecs`/`FillRect` in between), and it is *that* second value the function returns as `stimulusOnsetMs`. So the return value is really the stimulus's offset time, not its onset. Filed as latent rather than reachable-and-silent because S3.17 already notes the caller (`vislab.psychframework.run_experiment`'s `hooks.stimulus`) discards this return value entirely on the current live path — so nothing downstream is corrupted today, but anyone who starts consuming `stimulusOnsetMs` for real timing analysis (exactly the concern S3.17 raises about the retired `runTrial.m`) would get the wrong timestamp under a name that says otherwise.

**Recorded and disproved.** For the record, one plausible-sounding hypothesis is *false*: `edge` called unqualified inside `+lib/detect_edge_pixels.m:20` and `+lib/edge_measures.m:18` does **not** resolve to `lib.edge`. `lib.detect_edge_pixels(stim)` runs correctly and returns 1814 edge pixels **[ran]** — MATLAB resolves it to the Image Processing Toolbox `edge`. Do not "fix" these call sites.

Stage 4's work log (section 4.4) fills in as each item here is actually fixed.

</div>

</details>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">1. Scope and measurements</h2></summary>

<div style="margin-left:1.5em">

Every number in this section was measured on the repo as it stands, under **MATLAB R2024b**, not estimated. Re-measure before trusting any of them after substantial changes.

**Scope, precisely.** The repo holds **193 `.m` files** outside the vendored tree: 188 in the package folders and 5 at the root. Two groups are excluded. `por_sim_tx_synth/` is vendored third-party Portilla–Simoncelli code and is out of scope entirely. The **29 `_`-prefixed files** are known-dead and are excluded too — cleaning code that is about to be quarantined or deleted is wasted effort. Those 29 are 12 in `+stats/` (the whole package), 10 in `+general/`, and 7 in `+experiment/+analysis/`; they were renamed in place with a leading `_` so they sort to the top of every folder listing, and because MATLAB cannot resolve a package-qualified name beginning with `_`, they are no longer callable even from each other. If any of them is ever un-prefixed and brought back to life, it re-enters this pass's scope at that point like any other file.

That leaves **164 files and 10,212 lines** in scope, of which 7,554 are code lines and 2,659 are comment lines.

| Directory | In-scope files | In-scope lines | Excluded (`_`-prefixed) |
|---|---|---|---|
| `+lib/` | 56 | 2,967 | 0 |
| `+experiment/` (top level) | 26 | 1,390 | 0 |
| `+experiment/+main/` (incl. `testscripts/`) | 11 | 714 | 0 |
| `+experiment/+analysis/` | 12 | 787 | 7 |
| `+general/` | 31 | 2,474 | 10 |
| `+stats/` | 0 | 0 | 12 |
| `+vis/` | 8 | 377 | 0 |
| `+tinker/` | 13 | 1,040 | 0 |
| `+tests/` | 2 | 107 | 0 |
| root | 5 | 356 | 0 |
| **total** | **164** | **10,212** | **29** |

**The work is far more concentrated than the file count suggests.** 41 in-scope files are under 25 lines and 81 more are under 75, while the **8 files of 150 lines or more hold 2,503 lines — 25 % of all in-scope code**. Those eight are `+lib/edge_props_stim.m` (535), `+tinker/pink_noise.m` (366), `+general/compute_nat_img_eff_coding_bins.m` (355), `+general/fit_edge_model_with_exps.m` (309), `+tinker/whitening_tinker.m` (283), `+lib/stimulus.m` (252), `+general/plot_contour_props.m` (213), and `+experiment/+main/runCamouflageExperiment_search.m` (190). Batch the small files aggressively; budget real time for these eight.

**What is actually wrong with the files**, measured, not assumed:

- **Lint.** `checkcode` over the 164 in-scope files reports **222 messages**, and **90 of 164 files are clean**. They split by stage: *Stage 1/2 mechanical (~117)* — `NOPTS` 37, `AGROW` 30, `NOSEMI` 20, `SAGROW` 19, `LOAD` 9, `ISCL` 5, `LOGSUM` 3, `NANMEAN`/`NANSUM` 4, plus `NCOMMA`/`NOCOMMA`/`NOPRT`/`NBRAK2` singletons. *Needing judgement (~44)* — `NASGU` 24 (value assigned but never used), `ASGLU` 12, `INUSD` 5, `USENS` 3, `STRNU` 1; each is either a leftover or a real logic gap, so decide per site. *Bug signals, Stage 4 (~40)* — `STOUT` 22 (return value may be unset), `PFBNS` 6, `GVMIS` 3, `NODEF` 2, and one each of `DSPNORM`, `ELARLOG`, `FNDEF`, `FXSET`, `PFTUSE`, `PFUIXW`, `BDLGI`, `EXIST`, `FNDSB`, `HIST`. Record these, do not fix them.
- **Formatting.** 19 in-scope files are tab-indented; **718 lines carry trailing whitespace**. 45 files have at least one line over 100 characters; the worst concentrations are `+lib/edge_props_stim.m` (13 lines), `+vis/edge_strength_dists.m` (12), `+general/fit_edge_model_with_exps.m` (12), and `+experiment/+main/runCamouflageExperiment_search.m` (11).
- **Spacing consistency — this is the bulk of the mechanical work.** Of the code lines containing an assignment, **2,309 are unspaced (`a=b`) against 1,102 spaced (`a = b`)**, so roughly two thirds of the repo is written in the tight style and the file-to-file split is real, not uniform. Commas are the same story: **1,888 lines have a comma with no following space against 815 that do**. There are also 659 lines with unspaced binary operators (`a+b`) and 137 comment lines with no space after the `%`. Indentation is not uniform: 19 files use tabs, the rest mostly 4 spaces.
- **Header docs.** Of the 164 in-scope files, 116 begin with a `function` line. Only **39 have any `Inputs`/`Output` block** and only **18 have a `See also`**; 33 files have no header comment at all. There is **no `Contents.m` anywhere in the repo** — the shared library has one, and each package touched should gain one.
- **Names.** This is the real problem. The most-used opaque identifiers, by occurrence count across in-scope code (comments and string bodies stripped): `stim` 157, `x` 150, `d` 94, `seed` 82, `n` 73, `cont` 62, `ml` 59, `N` 56, `S` 52, `z` 51, `len` 51, `idx` 49, `y` 47, `r` 47, `c` 43, `a` 37, `mask` 35, `p` 34, `u` 33, `img` 33, `f` 29, `th` 24, `b` 24, `e` 23, `amp` 22, `ppd` 21. `+lib/` additionally carries `XX`/`YY` (14 each), `mnv` 14, `grad` 14, `haar` 12, `filt` 9, `wn` 9, `wnf` 6, `N_b` 11. The low-count but genuinely unreadable ones are all in `+lib/`: `nhood` (`local_sd.m:16`), `ntype` (`ptch_norm.m:1`), `xo`/`yo` (`radialavg.m:1`), `sd` (`laplacian_of_gaussian_filter.m:1`), `dc` (`cosdRadial.m:1`), `m0`/`c0` (`ptch_norm.m:1`).
- **Names diverge across call boundaries.** Concretely: `+general/compute_nat_img_eff_coding_bins.m:73` passes `patch_rgb` into a parameter named `ptch` (`+lib/ptch_norm.m:1`) and catches the returned `ptchout` as `ptch_rgb` — three names for one quantity in one statement. `+experiment/setUpExperiment_search.m:67` passes `'bg_size', Stimulus.stimulus_sz` and `'ml_b', Stimulus.ml`, so the same two quantities are `stimulus_sz`/`ml` on the caller side and `bg_size`/`ml_b` on the callee side. `+tinker/pink_noise.m:69` calls `lib.radialavg(img_corr,100)` against parameters named `z, m`.
- **Convention splits.** The repo is broadly `snake_case` in `+lib/`, `+general/`, `+tinker/` and `camelCase` in `+experiment/` (including both sub-packages), which follows the Psychtoolbox heritage of that directory. This split is deliberate enough to keep: **do not convert `+experiment/` to snake_case in this pass.** Harmonise within each directory instead.
- **Builtin shadows.** `mask` is declared 18 times (e.g. `+lib/correlations_across.m:1`, `+lib/edge.m:42`); `filter` 12 times, including as a name-value parameter at `+lib/steerable_grad.m:8`; `contrast` 8 times (`+experiment/sessionSettings.m:1,43`); `edge` 7 times — `+lib/edge.m:1` is a whole function shadowing the Image Processing Toolbox `edge`, which is exactly why the "disproved" note in section 0.4 matters; `alpha` 4 times (`+experiment/generate_camouflage_stimuli_shape_exponent.m:14,20`); `type` twice (`+lib/edge_energy.m:1,10`); `output` twice (`+lib/find_spot_centers.m:1`). Clean: `length`, `image`, `diff`, `sum`, `size`, `max`, `min`, `mean`, `hist`, `line`, `power` are never declared as variables in scope.
- **Commented-out code — this is the single biggest readability problem.** 2,659 of the in-scope lines are full-line comments, and **780 of those are commented-out code**, about 29 % of all comments and 9 % of all non-blank lines. By directory: `+general/` 297, `+lib/` 282, `+experiment/` 116, `+tinker/` 55, root 18, `+vis/` 12, `+tests/` 0. **81 of the 164 files carry at least one dead-code line**, and `+lib/edge_props_stim.m` alone holds 197 of them. It is also the main reason nobody can tell which edge measure is live — the contour-group code that `+general/compute_edge_group_measures.m` still calls for is commented out at `+lib/edge.m:115-134` (B1.5), and the write that the dead per-trial threshold fitters need is commented out at `+experiment/saveCurrentLevel.m:24-33`. **This pass removes none of it**; the block-level inventory is in section 4.1.4 and feeds the triage there.
- **Argument validation.** There are **no `arguments` blocks anywhere** in the repo. 9 files use `inputParser`. Converting changes validation behaviour, so it is Stage 3 (S3.12), not part of this pass.

**The style target already exists** — do not invent one. `../vislab-common/+vislab/+lib/` is the same author's cleaned code and is the normative reference, and `watson_otf.m` there is the exemplar: an uppercase `FUNCTION_NAME` summary line, the fully-qualified call signature, `Inputs` and `Output` blocks **with units**, a note on the domain where the result is undefined, a `See also`, then a body with descriptive names (`cutoff`, `diffraction` rather than `u0`, `D`) and short end-of-line comments only where the *why* is non-obvious. `vislab-common/+vislab/+lib/Contents.m` is the model for the per-package `Contents.m` files this repo lacks.

**Filename collisions with the shared library:** exactly two, both in `+lib/`. `+lib/ptch_norm.m` and `+lib/watson_otf.m` are the *uncleaned ancestors* of `vislab.lib.ptch_norm` and `vislab.lib.watson_otf` — the shared `ptch_norm` header even describes this repo's copy as "the buggy root +lib copy". **Do not clean either of them.** Polishing a copy that is already superseded elsewhere just makes it look maintained; the right move is to repoint callers and delete them, which is S3.11. No other in-scope file shares a name with anything in `vislab-common`.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">2. The check (Stage 1) and what the repo affords for Stage 2</h2></summary>

<div style="margin-left:1.5em">

`mtree` parses a `.m` file into MATLAB's own syntax tree, and `tree2str` prints it back in canonical form: comments stripped, whitespace and bracket spacing normalised, missing `end` supplied.

```matlab
canon = @(f) tree2str(mtree(f,'-file'));
```

This gives a fingerprint blind to exactly what Stage 1 is allowed to change and sensitive to everything else. **Verified: `canon` succeeds on all 164 in-scope files** — including the substantial fraction that cannot execute, which is the property golden-output testing cannot give you, and the reason this whole plan is organised around `canon` rather than around running the code.

Reverse-rename check: clean a file (renames, header, reflow), then undo the rename map on the canonical form of the new file and assert it is identical to the canonical form of the old one:

```matlab
c_new = canon(new_file);
for k = 1:size(renames,1)   % renames = {new_name, old_name}
    c_new = regexprep(c_new, ['(?<![A-Za-z0-9_.])' renames{k,1} '(?![A-Za-z0-9_])'], renames{k,2});
end
isequal(canon(old_file), c_new)   % must be true
```

The lookahead `(?![A-Za-z0-9_])` matters: without it a short name (`patch`) can wrongly match inside a longer one (`patch_size`). The lookbehind's `.` matters just as much here, because it is what excludes dot-qualified names — see the struct-field caveat in section 4.1.1. The rename map itself must be a bijection with disjoint domain and range; assert this before using it:

```matlab
dom = renames(:,1); ran = renames(:,2);
assert(numel(unique(dom)) == numel(dom));
assert(numel(unique(ran)) == numel(ran));
assert(isempty(intersect(dom, ran)));
```

A trial run of this check on `+lib/local_sd.m` during an earlier survey earned its keep immediately: cleaning that file (header doc, comments, reflow, and renaming `nhood`→`disc_mask`, `filter_size`→`mask_size`, `i,j`→`row,col`) produced a canonical form byte-identical to the original after reverse renaming, and along the way the check caught two swapped statements that were harmless but unintended, and that no reviewer would have noticed in the diff.

Caveat: `mtree`/`tree2str` are undocumented MATLAB APIs — stable across many releases, but **pin the MATLAB version in every commit that depends on the check**. This plan was built under R2024b.

**Stage 2's extra requirement: runtime golden output.** This repo executes only in part, and the harness surface is genuinely narrow. What it *can* cover, verified by running each with synthetic inputs under R2024b: `lib.stimulus` (self-seeds with `rng('default'); rng(seed)` at `+lib/stimulus.m:82-83`, verified bit-identical across two calls with the same seed), `lib.edge`, `lib.edge_vector_ideal`, `lib.edge_measures_ideal`, `lib.steerable_grad`, `lib.steerable_filter`, `lib.local_sd`, `lib.target_mask`, `lib.create_pink_noise_square`, `lib.whiten`, `lib.compute_pClipped`, `lib.autocorr`, `lib.csf_fitted`, and the three psychometric functions `experiment.analysis.psychometricFun`, `computeNegLogLikelihood`, and `fitPsychometric` (deterministic, `fminsearch`). Note that `lib.create_pink_noise_square` and the non-circular branch of `lib.target_mask` call `normrnd` and **do not self-seed**, so the harness must seed before each call itself.

**What cannot be covered, and is therefore pattern-check only** — this is a deliberate, recorded decision, not an oversight. `+general/`: 40 of its 41 files are top-level scripts with no arguments that assume workspace variables already exist, and several `save()` into `vislab-common/data/`. `+tinker/`: 8 of 13 are scripts, and several call the missing `lib.whiten_pink_noise_square` or the broken `lib.edge_energy`. `+experiment/+main/`: all 9 functions are Psychtoolbox, eye-tracker, or display bound. `+experiment/` top level: functions, but they take an `ExpSettings` struct and write into `exp_files/`, and three of them are broken (B2.4). `+vis/`: plotting, three of them scripts. `+experiment/+analysis/`: everything beyond the three psychometric functions needs loaded session `.mat` files. `+tests/`: two ad-hoc scripts, not a harness. Restructuring any of these into callable functions is itself Stage 3 (S3.7), so it cannot be done to make Stage 2 verifiable.

**`parfor` baseline: all 16 loops are sliced, none is a reduction.** Verified by reading every loop body. Each writes `out(idx,...)` or `out{idx,...}` with the loop variable in the index, so worker order cannot change a floating-point sum and they are safe to leave alone. The sites are `+lib/autocorr.m:8`; `+experiment/generate_camouflage_stimuli.m:33`, `_diff_bg.m:17`, `_shape_exponent.m:13`, `_texture_exponent.m:16`; `+general/compute_edge_group_measures.m:16`, `compute_edge_powers_camo.m:37`, `compute_edge_powers_camo_large.m:37`, `compute_noise_colour.m:24` and `:81`, `video_demo.m:11`; `+tinker/pink_noise.m:285`, `pink_noise_seed_multiple_energies.m:21`, `pink_noise_stimuli_autocorrelations.m:27`, `whitened_pn_stim_edge_energy.m:21`, `whitening_tinker.m:188`. Two oddities worth recording rather than fixing: `compute_noise_colour.m:81` has **no output at all** — its body only plots, and plotting inside a `parfor` is a no-op — and `video_demo.m:13` calls `rng('shuffle')` once per iteration, making that loop nondeterministic by design and therefore permanently outside any golden harness. **An edit that later turns any of these slices into an accumulator is a behaviour change**, and belongs in Stage 3.

**The four Stage 2 patterns, sized.** Missing suppressing semicolons: `NOSEMI` 20 (expect most apparent hits to be a trailing `%` comment after an already-present `;`). Unpreallocated growth: `AGROW` 30 plus `SAGROW` 19, many already carrying an author-written `%#ok<AGROW>`, i.e. known and suppressed rather than fixed. `find(...)` that could become logical indexing: 16 call sites, most of which will *not* be targets, since a numeric index used to index a second array, printed in a label, or used as a scalar bound is not convertible. Unused assignments: `NASGU` 24. Separately, `nanmean`/`nansum` appear at 4 sites (`+lib/edge.m:102`, `+lib/edge_vector_ideal.m:80`, `+tinker/pink_noise_stimuli_autocorrelations.m:60,62`); the first two are passed as `@nanmean` into `groupsummary`, so replacing them means writing `@(x) mean(x,'omitnan')` — a real AST change, hence Stage 2 with its own whitelisted pattern, not Stage 1.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">3. Four stages of change, in full</h2></summary>

<div style="margin-left:1.5em">

| Stage | Change | Canonical diff | Verification |
|---|---|---|---|
| **1** | Comments, header docs, whitespace, operator and bracket spacing, indentation, reflow, blank-line grouping, file-local renames, triaging commented-out code (verdicts only, no deletion) | empty (after reverse rename) | `isequal` — fully automatic, no execution |
| **2** | Adding a suppressing `;`, preallocation, `find`→logical indexing, deleting a provably unused assignment | non-empty but must match a whitelisted pattern | pattern check **plus** runtime golden output |
| **3** | Signature changes, adding `arguments` blocks, merging duplicate functions, reordering statements, changing accumulation order in a float reduction, anything touching the RNG stream, **acting on the Stage 1 triage of commented-out code** | — | **not part of the behaviour-preserving pass** — reviewed and done individually, once Stage 1/2 is done |
| **4** | Bug fixes found anywhere during 1/2/3, each marked 🔴/🟠/🟡 | — | not mechanically checkable — reviewed and fixed individually in severity order, once Stage 3 is done |

Semicolon insertion is Stage 2, not Stage 1: `tree2str` preserves display-vs-suppress, so the canonical diff is exactly `X` → `X;` — trivially whitelisted, but not invisible. **A missing semicolon is sometimes deliberate** in this repo, because `+general/` and `+tinker/` are full of top-level scripts whose only way to print a number when run interactively is an unsuppressed line. `+general/fit_edge_model_with_exps.m:217` is exactly this case: `var_exp=...` with no semicolon is how the headline number reaches the console. Ask before "fixing" one on a line whose variable is never read again; if it is deliberate, add a comment saying so, so a later pass does not undo it.

Stage 3 matters most. The tempting changes are all Stage 3 — see section 0.3's list. Fixing B1.3 (`create_pink_noise_line` ignoring its exponent) *changes output*; so does S3.3's variant collapse and S3.7's script-to-function conversion. Every one of them changes output, call sites, or validation behaviour, so none belongs in the behaviour-preserving pass — keeping them out is what makes that pass's diff skimmable instead of line-by-line. They are the next step of the same overall cleanup, not abandoned.

When the pass uncovers a *bug* — and it will — **record it in section 0.4 first, marked with its severity emoji**, so the recording survives even before the fix happens; the fix itself comes later, as a Stage 4 item, kept separate from Stage 3 so the bug list never gets buried inside the structural-cleanup list. Even a 🔴 waits: the severity sets the fix order within Stage 4, it does not pull a fix forward or interrupt the tranche that found it. This is the single rule most likely to be violated under pressure, and this repo makes it tempting, because the survey has already turned up ten severity-1 items.

Statement reordering is kept out of Stage 1/2 even though it looks cosmetic, purely because the check cannot distinguish a safe reorder from an unsafe one — it gets the same individual review as the rest of Stage 3.

**Ordering against the Stage 3 items.** Two of them interact with the readability pass and should be sequenced around it rather than simply queued behind it. **S3.5 (the smoke test and the `which()` resolution sweep) is worth building early**, before or during tranche 0, because running the sweep after every tranche is what catches a rename that broke a call site — it is the cheapest safety net this repo can have, and it already exists in scratch form. **S3.3 (collapsing the variant families) and S3.7 (scripts into functions) should wait until after the pass**, because both are far easier to perform on clean, well-named code than on the current text, and doing them first would mean cleaning files that are about to be merged or rewritten. Everything else in section 0.3 is independent of the ordering.

**Practical notes for whoever runs this.** MATLAB runs headless here: `matlab -batch "cd('<repo>'); setup; <cmd>"`. `checkcode` is a cheap first-pass bug finder and is covered by the standing authorization, along with `canon`, `check_stage1`, `assert_rename_bijection`, and `golden_harness('replay', ...)`. Capturing a new golden reference, running the demo or driver scripts, and anything that does real image I/O or writes into `data/` all need asking first. The working directory must be the repo root, since every data path in the codebase is relative to it and `config.m` has no callers. Note that **scripts inside `+package/` folders are not callable as `package.name`** — most of `+general/`, `+tinker/`, `+tests/` and three files in `+vis/` must be opened and run, which is why they are pattern-check only. And assume any `+general/` script is stale until proven otherwise: the `+lib` API changed underneath it (`lib.stimulus` went name-value only, `lib.edge_measures` was repurposed, `lib.edge_vector` was deleted) and **most callers were never updated**. Finally, `exp_files/` is ~100 GB and gitignored — never `git add` it.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">4. Stage-by-stage details and work log</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">4.1 Stage 1 — renaming zones, tranches, and findings log</h3></summary>

<div style="margin-left:1.5em">

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">4.1.1 Renaming: three zones</h4></summary>

<div style="margin-left:1.5em">

The rename map is the pass's most valuable artifact and its main divergence risk — build it first, once, repo-wide, in tranche 0, and commit it before touching any file.

**Zone 1 — file-local variables. Free.** `canon` makes these completely safe, so this is where nearly all the value is. Three sub-jobs: expand the abbreviations listed in section 1 (`ml`→`mean_lum`, `cont`→`contrast_rms`, `th`→`theta`, `amp`→`amplitude`, `len`→`n_samples`, `img`→`image_data` or better, `wn`/`wnf`→`white_noise`/`white_noise_filtered`, `mnv`, `haar`, `filt`, `XX`/`YY`, and the `+lib/` one-offs `nhood`, `ntype`, `xo`/`yo`, `sd`, `dc`, `m0`/`c0`); name every loop counter for what it indexes rather than `i`, `j`, `n`; and fix the builtin shadows — `mask`, `filter`, `contrast`, `alpha`, `type`, `output`, and the local variable `edge` inside `+lib/edge.m`. Bare single letters (`x` 150, `d` 94, `z` 51, `r` 47, `c` 43, `a` 37, `p` 34, `u` 33, `b` 24, `e` 23) are the bulk of the count and should be renamed per file to whatever the quantity actually is; do not try to give one of them a single repo-wide expansion, because `d` means distance in `+tinker/` and a `d'` sensitivity in `+experiment/+analysis/`.

**Zone 2 — cross-file name-value parameters. Repo-wide, or not at all.** The public vocabulary is **37 distinct name-value parameter names across 55 declaration sites**, nearly all declared in `+lib/`. Renaming one means editing a string literal at every call site, which is a real AST change — so **this zone is deferred entirely to Stage 3 (S3.9)** and no Stage 1 tranche may touch it. The measured call-site counts, which are what decide whether each is worth doing:

| Parameter | Declared at | Call sites |
|---|---|---|
| `target_radius` | `+lib/stimulus.m:55`, `+lib/target_mask.m:8` | 34 |
| `texture` | `+lib/stimulus.m:51` | 24 |
| `ml_b` | `+lib/stimulus.m:59` | 23 |
| `cont_b` | `+lib/stimulus.m:60` | 23 |
| `bg_size` | `+lib/stimulus.m:49`, `+lib/target_mask.m:5` | 20 |
| `kernel_size` | `+lib/edge.m:34`, `edge_vector_ideal.m:10`, `steerable_grad.m:7` | 13 |
| `seed` | `+lib/stimulus.m:53` | 8 |
| `grad_mag_bins`, `grad_or_bins`, `grad_prod_bins` | `+lib/edge_props_stim.m:16-18` | 5 each |
| `pca_coeffs`, `edge_pixels` | `+lib/edge_props_stim.m:15,20` | 4 each |
| `target_loc` | `+lib/stimulus.m:57` | 4 |
| `ml_t`, `cont_t` | `+lib/stimulus.m:61,62` | 4 each |
| `mask` | `+lib/edge.m:30` | 3 |
| `mask_edge`, `mask_normal`, `target_shape` | `+lib/edge.m:31,32`; `+lib/stimulus.m:54` | 2 each |
| `normalize` | `+lib/steerable_grad.m:10` | 2 |
| `texture_bg` | `+lib/stimulus.m:52` | 2 |
| `bdry_strip` | `+lib/edge_measures.m:7` | 1 |
| `target_or` | `+lib/stimulus.m:58` | 1 |
| 13 declared but never passed: `n_edge`, `pad_val`, `target_radius_cont`, `edge_detection_filter`, `thresh`, `edge_kernel`, `stim_raw`, `stim_type`, `otf_ppd`, `grad_hist_thresh`, `nbins_grad_or`, `target_normal`, `filter` | various | 0 |

When S3.9 happens, the cheap and high-value ones are the scientifically meaningful names with four or fewer call sites — `target_or`, `bdry_strip`, `normalize`, `target_shape`, `ml_t`, `cont_t` — plus the 13 zero-call-site declarations, which can be renamed for free today. The expensive ones are `target_radius` (34), `ml_b`/`cont_b` (23 each), and `kernel_size` (13); do those in one commit or not at all, since a half-done rename is worse than none.

**Zone 3 — serialised names. Frozen.** These appear inside `save`/`load` string literals, so ~100 GB of collected human data depends on them. **The string literal cannot change**; a local variable that merely *holds* one of these can. The full set, enumerated from every `save`/`load` call in scope: `ExpSettings`, `SubjectExpFile`, `Stimulus`, `edge_powers`, `edgePowerBlockEdges`, `edge_props`, `seed_energy`, `stim_energy`, `d`, `corr_cross`, `corr_blank_cross`, `corr_target_cross`, `LLR_blank`, `LLR_target`, and `cdfs.mat`'s `ea, Na, eb, Nb, er, Nr, egm, Ngm, coeff`. Beyond those, **every field of `ExpSettings` (33 fields) and `SubjectExpFile` (8 fields) is frozen too**, and this is the trap the check will not catch for you: `check_stage1`'s regex excludes dot-qualified names, so renaming a local variable `edgePowers` while `ExpSettings.edgePowers` must stay produces a **clean pass and a mismatched codebase**. Where that happens, note the resulting local-vs-field mismatch in the file's header. Note also that `d` is frozen in `+tinker/pink_noise_stimuli_autocorrelations.m` and completely free in the 90-odd other places it appears — check the file, not the name.

**Units are the other half of naming.** State them in every header. This repo's conventions: `kernel_size` is `[sigma, n_sigma]` in **pixels**; `target_radius` is in **pixels**, while the paper reports degrees at 60 ppd; `ppd` is pixels per degree (60 for the stimuli, but 106 in `compute_nat_img_eff_coding_bins.m` — see B1.10); `wavelength` is nm and `pupil_diameter` is mm; `ml`/`cont` are mean luminance in [0,1] and RMS contrast as a fraction. And beware names that are already lies: in `+lib/local_sd.m` the variable called `filter_radius` is actually the *product* `kernel_size(1)*kernel_size(2)`, and `ExpSettings.monitor_distance` holds 60 pixels per degree (B3.8). That class of misnaming is exactly what this pass exists to fix.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">4.1.2 Tranches, sequencing, and model assignment</h4></summary>

<div style="margin-left:1.5em">

Batched by directory but sized by lines, because the distribution is so skewed: 122 of the 164 in-scope files are under 75 lines while eight files hold a quarter of the code. `+lib/` is split into three tranches so that the naming-critical core is settled by a strong model before the long tail is handled mechanically, and `+general/` into two for the same reason. `+stats/` does not appear at all — all 12 of its files are `_`-prefixed and out of scope.

The **Agent** column is what the orchestrator dispatches to, per the skill's "Dispatching tranches" section. Tranches run **in order, one at a time**, because each one's naming decisions bind the next. Dispatch `matlab-cleanup-mechanical` with an explicit `model: "sonnet"`; dispatch the three opus agents with no `model` parameter at all, so their frontmatter effort setting applies.

| # | Tranche | Files / lines | Agent | Why |
|---|---|---|---|---|
| 0 | Rename map + `canon`/`check_stage1`/`assert_rename_bijection` + golden harness | — | `matlab-cleanup-lead` | Every other tranche trusts this being right; a bug here silently invalidates every downstream `isequal` result |
| 1 | `+lib/` edge & stimulus core: `stimulus.m`, `target_mask.m`, `edge.m`, `edge_vector_ideal.m`, `edge_measures_ideal.m`, `edge_measures.m`, `edge_energy.m`, `edge_shape.m`, `edge_response.m`, `edge_fit_cost.m`, `steerable_grad.m`, `steerable_filter.m`, `local_sd.m`, `compute_pClipped.m` | 14 / 948 | `matlab-cleanup-lead` | **Sets the naming conventions for the whole repo.** These are the functions whose vocabulary every other directory borrows |
| 2 | `+lib/edge_props_stim.m` | 1 / 535 | `matlab-cleanup-lead` | Largest file in the repo, holds the largest commented-out block, and is the front end of the model pipeline. Needs judgement, not throughput |
| 3 | `+lib/` remainder (41 files, none over 125 lines) | 41 / 1,484 | `matlab-cleanup-mechanical` | One decision applied many times, once tranche 1 has fixed the vocabulary |
| 4 | `+experiment/+main/` incl. `testscripts/` | 11 / 714 | `matlab-cleanup-mechanical` | Psychtoolbox runtime; self-contained, camelCase, no cross-file naming to settle |
| 5 | `+experiment/+analysis/` | 12 / 787 | `matlab-cleanup-mechanical` | Psychometric fitting; the three golden-checkable functions live here |
| 6 | `+experiment/` top level, including the 15 near-duplicate variant files | 26 / 1,390 | `matlab-cleanup-lead` | The `{setUpExperiment, sessionSettings, generate_camouflage_stimuli} × 5` families need the *same* edit applied five times. Drift between the base file and a variant manufactures exactly the divergence S3.3 exists to remove. **Clean the base file first, then apply identical edits to the four variants, then diff base against variant to confirm** |
| 7 | `+general/` live model chain: `compute_nat_img_eff_coding_bins.m`, `compute_edge_props_exp_pca.m`, `fit_edge_model_with_exps.m`, `compute_nll_edge_model.m` | 4 / 833 | `matlab-cleanup-lead` | The only files feeding the paper's model figure, and the only function in `+general/`. Three of the ten severity-1 bugs live here |
| 8 | `+general/` remainder | 27 / 1,641 | `matlab-cleanup-mechanical` | Top-level scripts, no cross-file propagation risk |
| 9 | `+vis/` + `+tests/` | 10 / 484 | `matlab-cleanup-mechanical` | Plotting and ad-hoc scripts; no callers outside themselves |
| 10 | `+tinker/` | 13 / 1,040 | `matlab-cleanup-mechanical` | Large exploratory files with no callers — last, per the skill's sequencing rule |
| 11 | Root: `config.m`, `setup.m`, `edge_power_demo.m`, `test.m`, `test_Erlang.m` | 5 / 356 | `matlab-cleanup-lead` | The config file and the user-facing demo go late and get the strongest model |

**Escalation rule, any tranche:** if `check_stage1` fails and the cause isn't obvious from the diff — stop, don't retry with a bigger prompt, hand that one file to `matlab-cleanup-escalation`. Don't loosen the check instead.

**"Done" checklist for a Stage 1 tranche:**

- [ ] `check_stage1(old, new, renames)` true for every file, with the **verbatim checker output** pasted into the tranche's findings-log entry — a claim that it passed is not evidence.
- [ ] Every file has a header matching `watson_otf.m`'s shape: summary, fully-qualified signature, `Inputs`/`Output` with units, `See also`.
- [ ] Formatting harmonized per the skill's step 2b: `=` and binary operators spaced, space after commas, no space inside brackets, 4-space indent, no tabs, no trailing whitespace, one space after `%`.
- [ ] No line exceeds 100 characters except documented string-literal exceptions, listed per tranche in section 4.1.3 — each would require turning a string literal into a `horzcat` expression, a real AST change Stage 1 forbids.
- [ ] No zone-3 frozen identifier renamed, no `save`/`load` string literal changed, and any local-variable-vs-struct-field mismatch created by a rename noted in the file's header.
- [ ] No zone-2 name-value parameter renamed — that is deferred to S3.9.
- [ ] Each package touched has a `Contents.m`, following `vislab-common/+vislab/+lib/Contents.m`.
- [ ] `+experiment/` files stay camelCase and `+lib/`/`+general/`/`+tinker/` files stay snake_case — harmonise within a directory, do not convert between them.
- [ ] Every commented-out block in the tranche's files has a verdict in section 4.1.4, and nothing was deleted or converted on the strength of it.
- [ ] Bugs found are written into section 0.4 with a severity tag, and **not** fixed.

One commit per tranche, per the skill's Committing section, each stating the checker result and that it was run under MATLAB R2024b.

**Housekeeping to do first, in the tranche-0 commit:** create `tools/` and add the three checker scripts plus the golden harness; nothing else in this repo needs moving, since the only filename-conflict copies (`+lib/ptch_norm.m`, `+lib/watson_otf.m`) are being excluded from cleaning rather than relocated, and are dealt with by S3.11.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">4.1.3 Findings log</h4></summary>

<div style="margin-left:1.5em">

Prose entries, one per tranche, written as the tranche finishes and never retroactively tidied. Each records the naming decisions that bind later tranches and why, the documented line-length exceptions, which baseline the verification used (HEAD, or a pre-edit backup copy) and why, and anything deliberately left alone. A tranche that found nothing still gets an entry saying what was checked — that is the evidence it was examined.

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0 — tooling</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6** — the version string is printed by `version` and is what every `canon`-based result below is pinned to, since `mtree`/`tree2str` are undocumented. Commit: the tooling commit named in the git log.

**What was built.** Four files in `tools/`, none of which existed before:

- `tools/canon.m`, `tools/check_stage1.m`, `tools/assert_rename_bijection.m` — copied from the skill, repo-agnostic. The only edit made to the copies: their `See also` lines and one body comment referred to `CHECK_TIER_A`, a function that does not exist under that name any more, so those three references now read `CHECK_STAGE1`. This is a deliberate divergence from the skill's copies; re-apply it if they are ever re-synced.
- `tools/golden_harness.m` plus its captured `tools/golden_ref.mat` (1.3 kB, 32 fields). Both are committed, because the reference file is what `replay` checks against.

**`canon` verified on every in-scope file — 164 of 164 parse and print.** Verbatim output of the sweep (`canon` called on each file, with the vendored tree, the `_`-prefixed files and `tools/` itself excluded):

```
24.2.0.2923080 (R2024b) Update 6
in-scope files: 164
canon OK      : 164
canon FAILED  : 0
```

**Scope, re-confirmed while building the sweep.** A raw find turns up **166** non-vendored, non-`_`-prefixed `.m` files, not 164. The two extras are `Presentations, reports, abstracts/cps_intclassnorm_demo.m` and `Presentations, reports, abstracts/2025 VSS/pca_demo.m`. That whole directory is gitignored (`.gitignore:4`), so it is correctly out of scope and section 1's count stands — but the sweep has to exclude it by name, and so does any later file-list generator. Excluding it is not an oversight to be "fixed" by a later tranche.

**`check_stage1` self-tested before anything trusts it**, on `+lib/csf_fitted.m`, with a scratch copy carrying a realistic Stage 1 edit (header added, `n`→`n_terms`, `d`→`pupil_diameter`, `w`→`wavelength`, `u`→`spatial_freq`, `z`→`sensitivity`, `p`→`params`, the packed `n = 2; d = 4; w = 555;` line split one-per-line, and a `...` continuation introduced). Verbatim:

```
identical, no renames : 1
different file        : 0
renamed + reformatted : 1
one constant changed  : 0
bijection guard fires : a name appears on both sides of the rename map
```

The fourth line is the one that matters: changing `a = 0.8563` to `0.8564` and nothing else is caught. The third confirms the skill's claim that splitting packed statements and adding continuations round-trips clean.

**The golden harness covers 32 fields across 16 entry points**, called directly — never through `edge_power_demo.m`, which is the repo's demo driver. Covered: `lib.steerable_filter`, `lib.csf_fitted`, `lib.compute_pClipped`, `lib.create_pink_noise_square`, `lib.whiten`, `lib.target_mask` (both the circular and the filtered-noise branch), `lib.stimulus`, `lib.steerable_grad`, `lib.local_sd`, `lib.edge`, `lib.edge_vector_ideal`, `lib.edge_measures_ideal`, `lib.autocorr`, and `experiment.analysis.psychometricFun` / `computeNegLogLikelihood` / `fitPsychometric`. Everything else is pattern-check only, per the decision already recorded in sections 2 and 4.2. Capture-then-replay was run and matched:

```
golden_harness: captured 32 fields to tools/golden_ref.mat
golden_harness: replay matched all 32 fields
```

Four decisions inside the harness that later tranches inherit:

1. **The reduction is not a plain sum.** The first capture used the template's `sum(x(:))` and immediately produced a false-safe fingerprint: `lib.create_pink_noise_square`, its own white noise, and `lib.whiten` all reduced to the **same** number, 69.7224, because the 1/f filter leaves the FFT origin at 1 and so preserves the DC term. Any edit that changed the filtering would have replayed clean. The fingerprint is now the 1×5 row `[sum, sum of squared magnitudes, index-weighted sum, NaN count, element count]` over the non-NaN elements in column order — order-sensitive and magnitude-sensitive. **Do not weaken this back to a sum when adding entry points in 0.2.0.**
2. **NaN-aware, deliberately.** `lib.steerable_grad` pads with NaN (3000 of its 32768 elements here). A plain sum collapses such an output to NaN, and `isequal(NaN, NaN)` is true, so every NaN-padded output would have compared equal to every other. The NaN count is carried as its own term instead.
3. **`lib.compute_pClipped` is exercised on a synthetic clipped array**, not only on a real stimulus. On a real stimulus it returns exactly 0, which is a degenerate fingerprint that any broken rewrite would still match. The synthetic case returns 0.5 and trips the function's own `>1%` warning — **that warning in the harness log is expected, not a failure.**
4. **Seeding.** `lib.stimulus` self-seeds (`rng('default'); rng(seed)` at `+lib/stimulus.m:82-83`), but `lib.create_pink_noise_square` and the non-circular branch of `lib.target_mask` call `normrnd` and do not, so the harness calls `rng(cfg.seed)` before every block regardless — blocks stay order-independent. Toolbox gating is on `normcdf`/`knnsearch` (Statistics) and `stdfilt`/`bwboundaries` (Image Processing), warning rather than erroring.

**Harness runtime is about 55 s, nearly all of it the parallel-pool start** that `lib.autocorr`'s `parfor` forces. Keeping `lib.autocorr` in was a deliberate trade: it is the only golden coverage of any `parfor` loop in the repo. Note also that replay output is noisy — `+lib/autocorr.m:9` has a bare unsuppressed `i` inside the loop, so a handful of `ans = 4` / `ans = 3` lines are printed out of worker order. That is a Stage 2 `NOSEMI` target (tranche 3), not a harness fault; grep for the `golden_harness:` line rather than reading the whole log.

**`parfor` re-confirmed by reading all 16 loop bodies, not taken on trust from the survey.** Every one writes only into a sliced output indexed by the loop variable — `edgePowers(iTrial,...)`, `stimuli(:,:,iTrial,...)`, `stim_l_groups{iTrial,...}`, `corr_cross(:,seed)`, `temp_response(seed,:)`, `autocorrs(:,:,n)`, `stim_f(:,:,i)`, `stim_energy(i,:)`, `r(i,j)`. **There is no accumulator anywhere**, so worker order cannot change a float sum and none of them needs to be touched. **Any edit that turns one of these slices into a reduction variable is a behaviour change and belongs in Stage 3.** Two loops produce no output at all: `+general/compute_noise_colour.m:81` (already recorded in section 2 — its body only plots, and plotting inside `parfor` is a no-op) and, newly noticed, `+tinker/pink_noise_seed_multiple_energies.m:21`, whose only output assignment is the commented-out `seed_energy_whitened(seed,:)=...` at `:38-39`. The second one is exploratory `+tinker/` code and is already on the triage worklist as block `27-39`, so tranche 10 should judge it there rather than treating it as a separate finding.

**Baseline decision for the dirty working tree — this binds every later tranche, decide nothing per-tranche.** `git status` at the time of this entry: the 29 `_`-prefix renames staged, `README.md` modified, `docs/` untracked, and two **in-scope** files carrying uncommitted edits — `+general/compute_nat_img_eff_coding_bins.m` and `+general/fit_edge_model_with_exps.m`, each with one live and one commented-out `colorbarpzn(...)` → `vislab.lib.colorbarpzn(...)` repoint. The live one is a real AST change, so:

- **For those two files only, HEAD is not a valid Stage 1 baseline.** Tranche 7 must copy the current on-disk content aside *before editing* and run `check_stage1` against that copy. Diffing them against HEAD will show a false change that is not the tranche's doing.
- **For every other in-scope file, HEAD is the baseline.** The `_`-prefix renames are staged but out of scope, and `README.md` is not a `.m` file.
- The repointing was deliberately **not** committed here to make HEAD clean. It is someone else's uncommitted work; blessing it inside a tooling commit would hide it in a diff nobody would look at again.

**`which_sweep.m` was not adopted into `tools/`, and that is a decision, not an omission.** The scratch sweep checks that every package-qualified reference resolves. It catches a *function* rename that broke a call site — but Stage 1 renames only file-local variables (zone 1), while zone 2 is deferred to S3.9 and zone 3 is frozen, so no Stage 1 tranche can create the damage the sweep detects. Its value is real but it belongs where the plan already puts it: as part (d) of the S3.5 smoke test, run when function-level renames actually start. Re-open this if any tranche finds itself wanting to rename a function.

**Housekeeping.** None was needed beyond creating `tools/`, exactly as section 4.1.2 predicted: the only two filename collisions with the shared library, `+lib/ptch_norm.m` and `+lib/watson_otf.m`, are excluded from cleaning rather than moved, and are S3.11's problem.

**No new bugs found.** `checkcode` on the four `tools/` files is clean. One cosmetic thing for tranche 1 to pick up rather than a bug: `lib.compute_pClipped` warns with the text "% of boundary ribbon clipped" no matter what it is handed, though it is a general-purpose clipping fraction — that is a header/message wording fix, well inside Stage 1.

**Rename map.** Nothing new to build: section 4.1.1 already carries the three zones, measured, from the survey — zone 1 free, zone 2 (37 name-value parameters, 55 declaration sites) deferred whole to S3.9, zone 3 (the `save`/`load` literals plus all 33 `ExpSettings` and 8 `SubjectExpFile` fields) frozen. It was re-read and is the map tranche 1 works from. Tranche 1 sets the concrete zone-1 expansions for the shared vocabulary and must record them here, since every later tranche will be told to follow whatever it writes down.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Tranche 0.1.1 — <code>+lib/</code> edge &amp; stimulus core (14 files, 948 lines)</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6**. Files: `stimulus.m`, `target_mask.m`, `edge.m`, `edge_vector_ideal.m`, `edge_measures_ideal.m`, `edge_measures.m`, `edge_energy.m`, `edge_shape.m`, `edge_response.m`, `edge_fit_cost.m`, `steerable_grad.m`, `steerable_filter.m`, `local_sd.m`, `compute_pClipped.m`. **This entry is binding on tranches 0.1.2–0.1.11**; the conventions below were chosen once, here, and later tranches follow them rather than re-deriving them.

**Baseline: HEAD, for all 14.** `git status` showed no in-scope `+lib/` file dirty, and `git diff HEAD -- '+lib/'` was empty before any edit, so the tooling entry's rule applies unchanged. The pre-edit copies were extracted with `git show HEAD:+lib/<f>.m` into a scratch directory and `check_stage1` was run against those. The two files carrying uncommitted `colorbarpzn` repoints are both in `+general/` and were not touched.

**Verbatim checker output.** The sweep script builds each file's rename map, runs `assert_rename_bijection` (inside `check_stage1`) and then the reverse-rename comparison:

```
24.2.0.2923080 (R2024b) Update 6
check_stage1 stimulus               1  (24 renames)
check_stage1 target_mask            1  (14 renames)
check_stage1 edge                   1  (13 renames)
check_stage1 edge_vector_ideal      1  (18 renames)
check_stage1 edge_measures_ideal    1  (4 renames)
check_stage1 edge_measures          1  (5 renames)
check_stage1 edge_energy            1  (5 renames)
check_stage1 edge_shape             1  (10 renames)
check_stage1 edge_response          1  (7 renames)
check_stage1 edge_fit_cost          1  (1 renames)
check_stage1 steerable_grad         1  (12 renames)
check_stage1 steerable_filter       1  (3 renames)
check_stage1 local_sd               1  (6 renames)
check_stage1 compute_pClipped       1  (0 renames)
files checked : 14
check_stage1 true : 14
check_stage1 false: 0
```

Stage 1 does not require a runtime check, but eight of these files are inside the golden harness, so it was replayed as a free extra confirmation:

```
golden_harness: replay matched all 32 fields
```

`checkcode` over the 14 files gives **the same 8 messages before and after**, the same ids in the same files — `stimulus` ASGLU ×3, `edge` NANMEAN, `edge_vector_ideal` NANMEAN, `edge_energy` DSPNORM, `compute_pClipped` LOGSUM ×2. No lint was introduced and none was fixed; all 8 are Stage 2 or Stage 4 work.

---

**Binding convention 1 — one old name maps to exactly one new name, per file.** This is a hard constraint, not a preference: `check_stage1` reverse-renames the canonical text globally, and `assert_rename_bijection` rejects a map where two new names share an old one. So where one file reuses a letter for two different roles, **you get one name for both**. It bit three files here. `+lib/edge.m` and `+lib/edge_vector_ideal.m` each use `i` as a pixel row index in the circular branch and as an index into a list of edge pixels in the other branch; `+lib/edge_shape.m` uses `i` for pixel rows and then for autocorrelation lags. In all three the name chosen was `i_row`, fitting the first use, with a two-line comment at the second site saying plainly that `i_row` indexes something else there and why it cannot be renamed separately. **Splitting such a variable into two is a Stage 3 change; do not attempt it in Stage 1, and do not "solve" it by leaving the counter as `i`.**

**Binding convention 2 — loop counters.** In the snake_case directories (`+lib/`, `+general/`, `+tinker/`), a loop counter is `i_<thing>`: `i_row`, `i_col`, `i_lag`, `i_exp`, `i_longest`, `i_unique_theta`. This is not invented — `+lib/edge_fit_cost.m` already wrote `i_exp` and `+lib/edge_props_stim.m` already writes `i_scale`. In `+experiment/` the equivalent is the existing camelCase `iTrial`/`iLevel`, which stays. **Pixel loops are `i_row`/`i_col`, never `row`/`col`**, because `row`/`col` is already taken in this code for *vectors* of found pixel coordinates (`[row,col] = find(mask_edge)`), and using the same words for a scalar index and a vector is what forces the collision in convention 1. Those coordinate vectors were renamed to `edge_rows`/`edge_cols`.

**Binding convention 3 — a local variable that mirrors a zone-2 name-value parameter keeps the parameter's exact name.** `bg_size`, `target_radius`, `target_shape`, `target_loc`, `target_or`, `kernel_size`, `n_edge`, `mask`, `mask_edge`, `mask_normal`, `ml_b`, `cont_b`, `ml_t`, `cont_t`, `texture`, `texture_bg`, `seed`, `pad_val`, `normalize`, `bdry_strip`, `edge_kernel`, `target_radius_cont` were all left alone for this reason, even where the name is poor (`ml_b`, `cont_b`). Renaming the local would pass the check — `parser.Results.ml_b` is dot-qualified and the regex skips it — and would leave the file reading `mean_lum_bg = parser.Results.ml_b`, which is worse than either name alone. Section 4.1.1's promised `ml`→`mean_lum` and `cont`→`contrast_rms` expansions therefore **do not happen in Stage 1 anywhere the name is a parameter**; they belong to S3.9, which renames the parameter and every call site together. A local that merely *holds* a parameter's value under a different name of its own is still free.

**Binding convention 4 — header shape.** Exactly the exemplar's: `% FUNCTION_NAME  One-line summary.`, then the fully-qualified call signature(s) indented three spaces, a blank comment line, prose, an `Inputs` block, an `Output`/`Outputs` block, then `See also`. `See also` targets are written **package-lowercase, function-uppercase** — `lib.STEERABLE_GRAD`, matching `vislab.lib.OTF_FILTER` in the exemplar. Every input and output line states a unit or says the quantity is dimensionless. Where a recorded bug makes the documented behaviour a lie, the header says so and cites the bug id, rather than quietly documenting the intent.

**Binding convention 5 — function bodies are indented four spaces, and every function file ends with `end`.** Half of these files indented the body and half did not; the exemplar indents, so all 14 now do. The terminal `end` was likewise inconsistent. Both were verified to round-trip clean through `canon` on a probe file before being applied — `tree2str` supplies a missing `end` and normalises indentation, so neither is visible to the check.

**Binding convention 6 — author attribution moves to the bottom of the header**, just above `See also`, instead of sitting between the summary line and the examples. It was only present in `stimulus.m` and `edge.m`; both now carry it in the new position. Later tranches should place any attribution block the same way and should not add one where none existed.

**Binding convention 7 — cross-boundary names are harmonised toward the caller's word, not the callee's**, when the two disagree and both are file-local. The concrete case here: `lib.target_mask` returned `target_normal` and `bd_strip`, while every caller catches them as `mask_normal` and (in `lib.stimulus`) `mask_strip`. The outputs are now `mask_normal` and `mask_strip`, so the whole `mask`/`mask_edge`/`mask_normal`/`mask_strip` family reads as one family on both sides of every call. The one caller that disagrees is `lib.edge_measures`, whose local is `bdry_strip` — but that is its zone-2 parameter name, so convention 3 wins there and the mismatch stays until S3.9. It is noted in that file's header.

**The concrete vocabulary set here**, to be reused rather than re-invented:

| meaning | name | notes |
|---|---|---|
| boundary parameter / polar angle | `theta`, `theta_grid`, `theta_field`, `theta_edge`, `theta_lags` | never `th`. `th` meant *threshold*, not theta, in `edge_response.m` — check the file, not the name |
| steerable kernel pair | `filter_kernel` | in both `steerable_filter.m` (output, was `filter`, a builtin shadow) and `steerable_grad.m` (local, was `filt`) |
| image gradient, rows × cols × 2 | `stim_grad` | `steerable_grad`'s output was `grad`; every caller already wrote `stim_grad` |
| normal component of the gradient | `grad_normal` | `edge_energy.m` called it `edge_normal`; `edge_shape.m` already said `grad_normal`. Pairs with the existing `grad_tangent` |
| gradient magnitude | `..._magnitude` | never `mag` |
| amplitude / spectrum | `edge_amplitude_spectrum`, `edge_power_spectrum`, `edge_phase_spectrum` | never `as`, `ps`, `spec` |
| white noise that generates a texture | `white_noise_bg`, `white_noise_target` | was `wn_b`, `wn_t` |
| background image | `stim_bg` | was `stim_b`. `_b`/`_t` suffixes expand to `_bg`/`_target` throughout |
| a loaded source image on disk | `source_image` | was `img`. Section 4.1.1's suggested `image_data` was not used — `source` carries the useful distinction from the synthesised `stim` |
| boundary/texture prefix | `boundary_`, `texture_` | never `bdry_`, `txtr_` |
| P–S texture-synthesis knobs | `n_scales`, `n_orientations`, `neighborhood_size`, `n_synthesis_iter` | were `Nsc`, `Nor`, `Na`, `Niter`. The **struct field** `texture.Niter` is untouched — it is dot-qualified and is written to disk |
| disc-shaped neighbourhood in `local_sd` | `disc_mask`, `disc_size`, `disc_center`, `disc_radius` | section 2's trial run used `disc_mask` + `mask_size`; `disc_*` throughout is more consistent and is what shipped |

**A correction to section 4.1.1.** It says the variable `filter_radius` in `+lib/local_sd.m` "is actually the *product* `kernel_size(1)*kernel_size(2)`" and offers it as an example of a name that is a lie. On reading, that is not right: `kernel_size` is `[sigma, n_sigma]`, so that product *is* the kernel's truncation radius in pixels, and `+lib/steerable_filter.m:8` computes the identical quantity under the identical name. The name was accurate. It was still renamed, to `disc_radius`, but for a different reason — to match the `disc_*` neighbourhood family in that file — and `filter_radius` was deliberately **kept** in `steerable_filter.m`, where it describes the filter rather than a neighbourhood. `ExpSettings.monitor_distance` (B3.8) remains a genuine example of the misnaming class; this one was not.

**Deliberately left alone.**

- **`compute_pClipped`'s camelCase name**, in an otherwise snake_case package. It is the filename, and renaming a file is a cross-file change, out of Stage 1's scope. The reason is written into the file's header so the next reader does not "fix" it.
- **`lib.edge` shadowing the Image Processing Toolbox `edge`**, and the unqualified `edge(stim,'zerocross',...)` call inside `+lib/edge_measures.m`, which resolves to the toolbox function. Section 0.4's "recorded and disproved" note says so; both files now say so in their headers too, because this is the single most inviting wrong "fix" in the package.
- **`mask` as a variable name.** It is the zone-2 parameter name in `lib.edge`, so convention 3 settles it regardless of whether it shadows anything.
- **`bPlot`** in `edge_shape.m`. The `b`-prefix boolean is an established repo convention (`bTargetPresent`, `bFovea`, `bBootstrap`); keep it in every tranche.
- **All eight `checkcode` messages**, listed above.

**Line-length exceptions — three, all in `+lib/edge_measures.m`**, at post-edit lines 68 (115 chars), 83 (117) and 84 (124). All three are **commented-out code** that step 2c triaged as *unfinished*. They were left byte-identical rather than reflowed: rewrapping dead code makes it harder to restore verbatim if S3.16 decides to revive it, and the wrapping would be invented by this pass rather than the author's. Every live line in all 14 files is under 100 characters; four function signatures and about a dozen expressions were wrapped with `...` and a four-space hanging indent to get there.

**Contents.m — deferred to tranche 0.1.3, deliberately.** The "done" checklist asks for a `Contents.m` in each package touched, but this tranche cleans 14 of `+lib/`'s 56 files. A `Contents.m` written now would list a quarter of the package and be stale within two tranches. **Tranche 0.1.3, the last `+lib/` tranche, writes the one `+lib/Contents.m` covering all 56 files**, following `vislab-common/+vislab/+lib/Contents.m`. Tranche 0.1.2 should not write one either. Later packages that are cleaned in a single tranche should write theirs in that tranche.

**Stage 2 not attempted**, per the plan: `+lib/` Stage 2 is item 0.2.1, done after the whole `+lib/` Stage 1 is complete. The four patterns are visible here and are left for it — `AGROW` none, `NOSEMI` none, `find` none convertible, and the `NASGU`/`ASGLU` targets are `stimulus.m`'s three unused `*_tight` outputs.

**Bugs found: four, all recorded in section 0.4 and none fixed** — 🟠 B2.13 (`stimulus.m` target branch tests the background texture struct), 🟠 B2.14 (`compute_pClipped`'s warning text, which the tooling entry had wrongly called a Stage 1 fix), 🟡 B3.13 (`edge_measures.m`'s hardcoded default boundary ribbon), 🟡 B3.14 (`target_mask.m` swaps row and column in the non-circular branch). Two observations that are *not* filed as bugs, recorded so they are not re-discovered: `lib.edge_energy` leaves its output unassigned if `measure_type` matches none of its eight strings, which errors loudly and only on a file that already cannot run (B2.3); and `lib.edge_fit_cost` depends on `sumsqr` from the Deep Learning Toolbox, which is a dependency, not a defect. Both are noted in their files' headers.

**A note for tranche 0.1.2.** `+lib/edge_props_stim.m` calls into four files cleaned here. It should adopt `theta`, `grad_normal`, `stim_grad`, `filter_kernel` and the `i_<thing>` counters, and it will hit convention 1 hard, since it reuses short names across a 535-line body.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Tranche 0.1.2 — <code>+lib/edge_props_stim.m</code> (1 file, 535 lines)</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6**. One file: `+lib/edge_props_stim.m`, the largest in the repo and the front end of the model feature extraction. Tranche 0.1.1's conventions were followed as written and not re-derived; the two decisions below that 0.1.1 did not cover are flagged as such.

**Baseline: HEAD.** `git status -- '+lib/edge_props_stim.m'` was empty and the on-disk file was byte-identical to `git show HEAD:+lib/edge_props_stim.m` (checked with `diff` before any edit), so the tooling entry's default rule applies. The pre-edit copy was taken into a scratch directory anyway and is what `check_stage1` compared against.

**Verbatim checker output.**

```
24.2.0.2923080 (R2024b) Update 6
assert_rename_bijection : passed (54 renames)
check_stage1 edge_props_stim  1
```

The golden harness does not cover this function (it cannot run — B2.2), so no replay was attempted. `checkcode` gives **the same 18 messages before and after**: `STOUT` ×15 (the fifteen outputs the commented-out contour block would assign) and `NASGU` ×3 (`bd_strip_rep`/`mask_strip_xy`, `grad_hist_thresh`, and `grads_pca`/`stim_grads_pca` — the third of these is now filed as B3.15). No lint introduced, none fixed.

---

**Renames — 54, all zone 1.** The vocabulary from 0.1.1 was applied directly: `mag`→`magnitude` (`grad_mags`→`grad_magnitudes`, `grad_mag_a`→`grad_magnitude_a`, `grad_m_hist_a`→`grad_magnitude_hist_a`, …), `or`→`orientation`, `prod`→`product`, `grad`/`grad_crop`→`stim_grad_tiled`/`stim_grad` (0.1.1's "`steerable_grad`'s output is `stim_grad`"), `grads`→`stim_grads`, `num_scales`→`n_scales` (matching 0.1.1's `n_scales` for the P–S knobs), `stim_sz`→`stim_size`, `epsl`→`epsilon`, `term_tot`→`term_total`, `N_a`/`N_b`→`n_elements_a`/`n_elements_b`, `stim_rep`→`stim_tiled`. `bd_strip`→`mask_strip` follows 0.1.1's convention 7 and its rename of `lib.target_mask`'s fourth output to `mask_strip`; `bd_strip_rep`→`mask_strip_xy` (replicated over the two gradient components). `kernel_sd_list`/`kernel_sd`/`kernel_nsd`→`kernel_sigma_list`/`kernel_sigma`/`kernel_n_sigma`, matching the documented `kernel_size = [sigma, n_sigma]` units. `i_scale` was already the 0.1.1 counter convention and is unchanged.

**Convention 3 held everywhere it applied.** `stim_raw`, `stim_type`, `otf_ppd`, `grad_hist_thresh`, `pca_coeffs`, `edge_pixels`, `target_normal` are all zone-2 name-value parameters declared in this file, so all seven keep their names, `target_normal` included even though 0.1.1 renamed the corresponding `lib.target_mask` output to `mask_normal`. That mismatch is noted in the file's header and belongs to S3.9.

**New decision A — a local that merely holds a parameter must not be renamed *onto* that parameter's own name.** `grad_m_bins = parser.Results.grad_mag_bins` was renamed to `grad_magnitude_bins`, deliberately **not** to `grad_mag_bins`. Renaming it onto the parameter's name would look tidier and would pass nothing: `check_stage1`'s reverse-rename regex has no way to tell a bare identifier from the same text inside the `addParameter(parser, 'grad_mag_bins', …)` **string literal**, so it would rewrite the literal too and the check would fail — or, worse, would not fail in some other file and would silently change a parameter name, which is zone 2 and forbidden here. **Rule for later tranches: a zone-1 new name may never equal any string literal in the file.** The same applies to `grad_o_bins`→`grad_orientation_bins` and `grad_p_bins`→`grad_product_bins`.

**New decision B — an output that only commented-out code would assign keeps its original name.** Fifteen of this function's thirty outputs (`npix_llr`, `ncon_llr`, `len_llr`, `len_sum`, `pos_llr`, `pos_sum`, `or_llr`, `or_sum`, `curv_llr`, `curv_sum`, `ep1_llr`…`ep16_llr`) are never assigned; the code that would assign them is the 260-line dead block at the end of the file (triage rows T2.5–T2.8 below). Expanding those names would leave the signature and the dead block that has to fill it out of step, and the dead block is deliberately left byte-identical. So they were left alone, and the header says plainly that they are never assigned and why their names are short. The fifteen outputs that *are* assigned were renamed in full (`grad_m_llr_1`→`grad_magnitude_llr_1`, etc.). **Later tranches: apply the same rule wherever a signature is half-dead.** Note this is a narrow exception to 0.1.1's vocabulary map, not a loosening of it.

**Not resolved here, per instruction — the B1.1/S3.4 normalisation question surfaces in this file too.** The `'camo'` branch calls `lib.steerable_grad(..., 'normalize', false)` while the `'tex'` branch forwards `varargin{:}` and passes no `normalize`, so it gets the default `2e-4`. The two branches therefore measure gradient magnitude in different units and their histogram bin edges are not comparable. The commented-out region-split loop (T2.2) passes no `normalize` on **either** branch, so restoring it verbatim would also change the camo normalisation. This is the same axis as `steerable_grad.m:64` (T1.14) and `edge.m:115-134` (T1.1). **Recorded, not decided: S3.4 owns it.**

**Line-length exceptions — thirteen, every one a commented-out line**, at post-edit lines 185, 186, 399, 484, 508, 601, 621, 627, 634, 639, 644, 649, 654 (101–118 characters). Same treatment and same reason as 0.1.1's three in `edge_measures.m`: dead code is left byte-identical rather than rewrapped, because invented wrapping makes verbatim restoration harder if S3.16 revives it. **Every live line is under 100 characters**; four statements were wrapped with `...` and a four-space hanging indent to get there, and three `% if p = 0, set p ln(p) to 0` inline comments were moved onto their own line above the statement for the same reason.

**The dead code was spliced, not retyped.** The four commented-out regions (pre-edit `75-94`, `112-118`, `134-139`, `271-536`) were copied out of the pre-edit file by line range and re-inserted programmatically, so their content cannot have drifted while the file was rewritten. The only change made to them is leading indentation (+4 spaces, to sit inside the now-indented function body) and stripped trailing whitespace. **Recommended for any later tranche handling a large dead block: splice it, do not retype it.**

**Contents.m:** none written, per 0.1.1's decision that tranche 0.1.3 writes the single `+lib/Contents.m` covering all 56 files.

**Stage 2 not attempted** — `+lib/` Stage 2 is item 0.2.1. For the record, the four patterns in this file: `NOSEMI` none (the unsuppressed `randi(10)` at pre-edit `:30` is S3.13's, not a semicolon fix); `AGROW` none; `find` none; unused assignments three (`bd_strip_rep`, `grad_hist_thresh`, `grads_pca`) — and **none of the three is a Stage 2 deletion target**, because each is evidence for a recorded defect rather than a leftover: the first two are only used by commented-out code (T2.1, T2.3) and the third is B3.15.

**Bugs found: one, recorded and not fixed** — 🟡 **B3.15** (the PCA rotation is computed and discarded). One further finding was folded into an existing Stage 3 item rather than filed as a bug: the three per-scale `figure`/`subplot`/`bar`/`title` groups inside the main loop are the same debug scaffolding S3.13 already lists for this file, so S3.13's scope was extended to name them. Two things deliberately **not** filed: the live per-region element counts `N_a`/`N_b` are taken once from the boundary mask, while the commented-out alternative (T2.4) counts non-NaN gradients per scale — the live denominators therefore ignore the NaN border that grows with kernel size, but which of the two the author intended is not recoverable, so it is a triage row and an S3.4/S3.16 question, not a bug; and `lib.edge_props_stim`'s existing defects B2.2 and B3.1 were re-confirmed by reading and are cited in the file's header rather than re-filed.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Tranche 0.1.3 — <code>+lib/</code> remainder (41 files, 1484 lines)</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6**. 41 files named in the tranche table; two of them, `ptch_norm.m` and `watson_otf.m`, are the filename collisions with the shared library excluded from cleaning per 0.1.1/0.1.2's housekeeping note (S3.11's problem) and were not touched — **39 files were actually cleaned**. Tranches 0.1.1/0.1.2's conventions were read in full and applied as written, not re-derived; the decisions below are applications of those conventions to files/situations 0.1.1/0.1.2 did not cover, not new conventions.

**Baseline: HEAD, for all 41.** `git status -- '+lib/'` was clean before this tranche started (confirmed empty `git diff HEAD -- '+lib/'`), so the tooling entry's default rule applies. Pre-edit copies of the 39 edited files were extracted with `git show HEAD:+lib/<f>.m` into a scratch directory and `check_stage1` was run against those copies.

**Verbatim checker output**, from the sweep script that builds each file's rename map and runs `assert_rename_bijection` (inside `check_stage1`) then the reverse-rename comparison:

```
24.2.0.2923080 (R2024b) Update 6
autocorr                         1  (4 renames)
combine_pairwise_stats           1  (15 renames)
correlations_across              1  (10 renames)
cosdRadial                       1  (7 renames)
cosWindow2                       1  (9 renames)
create_averaging_filter          1  (5 renames)
create_pink_noise_cube           1  (8 renames)
create_pink_noise_line           1  (7 renames)
create_pink_noise_square         1  (7 renames)
cropImage                        1  (6 renames)
csf_err                          1  (8 renames)
csf_fitted                       1  (9 renames)
csf_floating                     1  (10 renames)
csf_spatial_filter               1  (5 renames)
deg2rad                          1  (0 renames)
detect_edge_pixels               1  (2 renames)
diff_of_gaussians_filter         1  (10 renames)
differenceOfGaussians2D          1  (8 renames)
embedImageinCenter               1  (12 renames)
fftconv2                         1  (7 renames)
find_spot_centers                1  (7 renames)
gabor2D                          1  (14 renames)
gauss_llr                        1  (5 renames)
getTargetIndexFromString         1  (3 renames)
haar2D                           1  (10 renames)
hyperexp_nll                     1  (1 renames)
laplacian_of_gaussian_filter     1  (4 renames)
loadPatchAtIndex                 1  (11 renames)
maha_dist                        1  (3 renames)
mismatch_template                1  (15 renames)
monitorDegreesToPixels           1  (6 renames)
pairwise_stats                   1  (7 renames)
radialavg                        1  (11 renames)
samplePatchCoordinates           1  (10 renames)
spot2D                           1  (9 renames)
stimulus_spots                   1  (0 renames)
subplot_tight                    1  (0 renames)
trace_contours                   1  (8 renames)
whiten                           1  (7 renames)
files checked : 39
check_stage1 true : 39
check_stage1 false: 0
```

The golden harness covers five of these files (`create_pink_noise_square`, `whiten`, `csf_fitted`, `autocorr`, plus `compute_pClipped` from 0.1.1), so it was replayed as a free extra confirmation: `golden_harness: replay matched all 32 fields` — both immediately after the renames and again after the line-length reflow pass below, to catch anything the reflow might have disturbed.

`checkcode` over the 39 files gives the **same lint ids** before and after in every file except five, where the count only ever **drops**, never grows, and every drop is a formatting artifact the harmonisation pass naturally resolved rather than a deliberate Stage 2 fix: `cropImage` and `loadPatchAtIndex` each lost a `NOSEMI` ("extra semicolon is unnecessary") from dropping a stray `;` after `end`; `embedImageinCenter` lost six of the same; `differenceOfGaussians2D` and `gabor2D` each lost a `NOCOMMA`/`NCOMMA` pair from adding the missing comma between bracketed outputs (`[XX,YY]` → `[x_grid, y_grid]`) and dropping a trailing comma after a `for` header. None of these is a suppressing-semicolon insertion in the Stage 2 sense — they are semicolons and commas that were already inert — and all are confirmed still `check_stage1`-safe, since `canon` round-tripped every one of them.

---

**Binding-convention applications new to this tranche, recorded because later tranches will hit the same situations:**

1. **A local variable can be renamed onto a name that is also frozen elsewhere in the repo, as long as this file does not itself freeze it.** `+lib/correlations_across.m`'s outputs are named `corr_cross` and `d` — both on the zone-3 frozen list (section 4.1.1), but frozen there because `+tinker/pink_noise_stimuli_autocorrelations.m:42` does `save(...,'d','corr_cross')` on **its own local variables** of those names. `check_stage1`'s regex only protects dot-qualified names and string literals; a plain output-variable name in a different file that merely produces the value is zone 1. Renamed to `corr_vs_distance` and `distances` here. **Check the file, not the name — same rule as the survey's warning about `d`.**
2. **A whole-file camelCase style inside an otherwise snake_case package converts its internal variables, not its filename.** Several files here (`cosWindow2.m`, `cosdRadial.m`, `gabor2D.m`, `differenceOfGaussians2D.m`, `haar2D.m`, `spot2D.m`, `embedImageinCenter.m`, `cropImage.m`, `loadPatchAtIndex.m`, `samplePatchCoordinates.m`, `monitorDegreesToPixels.m`, `getTargetIndexFromString.m`, `find_spot_centers.m`) are written by other authors (Johannes Burge, Steve Sebastian, R. Calen Walshe, and others) entirely in camelCase, unlike the `edge`/`stimulus` core. The Stage 1 checklist already says `+lib/` files stay snake_case; the only precedent for *not* converting something is `compute_pClipped`'s **filename**, kept camelCase because renaming a file is a cross-file/out-of-scope change. That precedent does not extend to a file's internal locals, so every internal identifier in these files was converted to snake_case, same as the rest of the package. Filenames are untouched.
3. **A struct field is frozen even when nothing in section 4.1.1's enumerated zone-3 list names it**, whenever it is set by a caller outside this tranche's files. `Parameters.dc`/`.std`/`.size`/`.envelope`/etc. in `gabor2D.m`/`differenceOfGaussians2D.m`/`haar2D.m` and `stimulusParams.*` in `spot2D.m` are all left untouched, and `Settings.targetKey` in `getTargetIndexFromString.m` likewise, because `Settings` there is built by the out-of-scope `+stats/_loadStatisticsSettings.m` (`_`-prefixed) and read by later, not-yet-cleaned `+experiment/`/`+experiment/+analysis/` files. The general rule (struct fields not covered by the rename regex) already covers this; it is recorded here because it bit several files that were not part of the survey's explicit zone-3 enumeration.
4. **A zone-1 rename must not equal an existing string literal, checked per file, not just against the file's own addParameter keys.** No new instance of the exact `edge_props_stim.m` problem (0.1.2's decision A) came up, but it was checked in every file with a `switch`/`case` or `addParameter` (`gabor2D`, `differenceOfGaussians2D`, `haar2D`, `spot2D`, `detect_edge_pixels`) before choosing new names, since a case string like `'envelope'` or `'dc'` could otherwise have collided with a candidate local name.
5. **`case('literal')` and other redundant-looking parentheses are not free to remove.** `canon`/`mtree` preserves explicit grouping parentheses as real nodes: `if (nargin<4) || isempty(x)` and `if nargin<4 || isempty(x)` are **different** ASTs, and `case('horizontal')` vs `case 'horizontal'` likewise. This is not mentioned in the skill or in 0.1.1/0.1.2 because neither happened to touch a file with this pattern. It cost a first failed check-run on 11 of this tranche's files (`subplot_tight`, `cropImage`, `cosdRadial`, `embedImageinCenter`, `loadPatchAtIndex`, `getTargetIndexFromString`, `radialavg`, `fftconv2`, `differenceOfGaussians2D`, `gabor2D`, `haar2D`, `spot2D`) before every stray removed paren was put back exactly where the source had it. **Later tranches: do not "clean up" a redundant `if(...)`/`case(...)` paren as a formatting improvement — leave every parenthesization exactly as found, even where it looks inconsistent within the same file (as it does in `embedImageinCenter.m`, which wraps only the `exist(...)` call in some guards and the whole condition in others).** A companion trap: adding `exist(x, 'var')`'s second argument where the source called `exist(x)` with one argument is also a real AST change (an added argument), not a formatting fix — `cosdRadial.m`'s `if ~exist('bPLOT')` stays one-argument.
6. **A python text-mode file write can silently convert line endings.** One file (`gabor2D.m`) came out with CRLF line endings end-to-end after being rewritten via a Python one-liner running under Git Bash (Python's default text-mode newline translation on Windows); every other file in the tranche, written directly, stayed LF. Caught by an explicit end-of-tranche sweep (`file *.m` / trailing-byte check on every file), not by `check_stage1` (`canon` does not care about line-ending bytes). Converted back to LF before the final check-run and commit. **Any later tranche that shells out to a text-processing tool for a bulk edit should check line endings explicitly afterward — `check_stage1` will not catch it.**

**The concrete vocabulary set here**, extending 0.1.1's table, to be reused rather than re-invented:

| meaning | name | notes |
|---|---|---|
| CSF/ATF fit family (`csf_err`, `csf_fitted`, `csf_floating`, `csf_spatial_filter`) | `spatial_freq`, `pupil_diameter`, `wavelength`, `surround_shape_exponent`, `surround_strength`, `surround_size`, `center_size`, `params`, `atf`, `human_atf` | were `u`, `d`, `w`, `n`, `a`, `b`, `c`, `p`, `z`, `z0`. `pupil_diameter`/`wavelength` match the units already fixed by `vislab.lib.watson_otf`'s exemplar signature; this repo's own (excluded, uncleaned) `+lib/watson_otf.m` still reads `u,d,lambda` |
| pink noise generation (`create_pink_noise_square/cube/line`, `whiten`) | `pink_noise`, `white_noise`, `pink_noise_filter`, `white_noise_fft`, `white_noise_filtered_fft` | were `img_1f`/`cube_1f`/`sig_1f`, `wn`, `fil_1f`, `wnf`, `wnf_fil`. Matches 4.1.1's predicted `wn`→`white_noise` |
| pairwise-statistics family (`pairwise_stats`, `combine_pairwise_stats`, `correlations_across`) | `n_obs`, `mean_x`, `mean_y`, `mean_xy`, `mean_x2`, `mean_y2`, `corr_coeff`, plus `_list` for the per-group vectors | were the packed `n,xm,ym,xym,x2m,y2m,r` / `*_l` used identically in both functions |
| patch/coordinate family (`cropImage`, `loadPatchAtIndex`, `samplePatchCoordinates`) | `patch_coords_rc` | was `PcoordsRC`/`PCoordsRC`, kept consistent across all three files since they pass this value to each other |
| Gaussian/Gabor kernel family (`gabor2D`, `differenceOfGaussians2D`, `haar2D`, `spot2D`) | `x_grid`, `y_grid`, `envelope_radius`, `gabor_sd`, `amplitude` | were `XX`/`YY`, `envelopeRadius`, `GaborSD`, `amp` |
| pixel-list index in a graph/contour trace | `i_pixel`/`j_pixel`, `pixel_idx`/`next_pixel_idx` | `trace_contours.m`; `i_pixel` is convention-1's collision again (pixel-list index, then reused as contour-position counter), noted at the second site |

**Line-length exceptions — five, every one a commented-out or otherwise byte-preserved line**, left un-reflowed for the same reason as 0.1.1/0.1.2 (rewrapping dead code invents wrapping that was never the author's, and makes verbatim restoration harder for S3.16): `+lib/embedImageinCenter.m` post-edit line 34 (126 chars, the commented-out `warning(...)` call, T3.6 below). Every other over-100 line found during the pass was a live line and was wrapped with `...` and a four-space hanging indent; the worst was `+lib/embedImageinCenter.m`'s original 135-character signature/doc line.

**Contents.m — written**, `+lib/Contents.m`, covering the full 56-file package as 0.1.1 deferred it to this tranche. Modelled on `vislab-common/+vislab/+lib/Contents.m`'s shape (namespace line, one-paragraph summary, call convention) and adds one repo-specific note: `ptch_norm.m`/`watson_otf.m` are this repo's own uncleaned copies of names that collide with the shared library, not aliases to it, per S3.11.

**Stage 2 not attempted** — `+lib/` Stage 2 is item 0.2.1, done after all of `+lib/`'s Stage 1 (0.1.1–0.1.3) is complete. The four patterns, surveyed across all 39 files: `NOSEMI` none live (only the stale extras removed above); `AGROW` one, `+lib/find_spot_centers.m`'s `centers(end+1,:)`, already flagged `%#ok`-free but growing by one row per recursive call — a candidate, not fixed here; `find` none convertible (every `find` call either needs the index itself — `getTargetIndexFromString.m`, `trace_contours.m` — or is already reduced with a `1` count argument); unused assignments none beyond the pre-existing `combine_pairwise_stats`/`pairwise_stats` unused `corr_coeff`/`corr_coeff_list` argument (present before this tranche, not introduced by it, and not a Stage 2 deletion target since it is a function input, not a local assignment).

**Bugs found: one new, recorded and not fixed; one existing re-confirmed with a severity question flagged, not re-filed.**

- 🟠 **B2.15.** **`lib.cropImage`'s always-overridden `indColorChannels` (B3.2) is reachable, not just latent.** B3.2 (filed before any tranche started) already documents the root cause — `if ~exist('indColorChannel','var') || isempty(indColorChannels)` misspells the guard variable, so the branch always runs and always overwrites `indColorChannels` to `1:size(source_image,3)` regardless of what the caller passed. Filed at severity 3 as latent. Reading the actual call sites in this tranche shows it is not latent: `+vis/examplePatches.m:43`, `+vis/presentpatches.m:28`, and `+vis/viewpatches.m:39` all pass `indColorChannels = 1` explicitly, intending to crop a single colour channel, and the bug silently substitutes all channels instead — every one of those call sites is in `+vis/`, i.e. display-only. That fits B2's definition ("reachable, not silent... or it only touches plots, logging, or display") better than B3's "not reachable with the current config or inputs." Filed here as a new item rather than relabelling B3.2, per the skill's re-filing rule; B3.2 itself is left as originally recorded.

Two things read and deliberately **not** filed as bugs: `+lib/hyperexp_nll.m`'s name/docstring-vs-code mismatch is already B3.6, re-confirmed by reading the density formula (it is the hypoexponential sum, not a hyperexponential mixture) and cited in the file's header rather than re-filed; and `+lib/find_spot_centers.m`'s `ismember(...,'row')` typo is already B3.5, likewise re-confirmed and cited rather than re-filed.

**A note for later tranches.** `+lib/mismatch_template.m` and `+lib/stimulus_spots.m` both call `lib.circular_mask`, which does not exist anywhere in the tree (B2.9); neither function can currently run. `stimulus_spots.m` also duplicates most of `lib.stimulus`'s job under a different name (S3.3's near-duplicate-elimination territory) — not touched here, just flagged so S3.3 knows another candidate exists beyond the five `{setUpExperiment, sessionSettings, generate_camouflage_stimuli}` families already named in section 4.1.2.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Tranche 0.1.4 — <code>+experiment/+main/</code> (11 files, 714 lines)</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6**. All 11 files: `checkFixationCross.m`, `configureEyetracker.m`, `displayLevelStart.m`, `fixationInterval.m`, `giveFeedback.m`, `responseInterval.m`, `runCamouflageExperiment.m`, `runCamouflageExperiment_search.m`, `stimulusInterval.m`, `testscripts/gettestexperimentstruct.m`, `testscripts/runsingletrialTest.m`. Tranches 0.1.1–0.1.3's binding conventions were read in full and applied as written; this directory is `+experiment/`'s camelCase family, so the snake_case vocabulary table (theta, magnitude, stim_grad, etc.) mostly does not apply here — none of that vocabulary's abbreviations (`ml`, `cont`, `th`, `mag`, `or`, `filt`/`filter`, `grad`, `img`, `bdry`/`txtr`, `wn_b`/`wn_t`, `Nsc`/`Nor`/`Na`/`Niter`, `kernel_sd*`, `epsl`) occur anywhere in these 11 files. Loop counters already follow the established camelCase convention (`iTrial`, `iSession`, `iLocation`) and needed no changes.

**Baseline: HEAD, for all 11.** `git status -- '+experiment/+main'` and `git diff HEAD -- '+experiment/+main'` were both empty before this tranche started, so the tooling entry's default rule applies. Pre-edit copies of all 11 files were extracted with `git show HEAD:<path>` into a scratch directory and `check_stage1` was run against those copies.

**Verbatim checker output**, from a sweep script that builds each file's rename map and runs `assert_rename_bijection` (inside `check_stage1`) then the reverse-rename comparison:

```
24.2.0.2923080 (R2024b) Update 6
check_stage1 checkFixationCross               1  (1 renames)
check_stage1 configureEyetracker              1  (1 renames)
check_stage1 displayLevelStart                1  (0 renames)
check_stage1 fixationInterval                 1  (0 renames)
check_stage1 giveFeedback                     1  (0 renames)
check_stage1 responseInterval                 1  (0 renames)
check_stage1 stimulusInterval                 1  (0 renames)
check_stage1 runCamouflageExperiment          1  (0 renames)
check_stage1 runCamouflageExperiment_search   1  (13 renames)
check_stage1 testscripts/gettestexperimentstruct 1  (0 renames)
check_stage1 testscripts/runsingletrialTest   1  (0 renames)
files checked : 11
check_stage1 true : 11
check_stage1 false: 0
```

This directory is outside the golden harness's coverage (`+experiment/+main` is Psychtoolbox/EyeLink-bound, per the tooling entry and section 2), so no runtime replay was attempted — Stage 2 for this tranche is item 0.2.3, pattern-check only, per that recorded decision.

`checkcode -id` over all 11 files gives **identical message-id lists before and after**, file by file: `checkFixationCross` (`ASGLU, STRNU, NASGU, ASGLU, ASGLU, NOPRT`), `configureEyetracker` (`ASGLU`), `displayLevelStart` (`NASGU, NASGU`), `giveFeedback` (`NASGU, NASGU, NASGU`), `stimulusInterval` (`ASGLU`), and none in `fixationInterval`, `responseInterval`, `runCamouflageExperiment`, `runCamouflageExperiment_search`, or either `testscripts/` file. No lint introduced, none fixed.

---

**Renames — 2 single-file renames plus 13 in one file, all zone 1, none touching the vocabulary table (none applied here).**

- `+experiment/+main/checkFixationCross.m`: `evtype`→`eventType` (an unused local — assigned once from `SessionSettings.el.ENDSACC` in the dummy-mode branch, never read; kept as an unused assignment per the "don't fix Stage 2 material in Stage 1" rule, just given a readable name).
- `+experiment/+main/configureEyetracker.m`: the bare `i` holding `Eyelink('Openfile', edfFile)`'s return code →`edfOpenStatus`, so `if i~=0` reads as `if edfOpenStatus ~= 0`.
- `+experiment/+main/runCamouflageExperiment_search.m` (13 renames) — this file mixes snake_case locals (`exp_type`, `gamma_correction`, `stim_start`/`stim_end`, `luminanceSheet_gc`, `blank_tex`, `circle_cues`, `cue_tex`, `sampleStimulus_gc`, `valid_click`) into an otherwise-camelCase `+experiment/+main` file, the same situation tranche 0.1.3's binding-convention-application #2 named for a camelCase file inside a snake_case package, mirrored here. Converted to the directory's camelCase convention: `exp_type`→`expType` (also the function's second parameter), `gamma_correction`→`gammaCorrection`, `stim_start`/`stim_end`→`stimStart`/`stimEnd`, `luminanceSheet_gc`→`luminanceSheetGc`, `blank_tex`→`blankTex`, `circle_cues`→`circleCues`, `cue_tex`→`cueTex`, `sampleStimulus_gc`→`sampleStimulusGc`, `valid_click`→`validClick`. Also applied here: the vocabulary rule `num_*`→`n_*` (given in this tranche's own instructions, matching section 4.1.1's list), which for a camelCase file becomes `num_Correct`→`nCorrect`. Two bare single-letter locals from `GetClicks`, `x`/`y` (click coordinates), renamed to `clickX`/`clickY` per the survey's instruction to name every bare letter for what it holds — checked against the file's other coordinate pair `displayX`/`displayY` first to confirm no collision. No collision with any string literal in the file (checked `strcmpi(expType,'detect'|'search')` and the `exp_files/search/...` path-building string concatenations, none of which contain the token `expType` etc. as literal text).

**No renames in the other 8 files** (`displayLevelStart.m`, `fixationInterval.m`, `giveFeedback.m`, `responseInterval.m`, `stimulusInterval.m`, `runCamouflageExperiment.m`, and both `testscripts/` files) — their existing camelCase locals (`fixTarget`, `fixPosXY`, `targetDestination`, `stimulusOnsetMs`, `SessionSettings`, etc.) already read clearly and none is a bare letter, a builtin shadow, or one of the vocabulary abbreviations.

**`SessionSettings` kept everywhere it appears**, per binding convention 3's spirit (a local that mirrors an established config-struct name keeps that name) — it is this directory's equivalent of a zone-2 parameter, threaded through every interval function's first argument.

**Terminal `end` added to 8 of the 11 function files** (`checkFixationCross.m` already had one; `configureEyetracker.m`, `displayLevelStart.m`, `fixationInterval.m`, `giveFeedback.m`, `responseInterval.m`, `stimulusInterval.m`, `runCamouflageExperiment_search.m` did not; `runCamouflageExperiment.m`'s already had one; `testscripts/gettestexperimentstruct.m` already had one), per binding convention 5. `testscripts/runsingletrialTest.m` is a script, not a function, so no terminal `end` applies to it; its body indentation was also de-indented to column 0 for the same reason (a script's statements are not inside anything to indent relative to).

**Header docs — all 11 rewritten to the exemplar shape** (summary line, fully-qualified `experiment.main.<name>(...)` signature, `Inputs`/`Output` with units where they exist, `See also`). `runCamouflageExperiment.m` already had strong prose (it documents the retirement of the old `runSession`/`runTrial` monolith) — that prose was kept verbatim and only reshaped into the `Inputs`/`Output`/`See also` structure; nothing substantive was rewritten. Void functions (`checkFixationCross`, `displayLevelStart`, `fixationInterval`, `giveFeedback`, `runCamouflageExperiment_search`) get an `Output` section reading `none (side effect: ...)`, naming the side effect, since the exemplar has no void-function precedent to follow and this seemed the most literal extension of its shape. `stimulusInterval.m`'s `Output` section documents the onset/offset mismatch (this tranche's new finding, B3.16) inline, citing the file:line pair, rather than only in the bug list.

**Line-length exceptions — two, both documented.** `displayLevelStart.m` post-edit line 41 (168 chars): the `DrawFormattedText`/`sprintf` instruction string, which cannot be wrapped without turning one string literal into a `horzcat`, a real AST change Stage 1 forbids — confirmed by first attempting exactly that wrap and having `check_stage1` fail, then reverting to the original single-literal form. `runCamouflageExperiment_search.m` post-edit line 75 (122 chars): a commented-out (dead) line inside the `displayMask`/`iLocation` block (this tranche's only commented-out block, see below) — left byte-identical rather than rewrapped, matching 0.1.1–0.1.3's rule for dead code. Every other over-100 line found (18 of them, all in `runCamouflageExperiment_search.m`, `checkFixationCross.m`, `fixationInterval.m`, `runCamouflageExperiment.m`, and `stimulusInterval.m`) was live and was wrapped with `...` and a four-space hanging indent, including one case where a trailing inline comment was moved to its own line above the statement instead (`stimulusInterval.m`'s two `% If not foveal experiment...` comments) since that alone brought both lines under 100 characters without touching any code.

**Commented-out code — one block found, not in the survey's sizing table.** `+experiment/+main/displayLevelStart.m:39-45` (pre-edit numbering), 7 lines: a commented `if SessionSettings.bFovea ... else ... end` wrapping the order in which the fixation cross and the target outline are drawn. The commented branch (foveal case) would draw the target then the fixation cross; the live, unconditional code — what the `else` used to guard — draws the target then the fixation cross **on top**, unconditionally, regardless of `bFovea`. So the author disabled the conditional and kept only the peripheral-case draw order for every run. **Verdict: alternative** — a real, complete branch the author switched away from in favour of one fixed order; ties into the existing `S.bFovea`/foveal-vs-peripheral open question already flagged in S3.17 (`loadStimuliCamouflage.m:16` hardcodes `bFovea = 1`, so the peripheral path is currently unreachable from the live entry point regardless). Keep; S3.16 should convert it to a header note about why the draw order is fixed, per the *alternative* verdict's usual disposition, rather than deleting it. Not previously listed in section 4.1.4's sizing table (that table is heuristic and self-flagged as an undercount); recorded here as this tranche found it, per the skill's triage-at-read-time rule.

**One further scattered dead-code fragment, triaged in passing (below the 5-line block threshold).** `+experiment/+main/giveFeedback.m:20,23,26`: three one-line `%sound(...)` calls, one per branch, sitting under three live `Beeper(...)` calls of the same semantic role. **Verdict: alternative** — the tones (`correctTone`/`incorrectTone`/`errorTone`) are still computed above (hence the `NASGU` lint on those three lines, pre-existing and unchanged) but only the commented `sound()` calls would ever read them; the author switched from playing a synthesised tone via `sound` to a fixed system beep via `Beeper` for all three cases. Keep; S3.16 should either delete the now-pointless tone computation alongside the commented calls, or convert the switch into a one-line header note, but not without deciding what to do about the resulting unused `correctTone`/`incorrectTone`/`errorTone`.

**Bugs found: two new, recorded in section 0.4 and not fixed.**

- 🟠 **B2.16.** `+experiment/+main/testscripts/runsingletrialTest.m` references an undefined variable `w` (the window handle is actually named `window`) and errors immediately if run. Not previously documented — this file was not covered by the original survey's per-file reading.
- 🟡 **B3.16.** `experiment.main.stimulusInterval`'s returned `stimulusOnsetMs` is actually captured at the stimulus's second `Screen('Flip', ...)` call (which blanks it), not the first (which turns it on) — the two flips share one variable name, `StimulusOnsetTime`, and the second overwrites the first before the return. Filed latent rather than reachable because S3.17 already records that the current caller discards this return value.

Nothing else new: `B1.6` (timeout responses corrupting SDT scoring, `responseInterval.m:25`) and the `S.bFovea`/`S.targetTypeStr`/`stimulusOnsetMs`-discarded questions from S3.17 were re-confirmed by reading these files and are cited in the relevant files' headers (`responseInterval.m`, `stimulusInterval.m`) rather than re-filed.

**Contents.m — written**, `+experiment/+main/Contents.m`, covering all 11 files (this tranche cleans the whole package in one pass, so — per 0.1.1's precedent for a partially-cleaned package — no deferral was needed). Modelled on `vislab-common/+vislab/+lib/Contents.m`'s shape, adapted for a runtime package rather than a function library: names the shared-harness wiring (`runCamouflageExperiment` → `vislab.psychframework.run_experiment`), the standalone `_search` variant, and flags `testscripts/` as non-live scratch code.

**A note for tranche 0.1.6** (`+experiment/` top level, including the variant families): `runCamouflageExperiment.m`'s docstring documents that the old monolithic `runCamouflageExperiment`/`runSession`/`runTrial` were retired in favour of the shared `vislab.psychframework.run_experiment` harness — so `+experiment/` top-level files that still reference a `runTrial.m` or similar (S3.17 mentions one) are referring to retired code, not a currently-live sibling of this package.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Tranche 0.1.5 — <code>+experiment/+analysis/</code> (12 files, 787 lines)</h5></summary>

<div style="margin-left:1.5em">

**Done**, under **MATLAB 24.2.0.2923080 (R2024b) Update 6**. All 12 in-scope files: `computeBootstrappedThreshold.m`, `computeNegLogLikelihood.m`, `computeNegLogLikelihood_edgeResponse.m`, `computeTemplateResponseSigma.m`, `computeThreshold_edgePower.m`, `computeThreshold_edgeResponse.m`, `computeThreshold_texture_exponent.m`, `computeThresholdsVsStatistic.m`, `compute_thresholds_vs_lum_cont.m`, `fitPsychometric.m`, `plotThresholdvsCondition_mine.m`, `psychometricFun.m`. The 7 `_`-prefixed files already renamed out of scope before this tranche started (`_computeNegLogLikelihood_steve.m`, `_computeNegLogLikelihood_trials.m`, `_computeThreshold_steve.m`, `_computeThreshold_trials.m`, `_fitPsychometric_steve.m`, `_fitPsychometric_trials.m`, `_psychometricFun_trials.m`) are pre-existing uncommitted work by the repo owner, not this tranche's — they were not touched, and the working tree's `_`-prefixed set matched section 1's count of 7 for this directory exactly, so nothing was ambiguous about which 12 files are actually in scope. Tranches 0.1.1–0.1.4's binding conventions were read in full before touching any file.

**Convention check, per this tranche's own instruction to verify rather than assume.** `+experiment/+analysis/` is *not* the clean camelCase directory `+experiment/+main/` turned out to be. Every file's local scratch variables (`exp_values`, `target_means`, `num_targets`, `p_c`, `a_init`, `n_boot`, `blank_mean`, `thresholds_lum_cont`, `lum_cont`, …) are snake_case, consistently, across all 12 files; only variables that are function parameters, loop counters, or that mirror an `ExpSettings`/`SubjectExpFile` field are camelCase (`expTypeStr`, `subjectStr`, `bPlot`, `bBootstrap`, `nTrials`, `nLevels`, `bTarget`, `iBoot`, `iLevel`). This is the mirror image of tranche 0.1.3's finding for a camelCase file inside a snake_case `+lib/` — here it is snake_case scratch locals inside a camelCase-named-file package, and it is consistent enough across all 12 files (not just one outlier) that it reads as this directory's own established style rather than drift to correct. **Decision: kept the existing split as-is** — camelCase for parameters/loop-counters/struct-mirroring locals, snake_case for scratch/derived locals — rather than importing either convention wholesale. Loop counters follow the established camelCase (`iBoot`, `iLevel`, and new ones introduced below), matching 0.1.1's rule for `+experiment/`.

**Baseline: HEAD, for all 12.** `git status -- '+experiment/+analysis'` and `git diff HEAD -- '+experiment/+analysis'` were both empty before this tranche started, so the tooling entry's default rule applies. Pre-edit copies of all 12 files were copied from the working tree (byte-identical to HEAD) into a scratch directory and `check_stage1` was run against those copies.

**Verbatim checker output**, from a sweep script that builds each file's rename map and runs `assert_rename_bijection` (inside `check_stage1`) then the reverse-rename comparison:

```
24.2.0.2923080 (R2024b) Update 6
check_stage1 psychometricFun.m                             1  (7 renames)
check_stage1 computeNegLogLikelihood.m                     1  (12 renames)
check_stage1 fitPsychometric.m                             1  (10 renames)
check_stage1 computeNegLogLikelihood_edgeResponse.m        1  (19 renames)
check_stage1 computeThreshold_edgePower.m                  1  (25 renames)
check_stage1 computeThreshold_edgeResponse.m               1  (27 renames)
check_stage1 computeThreshold_texture_exponent.m           1  (25 renames)
check_stage1 computeThresholdsVsStatistic.m                1  (5 renames)
check_stage1 compute_thresholds_vs_lum_cont.m              1  (4 renames)
check_stage1 plotThresholdvsCondition_mine.m               1  (0 renames)
check_stage1 computeBootstrappedThreshold.m                1  (1 renames)
check_stage1 computeTemplateResponseSigma.m                1  (5 renames)
files checked : 12
check_stage1 true : 12
check_stage1 false: 0
```

Three files failed on the first pass and were fixed before the run above: `computeThreshold_edgePower.m` and `computeThreshold_texture_exponent.m` each had a loop counter renamed to `iLevel`, which collided with a *different*, already-existing `iLevel` elsewhere in the same file (the bootstrap inner loop) — a rename-chain that `assert_rename_bijection` is specifically designed to catch (old name `iLevel` on the domain side, new name `iLevel` on the range side). Fixed by renaming the outer per-level loop to `iTargetLevel` instead, freeing `iLevel` for the (separately renamed) bootstrap loop, `iBootLevel`. `compute_thresholds_vs_lum_cont.m` failed because the chosen new name `threshold` collided with the pre-existing string literal `'threshold'` in `zlabel 'threshold'` — the exact hazard tranche 0.1.2's "decision A" describes, just with a plot label instead of an `addParameter` key. Fixed by renaming to `fit_threshold`/`fit_threshold_std` instead. **All three are recorded here because they are exactly the two escalation-relevant traps this tranche was warned about, not because the fix was unclear.**

Golden harness replayed as a free extra confirmation, since three of this tranche's files (`computeNegLogLikelihood.m`, `fitPsychometric.m`, `psychometricFun.m`) are inside its coverage — **these are the three files item 0.2.2 means by "the three psychometric functions"**:

```
golden_harness: replay matched all 32 fields
```

`checkcode -id` gives the **same message-id count in every file, before and after**: `computeBootstrappedThreshold.m` 10, `computeNegLogLikelihood_edgeResponse.m` 2, `computeTemplateResponseSigma.m` 5, `computeThreshold_edgePower.m` 8, `computeThreshold_edgeResponse.m` 13, `computeThreshold_texture_exponent.m` 9, `computeThresholdsVsStatistic.m` 3, everything else 0. No lint introduced, none fixed.

---

**Renames — the vocabulary, built here since no earlier tranche touched this directory's fit-model terms.** The signal-detection psychometric model (`experiment.analysis.psychometricFun`, fit by `fitPsychometric`/`computeNegLogLikelihood`) uses bare `a`, `b`, `c`, `d`, `p_c`, `p_h`, `p_cr`; the edge-response variant (`computeNegLogLikelihood_edgeResponse`/`computeThreshold_edgeResponse`) uses `th`, `n`, `sigma`, `r`. Renamed consistently across every file that shares the vocabulary:

| meaning | name | notes |
|---|---|---|
| Weibull scale (stimulus level at d' = 1) | `threshold_scale` | was `a`. Docstring already called this "model alpha"; not renamed to `alpha` because `ExpSettings.alphas`/`\alpha` already means *texture exponent* in `computeThreshold_texture_exponent.m` — reusing the word for a different quantity in the same file would be a readability trap, not a fix |
| Weibull shape exponent | `slope` | was `b` |
| criterion asymmetry, dimensionless in (-1,1) | `bias` | was `c` |
| sensitivity index | `d_prime` | was `d`. Per section 4.1.1's own warning, `d` means something else in `+tinker/` — checked file by file, not name by name |
| probability of a hit / correct rejection / correct | `p_hit` / `p_correct_rejection` / `p_correct` | were `p_h` / `p_cr` / `p_c` |
| trial counts feeding the binomial likelihood | `n_blanks`, `n_targets`, `n_hits`, `n_correct_rejections` | were `num_blanks`, `num_targets`, `num_hits`, `num_cr` — the `num_*`→`n_*` rule tranche 0.1.4 already applied to a camelCase file |
| log likelihood / negative log likelihood | `log_likelihood` / `neg_log_likelihood` | were `ll` / `nll` |
| edge-response model's threshold-like and shape parameters | `exponent`, plus **`threshold` in `computeNegLogLikelihood_edgeResponse.m` but `edge_threshold` in `computeThreshold_edgeResponse.m`** | were `n` and `th`. See the collision note below for why the same old name got two different new names across these two sibling files — a deliberate exception to "one vocabulary per concept," forced by a pre-existing bug |
| pooled edge response and its per-level blank/target moments | `edge_response`, `response_blank_means`, `response_blank_sds`, `response_target_means`, `response_target_sds` | were `r`, `r_b_means`, `r_b_sds`, `r_t_means`, `r_t_sds` |
| per-level loop counter | `iLevel` (outer, uncontested files) / `iTargetLevel` (where a bootstrap-inner `iLevel` already existed) / `iBootLevel` (that inner loop) / `iSession` (loop over completed sessions, was `cItr`/`idx`) | see the collision note |

**A deliberate, file-specific exception forced by B3.10.** `computeThreshold_edgeResponse.m`'s `%% Bootstrap` section is the copy-pasted, never-adapted scaffolding B3.10 already documents: it references `target_means`, `target_sds`, `exp_values`, and `threshold`, none of which this function ever assigns. Its sibling `computeThreshold_edgePower.m` names its own fitted parameter `threshold` (`= mu + threshold_scale`) with no such conflict. Renaming this file's `th` to `threshold` too would have coincided with the Bootstrap section's already-broken bare `threshold` reference and **silently supplied it a value** — turning a loud, reproducible error into a quiet non-error, which is a real behaviour change and would have buried B3.10 rather than left it intact. Renamed to `edge_threshold` instead, and the file's header explains why, citing B3.10 by id. The Bootstrap section's other three undefined names, `a`/`b`/`c`, were renamed anyway (to `threshold_scale`/`slope`/`bias`, matching the vocabulary above) because neither the old nor the new name is ever validly assigned in that file — renaming an already-undefined identifier cannot mask anything. `target_means`, `target_sds`, `exp_values`, and the bare `threshold` inside that same Bootstrap section were left **completely untouched**, both because they are never validly assigned (so renaming risked nothing) and to keep the B3.10 citation's variable names matching the code exactly.

**The `iLevel` collision, generalized.** Three files (`computeThreshold_edgePower.m`, `computeThreshold_edgeResponse.m`, `computeThreshold_texture_exponent.m`) each contain two conceptually-similar but textually-distinct per-level loops: an outer one (originally `i` or, in `computeThreshold_edgeResponse.m`, absent from the final `bPlot` loop's `i`) and a bootstrap-inner one (originally `iLevel`). Naming both `iLevel` — the natural choice for either alone — creates exactly the rename-chain `assert_rename_bijection` forbids. Resolved uniformly across all three files: the outer loop is `iTargetLevel` (since in every case it is indexing per-level target statistics), the inner bootstrap loop is `iBootLevel`. **Later tranches: if a file has two loops that both deserve the same natural per-level name, check whether one of the two old names is itself `iLevel` (or otherwise equal to the other's natural new name) before choosing — the fix is to make the new names describe what's different about each loop (here, "target" vs "boot"), not to abbreviate one of them.**

**Convention 3 held throughout.** `ExpSettings`, `SubjectExpFile`, `nTrials`, `nLevels`, `bTargetPresent`/`bTarget`, `levelCompleted`, `correctRejection`, `edgePowers`, `ImgStats`, `expTypeStr`, `subjectStr`, `targetTypeStr`, `binIndexLevels` and similar were left exactly as found, including where a local's name only *approximately* mirrors the struct field it is copied from or into: `correct_reject` (local) vs. `SubjectExpFile.correctRejection` (field) is exactly 0.1.1's convention-7 situation — both are file-local-vs-frozen-field mismatches, not touched, and each file's header now says so explicitly so the mismatch isn't mistaken for an oversight.

**`computeThresholdsVsStatistic.m` and `computeTemplateResponseSigma.m` share vocabulary deliberately**, even though `check_stage1` is per-file and doesn't require it: `tSigma`→`templateSigma`, `iLum`/`iCon`/`iSim`→`iLuminance`/`iContrast`/`iSimilarity`/`iTarget` (from `iTar`) are the same rename in both files, since the former calls the latter and passes results back and forth under these names.

**Calls to `analysis.*` and `nm.analysis.*` were left exactly as written, not repointed to `experiment.analysis.*`.** `computeThresholdsVsStatistic.m`, `compute_thresholds_vs_lum_cont.m`, and `computeBootstrappedThreshold.m` all call an unqualified `analysis.*` or `nm.analysis.*` function that does not resolve (B2.9, pre-existing) — adding the missing `experiment.` prefix would be an obvious-looking one-word fix, and is exactly the kind of call-site repair Stage 1 forbids (it changes what the AST resolves to, which is a real behaviour change, not a rename). Left alone and cited to B2.9 in each file's header.

**Line-length exceptions — two, both commented-out (dead) lines**, left byte-identical rather than reflowed, same reasoning as every earlier tranche: `computeThreshold_edgeResponse.m` post-edit line 129 (a sketch of a never-written `fitPsychometric_edgeResponse` two-stage fit, part of triage block T5.5 below) and `computeThreshold_texture_exponent.m` post-edit line 165 (the commented `rectangle(...)` alternative to the live `errorbar(...)` call two lines below it). Every live line in all 12 files is under 100 characters; the large `computeThreshold_*` family needed extensive `...` continuation with a four-space hanging indent to get there, since several lines packed 4–5 statements or an 8-argument call onto one line.

**Line endings: this directory's own pre-existing convention is CRLF, confirmed and preserved, not creep.** All 12 pre-edit files were already 100% CRLF (verified: `grep -c $'\r'` equals `wc -l` exactly, for every file, both before and after editing) — unlike `+lib/`'s uniform LF, this directory (all authored by Steve Sebastian/Jared Abrams per the file headers) was CRLF from the start. Preserved throughout; this was checked explicitly rather than assumed, per the skill's CRLF-creep warning, and the new `Contents.m` (a genuinely new file, no pre-existing convention to match) was written LF to match every other `Contents.m` in the repo (e.g. `+experiment/+main/Contents.m`).

**Contents.m — written**, `+experiment/+analysis/Contents.m`, covering all 12 in-scope files (this tranche cleans the whole in-scope set in one pass, so per 0.1.1's precedent for a fully-cleaned package, no deferral was needed). Notes the `analysis.*`/`nm.analysis.*` resolution gap (B2.9) and that the 7 `_`-prefixed files are excluded pending S3.6.

**Bugs found: one new, recorded in section 0.4 and not fixed.**

- 🟠 **B2.17.** `+experiment/+analysis/plotThresholdvsCondition_mine.m` references an undefined variable `dur` and errors immediately if run — same class as tranche 0.1.4's B2.16 (an ad-hoc, uncalled scratch script), so filed at the same severity.

Nothing else new: `B3.9` (`computeThreshold_edgeResponse.m`'s function name vs. filename), `B3.10` (the undefined-variable Bootstrap block in the same file), `B2.9` (the `analysis.*`/`nm.analysis.*` resolution gap), `B2.11` (the hardcoded Dropbox paths in `computeBootstrappedThreshold.m`), and `B3.4` (`computeTemplateResponseSigma.m`'s `size(...<300)` and loop-bound issues) were all re-confirmed by reading these files and are cited in the relevant files' headers rather than re-filed.

**Commented-out code — triaged below in section 4.1.4 (T5.1–T5.5).** Five blocks/fragment-groups found across `computeNegLogLikelihood.m`, `computeNegLogLikelihood_edgeResponse.m`, `fitPsychometric.m`, and `computeThreshold_edgeResponse.m`, all variants on the same theme: an earlier, more general form of the fit (a 4-parameter model with `mu` free, or a per-trial rather than per-level-summarized likelihood, or a bias-aware edge-response likelihood) that was fixed/simplified down to what's live today. None were previously listed in section 4.1.4's sizing table for this directory except the one `computeNegLogLikelihood.m` row; the rest are new, found on first read of each file, per the skill's triage-at-read-time rule. All verdicts are **alternative** or **unfinished** — nothing here was judged **superseded**, since in every case the live code is a genuine simplification (fewer parameters, or a different pooling rule) rather than a strict improvement on the same computation.

**Stage 2 not attempted** — this tranche's Stage 2 is item 0.2.2, pattern-check only except the three psychometric functions named above (golden-checked here as a bonus, formally item 0.2.2's job). The four patterns, surveyed across all 12 files: `NOSEMI` none (the pre-existing `checkcode` `NOSEMI`-free state was preserved); `AGROW` several, all pre-existing and unchanged (the `exp_values`/`bTarget`/`hit`/`correct_reject`/`correct` pooling loops in the `computeThreshold_*` family, `thresholds`/`thresholdsStd` in `computeThresholdsVsStatistic.m`, `patchIndex`/`tMatch`/`scaleFactor` in `computeTemplateResponseSigma.m`); `find` none present anywhere in this directory; unused assignments unchanged (`blank_mean`, `mu_sd` in the `computeThreshold_*` family — both pre-existing `NASGU`s, not introduced and not touched).

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">4.1.4 Commented-out code — triage verdicts</h4></summary>

<div style="margin-left:1.5em">

**Sizing pass (survey).** 780 commented-out code lines across 81 of the 164 in-scope files — full totals in section 1. Below are the **37 contiguous blocks of 5 or more dead-code lines**, which is the actual triage worklist; the remaining ~230 lines are scattered one- and two-line fragments, triaged in passing when their file is read. A *block* here is a run of full-line comments allowing at most two non-comment lines of interruption, trimmed to start and end on a dead-code line; `lines` is that span and `count` is the number of dead-code lines inside it, the remainder being prose or bare `%` interleaved in the dead region. The classification is heuristic (MATLAB statement syntax, with each file's leading help block always treated as prose) and is good to roughly ±10 %, most likely a slight undercount. **Nothing here has been judged.**

| file | lines | dead lines | tranche |
|---|---|---:|---|
| `+lib/edge_props_stim.m` | 275-534 | 160 | 2 |
| `+lib/edge_props_stim.m` | 70-94 | 20 | 2 |
| `+general/compute_edge_powers_pink_noise.m` | 11-34 | 19 | 8 |
| `+general/compute_noise_colour.m` | 104-123 | 18 | 8 |
| `+general/fit_edge_model_with_exps.m` | 159-186 | 18 | 7 |
| `+general/compute_edge_props_exp_full.m` | 72-89 | 17 | 8 |
| `+general/fit_edge_model_with_exps.m` | 115-147 | 17 | 7 |
| `+lib/edge.m` | 115-134 | 16 | 1 |
| `+general/plot_contour_props.m` | 82-122 | 15 | 8 |
| `+general/compute_edge_props_exp.m` | 26-38 | 13 | 8 |
| `+general/compute_edge_props_exp_eq.m` | 27-39 | 13 | 8 |
| `+general/compute_edge_props_exp_full.m` | 27-39 | 13 | 8 |
| `+general/compute_edge_props_exp_pca.m` | 29-41 | 13 | 7 |
| `+general/compute_edge_props_exp_raw.m` | 34-46 | 13 | 8 |
| `+lib/edge_measures.m` | 39-51 | 13 | 1 |
| `test.m` | 4-17 | 13 | 11 |
| `+experiment/setUpExperiment.m` | 52-64 | 11 | 6 |
| `+experiment/saveCurrentLevel.m` | 24-33 | 10 | 6 |
| `+lib/target_mask.m` | 52-61 | 8 | 1 |
| `+lib/edge_props_stim.m` | 112-118 | 7 | 2 |
| `+experiment/+analysis/computeNegLogLikelihood.m` | 24-32 | 6 | 5 |
| `+general/compute_nat_img_eff_coding_bins.m` | 170-175 | 6 | 7 |
| `+lib/csf_err.m` | 15-20 | 6 | 3 |
| `+lib/edge_props_stim.m` | 134-139 | 6 | 2 |
| `+lib/steerable_filter.m` | 23-30 | 6 | 1 |
| `+tinker/whitened_pn_stim_edge_energy.m` | 42-48 | 6 | 10 |
| `+tinker/whitening_tinker.m` | 21-28 | 6 | 10 |
| `+experiment/+analysis/computeNegLogLikelihood_edgeResponse.m` | 50-54 | 5 | 5 |
| `+experiment/+main/runCamouflageExperiment_search.m` | 47-51 | 5 | 4 |
| `+experiment/setUpExperiment.m` | 71-77 | 5 | 6 |
| `+general/compute_edge_props_exp.m` | 4-13 | 5 | 8 |
| `+general/compute_edge_props_exp_eq.m` | 5-14 | 5 | 8 |
| `+general/compute_edge_props_exp_full.m` | 5-14 | 5 | 8 |
| `+general/compute_nll_edge_model.m` | 44-48 | 5 | 7 |
| `+general/plot_contour_props.m` | 7-17 | 5 | 8 |
| `+tinker/pink_noise_seed_multiple_energies.m` | 27-39 | 5 | 10 |
| `+tinker/whitening_tinker.m` | 5-12 | 5 | 10 |

Two things to know before triaging these. **`+lib/edge_props_stim.m:275-534` is one single continuous dead region**, not several: line 271 is a live `%% edge contour properties` section header, 272-274 are commented prose, and there is no live code anywhere between 275 and 534. It is the per-contour length/position/orientation/curvature half of the ideal-observer statistic, and it is why 16 to 30 of that function's 30 declared outputs are never assigned. **The five `compute_edge_props_exp*.m` files carry near-identical blocks at the same relative positions** (rows 10-14 and 31-33 above), which is a strong hint that they are copies of one another; triage them together and give them the same verdict, or you will delete a block from one file and keep it in its twin.

**Triage.** One row per block, added as each Stage 1 tranche reaches the file it is in, not deferred to a separate pass. Filled in by reading the surrounding code, **not the git history** — the history in this repo was not written with this question in mind, and a commit message saying "cleanup" tells you nothing. Verdicts: *superseded* (the live code beside it does the same job better — name that live code) → delete; *scaffolding* (a stray debug print, plot, timer, or `keyboard`) → delete, or promote to a real debug flag if genuinely useful; *alternative* (a method, parameter set, dataset, or path the author switched away from and could switch back to) → keep, but convert it into a documented option or a note in the header docs; *unfinished* (a sketch never completed) → keep, rewritten as a prose TODO; *unknown* (purpose not recoverable from the surrounding code) → leave exactly as is.

**Unknown is the default whenever the evidence runs out.** An honest *unknown* costs a few commented lines; a wrong *superseded* destroys the only copy of code that was written commented-out and so was never live, meaning it is nowhere in the history to recover from. This repo makes that risk concrete: much of `+general/` and `+tinker/` is exploratory work whose alternatives were never committed in live form.

Acting on a verdict — deleting or converting — is Stage 3 (S3.16), never done here. Note that `check_stage1` **cannot see a commented-out block disappear**, because `canon` strips comments before comparing; triaging inside the same tranche that touches the file is what closes that gap, by judging each block at the one moment nothing has had a chance to make it vanish unassessed.

Line numbers in the `file:lines` column are **pre-edit**, matching the sizing table above, so that a row can still be found in `git show` of the commit before its tranche.

| block | file:lines | tranche | what the surrounding code says it was for | verdict |
|---|---|---|---|---|
| T1.1 | `+lib/edge.m:115-134` | 1 | A complete, working computation that splits the edge vector into runs of constant sign — "contour groups" — and returns each group's length and mean squared edge. Nothing in the live code does this. It is not abandoned downstream: `+general/compute_edge_group_measures.m:20` still destructures `lib.edge`'s outputs 3 and 4 as `l_groups, e_groups` (that is B1.5), and `lib.edge_response(l, e, th, n)` consumes exactly that pair of vectors. So the author switched the function's outputs 3 and 4 to a field and an angle grid and left the group code commented, but the model chain was never switched with it. | **alternative** — a real method the author switched away from and that a live caller still expects. Keep. S3.16 converts it, and S3.4 should decide whether the group statistic is part of the canonical edge measure before anything is deleted. |
| T1.2 | `+lib/edge_measures.m:17` | 1 | `all_edges=edge(stim,'canny',[.2 .3]); % threshold for foliage` — a Canny detector with a hand-tuned threshold, sitting directly above the live `edge(stim,'zerocross',1e-3,edge_kernel)` on the next line, which carries the same trailing comment. Two detectors for one job; the author kept the zero-crossing one. | **alternative** — a different method with its own tuning. Convert to a documented `'method'` option, or record the switch and its threshold in the header. |
| T1.3 | `+lib/edge_measures.m:30,33` | 1 | `d_n=(n_bdry_edges-n_bdry*txtr_edge_density)/sqrt(...)` and `response=d_n;`, under a live section header `%% compute edge density d'`. It references `n_bdry_edges`, `n_bdry` and `sig_n`, none of which exist in the function — the live code computes `n_bdry_edge_pixels` and `txtr_edge_density` but never combines them. This is the d' the section header promises and the function never delivers. | **unfinished** — a sketch that was never completed and cannot run as written. Keep, rewritten as a prose TODO naming the two live quantities it would combine. |
| T1.4 | `+lib/edge_measures.m:35,39-51` | 1 | A per-contour loop computing each contour's length and mean squared edge, using `lib.contour_props`, `stim_grad_x`, `stim_grad_y` and `stim_std`. None of those four exist in this function — no gradient is ever computed here — so the block was pasted in from a context that had them (it is close kin to T1.1) and never wired up. | **unfinished** — keep, as a prose TODO. Do not treat it as superseded by T1.1: they compute over different contour sets (all image contours here, boundary groups there). |
| T1.5 | `+lib/target_mask.m:51-56` | 1 | Explicitly labelled "check if boundary point (old method)": an 8-neighbour test inside the pixel loop, setting `mask_edge_old`. The live line 65, `mask_edge=bwperim(mask,4)|bwperim(~mask,4)`, computes the same boundary with a library call and works for both shape branches. | **superseded** by `+lib/target_mask.m:65`. Delete. |
| T1.6 | `+lib/target_mask.m:58-61` | 1 | Labelled "new method" by the author: a 3×3 `unique` test, again per pixel. Same job as T1.5 and same job as the live `bwperim` pair, which is what actually shipped — so the author's "new method" was itself superseded before it went live. | **superseded** by `+lib/target_mask.m:65`. Delete. |
| T1.7 | `+lib/target_mask.m:74,80` | 1 | A commented `if mask_edge(i,j)` / `end` wrapping the normal-vector assignment in the circular branch. With it commented out, the branch fills a unit normal at *every* interior pixel rather than only on the boundary; the noisy branch does mask to the boundary (`:93`). Every caller indexes the normals by `mask_edge` anyway, so the difference is invisible in output and costs only time. Whether it was commented out for speed, for debugging, or by accident cannot be told from the code. | **unknown** — the evidence runs out. Leave exactly as is. The resulting circular-vs-noisy asymmetry is documented in the file's header instead. |
| T1.8 | `+lib/target_mask.m:84-85` | 1 | `imgradientxy(mask)` with a sign flip on the x component, directly above the live `imgradient(~mask)` plus `cosd`/`sind` at `:86-88`. Same normals, obtained from the gradient direction instead of its components; the live version avoids the manual sign flip. | **superseded** by `+lib/target_mask.m:86-88`. Delete. |
| T1.9 | `+lib/target_mask.m:90-92` | 1 | A third route to the same normals, `lib.steerable_grad(~mask,[1 3])` followed by `vecnorm` normalisation. Note the call is positional and would error today for the reason in B2.3, so it is not even revivable as written. | **superseded** by `+lib/target_mask.m:86-88`. Delete. |
| T1.10 | `+lib/target_mask.m:6,15` | 1 | A commented `'seed'` name-value parameter and its retrieval. The function's only randomness comes from `lib.create_pink_noise_line`, and the live design seeds the whole stimulus once in `lib.stimulus` (`rng('default'); rng(seed)`) before calling here — so a second seed on this function would be at best redundant and at worst would break the one-seed-one-stimulus property S3.1 depends on. | **superseded** by the seeding at `+lib/stimulus.m:82-83`. Delete. |
| T1.11 | `+lib/steerable_filter.m:21-24` | 1 (the sizing table says 3; the file is in tranche 1's list, so it was triaged here) | Normalising the two kernels by their L2 norm, with the author's own reason attached — "so that larger filter responses aren't bigger simply due to size". That is a real alternative normalisation convention, and the live code instead normalises the *response* in `lib.steerable_grad`, which is not the same thing. | **alternative** — the reasoning is already moved into the file's header by this tranche; S3.16 should delete the code and keep the prose, or promote it to an option. |
| T1.12 | `+lib/steerable_filter.m:26-30` | 1 | Five lines that gamma-correct and `image()` one kernel page to look at it. | **scaffolding** — delete, or promote to a `bPlot` flag if anyone actually wants to see the kernel. |
| T1.13 | `+lib/steerable_grad.m:47-50` | 1 | An earlier version of the paste-the-valid-region step, padding by `kernel_size(1)*kernel_size(2)`. The live code at `:35-45` derives the paste indices from the actual kernel's row and column counts, which is correct for a non-square kernel and for an even width; the commented version assumes the radius formula and is wrong whenever a `'filter'` is passed in directly instead of a `kernel_size`. | **superseded** by `+lib/steerable_grad.m:35-45`. Delete. |
| T1.14 | `+lib/steerable_grad.m:64` | 1 | `% stim_sd=std(stim(:));` — normalise by the image's global sd instead of the per-pixel local sd on the line above. That is a materially different model of contrast normalisation, and it is exactly the axis B1.1 turns on. | **alternative** — keep. Do not delete this one until S3.4 has picked a canonical edge-power definition; it is evidence about what the author was weighing. |
| T1.15 | `+lib/edge_vector_ideal.m:51-54` | 1 | A `scatteredInterpolant` nearest-neighbour theta field over the whole image, then masked to the edge. The live `knnsearch` at `:50` plus the loop at `:55-57` assigns theta only at edge pixels — same result where it matters, without interpolating 65k pixels. | **superseded** by `+lib/edge_vector_ideal.m:50,55-57`. Delete. |
| T1.16 | `+lib/edge_vector_ideal.m:73` | 1 | `% th_edge=th_edge(unique_idx_1,:);` — deduplicate thetas by keeping the first row of each. `unique_idx_1` exists nowhere in the file, and the live `unique` + `groupsummary` pair at `:79-80` deduplicates by *averaging* the degenerate thetas instead, which is the better answer and is what `lib.edge` also does. | **superseded** by `+lib/edge_vector_ideal.m:79-80`. Delete. |
| T1.17 | `+lib/edge_response.m:8-9` | 1 | Two lines. `e_sup(isinf(e_sup))=e_tot(isinf(e_sup))-log(1+k);` patches infinities in the suppressed powers, but `e_tot` and `k` exist nowhere in the file, so it cannot be switched back on. `r=mean(e_sup);` is a complete earlier pooling rule — an unweighted mean, against the live length-weighted sum divided by `numel(e)+n`. | **unfinished** for the `e_sup(isinf(...))` line; **alternative** for `r=mean(e_sup)`. Keep both: TODO prose for the first, a header note for the second recording that pooling was changed from an unweighted mean to a length-weighted, count-offset sum. |
| T1.18 | `+lib/edge_shape.m:44` | 1 | `%th_lags=th_lags(1:end-1);` — trim the last lag. The live code sizes `n_corr=floor(n_th/2)+1` and allocates `edge_autocorr` to exactly that length, so trimming `th_lags` alone would leave the two vectors mismatched. The off-by-one this line was reaching for is already handled by the sizing. | **superseded** by `+lib/edge_shape.m:42,45`. Delete. |
| T1.19 | `+lib/edge_energy.m:78` | 1 | `%e=rms(edge_normal(:));` directly under the live `e=rms(edge_normal(:))/rms(edge_mag(:))` — the same measure without the normalisation by gradient magnitude. | **alternative** — a normalised/unnormalised pair, the same choice as B1.1 in miniature. Convert to a note in the header rather than deleting silently. |
| T1.20 | `+lib/stimulus.m:78-79` | 1 | `seed_struct=rng('shuffle'); seed=seed_struct.Seed;` above the live `seed=randi(intmax)`. Both produce an unpredictable seed; only the live one produces a seed drawn from the *current* stream, and `rng('shuffle')` is precisely the pattern the plan's harness rules warn about. | **superseded** by `+lib/stimulus.m:80`. Delete. |
| T1.21 | `+lib/stimulus.m:124` and `:181` | 1 | `% texture_bg=struct;` and `% texture=struct;`, each immediately before the line that writes `.stats` into that struct. Reinstating either would wipe `.type` and `.img`, which the following lines and the later branches still read — `:186` branches on `texture_bg.type`. So the author tried clearing the struct and the surrounding code depends on not clearing it. | **superseded** by the live `texture_bg.stats = ...` / `texture.stats = ...` lines, which deliberately preserve the other fields. Delete. |
| T1.22 | `+lib/compute_pClipped.m:8` | 1 | `%fprintf('%f of boundary ribbon clipped\n', pClipped);`, the entire content of an otherwise empty `else` branch: print the clipping fraction when it is below the 1 % warning threshold. | **scaffolding** — delete, together with the now-empty `else`, or promote to a verbosity flag. Note the message text is the same one B2.14 is about, so fix that wording at the same time. |
| T2.1 | `+lib/edge_props_stim.m:52` and `:158-159` | 2 | Two one-liners for the same idea, in two incompatible places: `% grad_mag_bins(:,1)=grad_hist_thresh;` would push the lowest histogram bin edge up to the threshold, and `% grad_mag(grad_mag<grad_hist_thresh)=0;` would instead zero sub-threshold gradients before histogramming. Neither can run as written — `grad_mag_bins` and `grad_mag` are not variables in this function (the locals are `grad_m_bins` and `grad_mag_a`/`grad_mag_b`). Together they are the whole reason the `'grad_hist_thresh'` parameter is retrieved at `:49` and never used, which is the `NASGU` `checkcode` flags there. | **unfinished** — two sketches of one feature, neither completed. Keep, rewritten as a single prose TODO that names the live variables each would have to act on and records that the parameter is dead until one of them is finished. |
| T2.2 | `+lib/edge_props_stim.m:70-72` and `:75-94` | 2 | `:75-94` is the earlier form of the live gradient loop at `:96-109`: it allocates `grads` 5-D with a trailing region dimension and NaN-masks the cropped gradient twice — once outside the boundary ribbon (region a) and once inside it (region b). The live loop dropped that dimension, but the live histogram loop at `:161-162` still reads `grad_mags(:,:,i_scale,2)`. **That missing dimension is exactly B2.2**, so this is not superseded: the live code still depends on it. `:70-72` belongs to the same era — `grad_mag_bins{5}=[-inf inf]` and its two siblings use cell indexing against a local that is now a matrix, and would collapse the coarsest scale to one bin for `'tex'` stimuli. | **alternative** for `:75-94` — the working form of what the live code assumes, and the most likely basis of the B2.2 fix. Keep; do not delete until B2.2 is fixed, and note that it passes no `'normalize'` on either branch where the live camo branch passes `'normalize', false`, so reviving it verbatim also changes the normalisation (S3.4's question). **unknown** for `:70-72` — the effect is clear (neutralise the sigma-16 histogram for texture stimuli) but *why* only scale 5 is not recoverable from the surrounding code. Leave exactly as is. |
| T2.3 | `+lib/edge_props_stim.m:112-118` | 2 | The PCA rotation written for the 5-D `grads` layout of T2.2 — `permute(grads,[1 2 5 4 3])`, flatten, multiply, unflatten — ending with `grads=grads_pca;`. The live block at `:121-131` does the same job for the current 4-D layout but **omits that final assignment**, which is B3.15. | **alternative** — it is the version that matches T2.2's layout, and it is the evidence for what the live block's missing last line should be. Keep until B2.2 and B3.15 are both settled; S3.16 should then convert it into a header note rather than delete it silently. |
| T2.4 | `+lib/edge_props_stim.m:134-139` and `:165-166` | 2 | `:134-139` is a third PCA variant, `reshape(grads,stim_sz^2,2*num_scales)` with no `permute`, so the ten feature columns come out component-fastest; the live block at `:121-131` permutes first and so feeds them scale-fastest, which its own comment spells out. The two are not better and worse, they assume **different `pca_coeffs` column orders**. Its own `% grads=grads_pca;` is commented out inside the dead block, so it was never finished either. `:165-166` recomputes `N_a`/`N_b` per scale as `nnz(~isnan(grad_mag_a))`, against the live `:63-64` which counts boundary-ribbon pixels once for all scales — so the live denominators include the NaN border that grows with kernel size. | **alternative**, both. Keep. Which feature ordering matches how `pca_coeffs` was computed, and whether the LLR denominator should be per-scale or fixed, are open method questions for S3.4/S3.16, not cleanup decisions. Neither is filed as a bug: the author clearly weighed both, and the evidence does not say which side is right. |
| T2.5 | `+lib/edge_props_stim.m:275-300` | 2 | Opening of the single 260-line dead region (`:271` is a live section header and there is no live code anywhere from `:275` to the end of file). Detects edge pixels with `lib.detect_edge_pixels`, splits them into region a/b by the boundary ribbon, and traces them into contours with `lib.trace_contours`. Both helpers exist in `+lib/` and both are otherwise uncalled. | **alternative** — a working entry point to a method the author switched off wholesale, whose helpers are still shipped. Keep. |
| T2.6 | `+lib/edge_props_stim.m:303-399` | 2 | The per-contour property loop: length in pixels, distance from the true target boundary, edge power at each of the five scales, cosine alignment with the target normal, and curvature sd. It is largely complete, but `:328` uses `target_center` and `target_radius`, neither of which is ever defined in this function, so it **cannot be revived verbatim**. It also contains the author's own nested deactivations at `:316-318` (true arc length, replaced by pixel count with the reason written down), `:333-344` (contour tangent and normal) and `:346-349` (absolute orientation, "not used in camouflage"). | **alternative** with a caveat — the method is recoverable but the position term is not, so it is partly **unfinished**. Keep both halves; S3.16 must not treat "it's all one block" as licence to revive it as-is. The three nested deactivations are themselves *alternative*/*scaffolding* and already carry the author's reasons, which should move into header prose. |
| T2.7 | `+lib/edge_props_stim.m:401-534` | 2 | The summary half: placeholder structs when a region has no contours, the edge-pixel-count LLR, the contour-count LLR, and same/different LLRs for the exponential distributions of position, length, orientation alignment, curvature and the five edge powers. **This is the code that would assign the fifteen never-assigned outputs in the live signature** (`npix_llr` … `ep16_llr`), which is why `checkcode` reports fifteen `STOUT` messages. The interleaved `% contour_props_summary.*_mean=...` lines at `:419-433`, `:450`, `:452-453`, `:460` and `:470-474` are a *second*, earlier output convention (a summary struct) that the flat output list replaced. | **alternative** for the LLR computations — they are the declared-but-unfilled half of this function's contract and cannot be deleted without a signature change, which is Stage 3 anyway. Keep. **superseded** for the `contour_props_summary` fragments, by the flat `*_llr`/`*_sum` output list in the live signature. |
| T2.8 | `+lib/edge_props_stim.m` — whole-file note | 2 | Recorded so a later reader does not re-derive it: `test.m:40` and `+general/compute_edge_props_pink_noise.m:22,35` call this function expecting **two** outputs named `contour_props`/`mean_contour_props`, a signature that no version in the tree has. Those call sites predate even the dead block. | — (not a block; context for T2.5–T2.7.) Neither call site is in this tranche; they belong to tranches 11 and 8. |
| T3.1 | `+lib/csf_err.m:15-20` | 3 | `sz=size(z); for i=1:sz(2); if z(i)<=0; z(i)=10^-20; end; end` sits right after `z=z/max(z)` and right before `e=sum((log(z)-log(z0)).^2)`. It clamps non-positive model ATF values to a tiny positive number before the fit takes their log — a guard against `log(0)=-Inf` or a complex log of a negative value that the live code does not have. Whether the live code actually needs it (i.e. whether `lib.csf_floating`'s output can go non-positive over the frequency ranges this is fit against) is not answerable from the surrounding code alone. | **unfinished** — a defensive clamp the author sketched and never turned on. Keep, rewritten as a prose TODO naming the two live variables (`atf`, the normalised ATF, and the fit target `human_atf`) it would guard. |
| T3.2 | `+lib/csf_spatial_filter.m` (post-edit line 34, pre-edit last line) | 3 | `h=h(128-50:128+50,128-50:128+50);` directly under the live `h=fftshift(ifft2(ifftshift(csf_fil)));`. Crops the 256x256 spatial filter down to a 101x101 window around its center; the live code keeps the full 256x256. | **alternative** — a smaller-output-size variant the author tried and left off. Keep. |
| T3.3 | `+lib/subplot_tight.m:49-50` | 3 | `% h_subplot=subplot(m,n,p,varargin{:},'Position',pos_vec);` directly above the live `h_subplot=subplot('Position',pos_vec,varargin{:});`, with the author's own explanation on the next commented line: `subplot` ignores `'Position'` when the same `(m,n,p)` triple as an existing axes is passed. | **superseded** by the live line just below, reason already given inline by the author. Keep as documentation of why the call is shaped this way; nothing to convert beyond what the comment already says. |
| T3.4 | `+lib/autocorr.m:12` (pre-edit) | 3 | `% c=corrcoef(stim(:),stim_shifted(:));` directly above the live `r(i,j)=dot(stim(:),stim_shifted(:));`. `corrcoef` returns a normalised correlation coefficient (mean-subtracted, scaled by variance); `dot` is a raw, unnormalised energy product — a materially different statistic, and the commented line's own result (`c`) is never read even where it is live. | **alternative** — a normalisation choice the author moved away from, same axis as the edge-power normalisation questions (B1.1/S3.4) in miniature. Keep, note added inline. |
| T3.5 | `+lib/detect_edge_pixels.m:7` (pre-edit) | 3 | `% edge_detection_filter=lib.diff_of_gaussians_filter(2,4,2);` directly above the live `edge_detection_filter=lib.laplacian_of_gaussian_filter(2,3);`, both feeding the same `addParameter` default. Two edge-detection filter shapes for the same job; the author kept the Laplacian-of-Gaussian one. | **alternative** — a different filter with its own parameters. Convert to a documented filter-choice option, or record the switch in the header, per S3.16. |
| T3.6 | `+lib/embedImageinCenter.m:30` (pre-edit `if(~exist('tWin', 'var')) || isempty(tWin) ... end`) | 3 | `%     warning('If you are using an occluding target you need a window. Execution may crash if no window is supplied');` — the entire body of an `if` branch that otherwise does nothing when `target_window` is not supplied. A stray warning the author considered and left off; the branch is a no-op either way. | **scaffolding** — delete, or promote to a real warning, per S3.16. |
| T4.1 | `+experiment/+main/displayLevelStart.m:39-45` (pre-edit) | 4 | A commented `if SessionSettings.bFovea ... else ... end` wrapping the draw order of the target outline and the fixation cross. The commented (foveal) branch would draw target then cross; the live, unconditional code below it — originally the `else` — draws target then cross **on top**, for every run regardless of `bFovea`. Not found by the survey's heuristic sizing pass (block is 7 lines, above its 5-line threshold, but was missed); found and triaged here on first read of the file, per the skill's rule that this is not a separate pass. | **alternative** — a real branch the author switched away from in favour of one fixed draw order. Keep; ties into S3.17's open `bFovea` question (`loadStimuliCamouflage.m:16` currently hardcodes `bFovea = 1`, so the commented branch is unreachable from the live entry point anyway). S3.16 should convert to a header note rather than delete. |
| T4.2 | `+experiment/+main/giveFeedback.m:20,23,26` (pre-edit) | 4 | Three one-line `%sound(correctTone/incorrectTone/errorTone, sampleFreqHz)` calls, one per response branch, each directly under a live `Beeper(...)` call playing the same semantic tone. Below the 5-line block threshold; triaged in passing while reading the file. | **alternative** — the author switched from a synthesised tone played via `sound` to a fixed system beep via `Beeper` for all three branches; the three `*Tone` variables are still computed above (source of the pre-existing, unchanged `NASGU` lint) but only these commented lines would ever read them. Keep; S3.16 must decide together whether to delete the now-unused tone computation alongside the commented calls, or convert the switch into a header note and leave the computation as a documented option. |
| T5.1 | `+experiment/+analysis/computeNegLogLikelihood.m:17-18,24-30,32-33,38,40` (pre-edit) | 5 | Three related fragments, all reachable within a couple of live lines of each other. `mu=p(1);`/`mu=0;` above the live `a=p(1)` sketch an earlier 4-parameter model (mu free) that the live 3-parameter model (mu fixed at 0 by every caller) replaced. `y_bm=...`/`yc=...`/`y=...`/`z=y-yc` plus `ll=sum(log(normcdf(z(response)/2)))+...` reference `response`, `blank_mean`, `y_t`, none of which exist in this function — an earlier per-trial-response likelihood, replaced by the live per-level summarized hit/correct-rejection binomial counts. `p_c=(p_h+p_cr)/2;` and `p_c=normcdf(d/2);` are two ways to get a combined "probability correct" that the live code never needs, since the binomial likelihood at the end uses `p_h`/`p_cr` directly. | **alternative**, all three. Keep; S3.16 should fold the mu-fixed-at-0 and per-trial-vs-summarized decisions into header prose — the same decision recurs at T5.3/T5.4 in this tranche's other files, so one shared note may cover all of them. |
| T5.2 | `+experiment/+analysis/computeNegLogLikelihood_edgeResponse.m:50-54` (pre-edit) | 5 | "incorporating bias": `p_h=normcdf(d*(1-gamma)/2);`, `p_cr=normcdf(d*(1+gamma)/2);`, `p_c=(p_h+p_cr)/2;`, and a `ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...` binomial likelihood using the per-level hit/correct-rejection split — a complete, bias-aware alternative to the live code two lines above, which instead computes a single bias-free `p_c=normcdf(d/2)` and a combined-correct likelihood (`bOpt` branch: `mean(p_c)`; else: `binopdf(num_hits+num_cr,nTrials,p_c)`). The bias term is named `gamma` here, never defined elsewhere in this file. | **alternative** — a real, complete method the author moved away from in favour of a simpler bias-free model for the edge-response variant. Keep; S3.16 should convert to a header note, and should decide whether `n_targets`/`n_blanks` (accepted as parameters, read only by this dead block) should be dropped from the signature at the same time — that is a signature change, so it can't happen here. |
| T5.3 | `+experiment/+analysis/fitPsychometric.m:16-28` (pre-edit) | 3 | `n_levels=size(exp_values,2);` through a loop computing `mu_blanks(level)`/`mu_targets(level)` from raw `exp_values`/`bTargetPresent` — an earlier version of this function that computed `target_means` itself from per-trial data, before the API changed to receiving `target_means` already computed by the caller (every live caller, e.g. `computeThreshold_edgePower.m:57`, does this itself now). Not previously listed in section 4.1.4's sizing table (the table under-counts by its own admission); found on first read of this file. | **superseded** — by the live signature, which takes `target_means` as an input rather than computing it. Delete once S3.16 reaches it. |
| T5.4 | `+experiment/+analysis/computeThreshold_edgePower.m:62-64,96-97` and `+experiment/+analysis/computeThreshold_texture_exponent.m:96-97` (pre-edit) | 5, 5 | Two one-line fragments per file: `blank_mean=mean(SubjectExpFile.edgePowers(~SubjectExpFile.bTargetPresent));` and `mu_init=blank_mean;`, both superseded by the live `mu=0;` a few lines later — the same mu-fixed-at-0 decision as T5.1, recorded a third and fourth time. Below the 5-line block threshold in both files; triaged in passing. | **superseded** — by the live `mu=0` in each file. Same underlying decision as T5.1; S3.16 should write one header note that covers all four sites (this pair, plus T5.1's `computeNegLogLikelihood.m` and `fitPsychometric.m`'s own `% mu=params(1);`) rather than four separate notes. |
| T5.5 | `+experiment/+analysis/computeThreshold_edgeResponse.m:8,33,67-69` (pre-edit) | 3, 3 | `%     stim_n_groups=[];` and, inside the pooling loop, `%             stim_n_groups=[stim_n_groups; ExpSettings.stim_n_groups(:,:,idx)];` — an earlier plan to pool a third contour-count group alongside `stim_l_groups`/`stim_e_groups`, never finished (`ExpSettings.stim_n_groups` is never read live). Separately, `[alpha,beta] = experiment.analysis.fitPsychometric_edgeResponse(alpha_init, beta_init, stim_n_groups,stim_l_groups,stim_e_groups,bTarget,num_blanks,num_targets, num_hits, num_cr); mu=0; threshold=mu+a;` sketches a second-stage fit function that was never written (`fitPsychometric_edgeResponse` does not exist anywhere in the tree) — this is also the source of this file's one documented line-length exception (189 chars, left byte-identical). Both fragments are below the 5-line threshold; triaged in passing. | **unfinished**, both. Keep, rewritten as prose TODOs — the first naming `ExpSettings.stim_n_groups` as the data that was never wired up, the second naming the sketched `fitPsychometric_edgeResponse` two-stage fit. |

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">4.2 Stage 2 — coverage gaps and work log</h3></summary>

<div style="margin-left:1.5em">

**Coverage gaps, decided at survey time rather than discovered later.** The runtime golden harness can only reach the `+lib/` core chain and the three psychometric functions, for the reasons set out in section 2. Every other tranche is therefore **pattern-check only**, and this is a recorded decision: `+general/`, `+tinker/`, `+vis/` and `+tests/` are top-level scripts with no callable entry point; `+experiment/+main/` is hardware-bound; `+experiment/` top level writes into `exp_files/`; and the non-psychometric half of `+experiment/+analysis/` needs loaded session `.mat` files. Restructuring any of them into functions is itself Stage 3 (S3.7), so it cannot be used to make Stage 2 verifiable here.

**Per-tranche work log.** Each entry records either the fix (which pattern, how it was rewritten, how it was verified, and the golden-replay result) or an explicit "no Stage 2 edits" that names all four patterns and says why each has no target in this tranche. A documented negative is the evidence the tranche was actually examined.

*Not started.*

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">4.3 Stage 3 — work log</h3></summary>

<div style="margin-left:1.5em">

Fills in as each Stage 3 item from section 0.3 is actually done, one item per invocation (`matlab-cleanup-stage3` or `-stage3-mechanical`, per the item's own tag in section 0.3), never a batch. Commented-out code was already triaged in Stage 1 (section 4.1.4), so this log records only what was actually deleted or converted as a result, citing the verdict row it acted on.

*Not started.*

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">4.4 Stage 4 — bug work log and severity crosswalk</h3></summary>

<div style="margin-left:1.5em">

Bugs discovered while doing Stage 1/2/3 are recorded in section 0.4 as they are found, each with its `B<severity>.<n>` id and emoji; their fixes, done last and in that order, get logged here — what was wrong, the fix, and how it was verified (call-site search, not a mechanical check). If a severity turns out to have been misjudged once the bug is looked at properly, say so here and re-file it in 0.4 under the correct severity's next `n`: it gets a new id, the old one is not reused, and nothing else in the list is renumbered.

*No fixes started.*

**Crosswalk from the old `CODEBASE.md` severity scheme.** That document used S1 (silently wrong) / S2 (crashes on a live path) / S3 (crashes on a dead path) / S4 (cosmetic or latent), and numbered its findings B1–B24 in a single sequence. Those ids do **not** match the ids in section 0.4 — old B1 and new B1.1 happen to be the same bug, but old B2 is new B2.1 while old B3 is new B1.2, and so on. Use this table to resolve any older note or commit message. Several old entries bundled two or three distinct bugs and have been split; a few have been re-severitied, with the reason given in the new entry.

| Old id | Old severity | New id(s) | Note |
|---|---|---|---|
| B1 | S1 | B1.1 | — |
| B2 | S1 | B2.1 | Re-severitied: it errors rather than producing wrong numbers |
| B3 | S1 | B1.2 | — |
| B4 | S1 | B2.2, plus the debug leftovers to S3.13 | Split; re-severitied, since it errors out |
| B5 | S1 | B1.3 | — |
| B6 | S1 | B1.4 | — |
| B7 | S1 | B1.5 | — |
| B8 | S1 | B1.6 | — |
| B9 | S1 | B1.7 | — |
| B10 | S1 | B1.8 (the `'eff'` half) and B3.12 (the `_`-prefixed `'type','samp'`/`'bplot'` half) | Split |
| B11 | S1 | B1.9 | — |
| B12 | S1 | B3.4 | Re-severitied: the file is dead today, so it is latent |
| B13 | S2 | B2.3 | — |
| B14 | S2 | B2.4 | — |
| B15 | S2 | B2.5 | — |
| B16 | S2 | B2.6 | — |
| B17 | S2 | B2.7 | — |
| B18 | S2 | B2.8 | — |
| B19 | S3 | B2.9 | Re-measured against in-scope files only: 15 names, 41 sites, and one of them (`stats.computeSceneSimilarityAmplitude`) is new damage from the `_` rename |
| B20 | S3 | B2.11 (the `computeBootstrappedThreshold` half) and B3.12 (the `+stats` half) | Split |
| B21 | S3 | B3.3 | — |
| B22 | S3 | B3.10 and B3.12 | Split by whether the file is in scope |
| B23 | S3 | B3.9 | — |
| B24 | S3 | B3.11, plus `_changepower.m` to B3.12 | Split |
| S4 bullet list | S4 | B3.1, B3.2, B3.5, B3.6, B3.7, B3.8, B1.10, and S3.13/S3.18 for the non-bugs | The `ppd = 106` bullet was promoted to severity 1; the `nanmean` and `checkcode` bullets became Stage 2 work and section 1 measurements respectively |

</div>

</details>

</details>
