# camouflage_detection

Code for the Geisler-lab camouflage-detection project: how well a human — and an ideal observer — can detect a **camouflaged target** hidden in a naturalistic texture, and what visual information they use. Includes stimulus generation, the ideal-observer edge model, the Psychtoolbox detection experiments, and the psychometric-threshold analysis.

The 2022 dissertation, *Camouflage detection & signal discrimination: theory, methods & experiments* (A. Das, UT Austin), is the fullest write-up and a **superset** of the current paper: its chapter 2 additionally covers edge autocorrelation and the edge power spectrum (§2.2.2), combining edge power across scales (§2.2.4), and whitening (§2.2.5). Much of `+general/` implements those thesis-era analyses, which is why a good deal of it is not reachable from the current paper's figures. The current draft narrows to edge power plus the experiment series, and its model section is still unwritten — that is what `+general/fit_edge_model_with_exps.m` is building toward.

Write-ups live in `Presentations, reports, abstracts/` (gitignored): `2022 thesis/Thesis.pdf` is the dissertation, `Camouflage_paper.pdf` the current draft, and the `.pptx` decks are a chronological lab-talk record from 2018 to 2025. Current figure drafts are in `paper/`.

## What it does

The stimulus is a square texture patch (256×256 px) with a circular target region in the centre, filled with an *independent sample of the same texture*. The target's mean luminance and RMS contrast are matched to the exact background region it covers (`+lib/stimulus.m:232-244`), so first- and second-order statistics are identical inside and outside the target. **The only cue is the boundary** — the phase/texture discontinuity along the target's edge.

The project's central scalar is **edge power**. Convolve the stimulus with a steerable gradient filter (Gaussian $\sigma = 1$ px, truncated at $3\sigma$), walk along the target boundary parameterised by angle $\theta$, take the gradient component **normal** to the boundary, normalise it, and resample onto a uniform grid of $n = 1000$ points. That gives the *edge vector* $e(\theta)$, and

$$\mathrm{ep} = \langle e^2 \rangle.$$

Edge power separates target from blank stimuli with $d' \approx 8.7$, and orders target stimuli by detectability — which is what makes it usable as the independent variable of a blocked detection experiment.

> The repo currently contains **two incompatible normalisations** of $e(\theta)$, and which one you get depends on which function you call. See item B1.1 in [`docs/repo-cleanup.md`](docs/repo-cleanup.md) before trusting an edge-power number.

### The experiments

Yes/no detection. Stimuli are presented in blocks of increasing edge power: 30 trials × 10 levels × 4 sessions, 200 ms presentation, 1 s response window, auditory feedback.

| Paper § | Manipulation | Code family | `exp_files/` |
|---|---|---|---|
| 3.1 | pink noise, blocked by edge power | base | `pink_noise/` |
| 3.2 | same stimuli, shuffled (tests criterion vs. sensitivity) | `+general/shuffle_unshuffle_exp.m` | `pink_noise/shuffled/` |
| 3.3 | size, duration, eccentricity, luminance, contrast | base, re-run per condition | `pink_noise/eccentricity/`, `recast/` |
| 3.4 | hidden edge (boundary strip occluded) | base | — |
| 3.5 | whitened stimuli | base | — |
| 3.6.1 | texture $1/f$ exponent varied | `_texture_exponent` | `texture_exponent/` |
| 3.6.2 | natural textures (Portilla–Simoncelli) | base with `type='ps'` | `natural/` |
| 3.6.3 | target texture ≠ background texture | `_diff_bg` | `diff_bg/` |
| 3.7 | target *shape* irregularity varied | `_shape_exponent` | `shape_exponent/` |
| 3.8 | covert search vs. cued detection | `_search` | `search/` |
| — | many textures, unblocked | `_all` | `all/`, `all1/`, `all2/` |

## Dependencies

- **[vislab-common](https://github.com/abhranildas/vislab-common)** — the lab's shared MATLAB library (the `+vislab` package inside the sibling `vislab-common` folder; `setup.m` clones it automatically if it's missing). This repo uses exactly three functions from it: `vislab.lib.otf_filter`, `vislab.lib.colorbarpzn`, and `vislab.psychframework.run_experiment`.
- **`+lib`** — this repo's own package of camouflage-domain helpers (`lib.stimulus`, `lib.target_mask`, the edge measures, filter-bank builders), extracted from the old shared lab-root `+lib` so the repo is self-contained.
- **[IntClassNorm](https://github.com/abhranildas/IntClassNorm)** and **[gx2](https://github.com/abhranildas/gx2)** — installed MATLAB **add-on toolboxes**, used for `classify_normals` and `quad2fun`; `setup.m` verifies and self-heals the path.
- **por_sim_tx_synth** — vendored, in-repo Portilla–Simoncelli texture-synthesis toolbox (`matlabPyrTools` + `textureSynth`). `setup.m` adds it with `addpath(genpath(...))`, which puts `textureAnalysis`/`textureSynthesis` on the path unqualified.
- **vislab-common/data** — the shared data store, a sibling folder alongside this repo (~23 GB). Holds the calibrated natural images, texture sheets, and colour transforms. The natural-image set is too large for GitHub and must be obtained separately.
- **Psychtoolbox-3** (+ the EyeLink toolbox for peripheral runs) — needed only to *run* the experiments, not to analyse them.
- **MATLAB** with the Image Processing and Statistics & Machine Learning toolboxes. Some files additionally need the Deep Learning Toolbox (`sumsqr` in `+lib/edge_fit_cost.m:4`), the DSP System Toolbox (`dsp.Normalizer` in `+lib/edge_energy.m:35` — **removed in R2024b**), and Symbolic Math (`+tinker/pink_noise.m`); these are undeclared and not needed on the main path.

## Setup

```matlab
setup            % adds this repo + vislab-common + por_sim_tx_synth; self-heals the toolboxes
cfg = config;    % paths + constants
```

Every data path in the codebase now comes from `config()`, so the working directory no longer has to be the repo root (S2.2). Edit `cfg.paths.data_root` if the shared `vislab-common/data` store does not sit next to this repo.

## Quick demo

```matlab
edge_power_demo    % 3 cells: seeded / random / brown-noise stimulus + edge vector + edge power
```

This is the clean, working entry point for understanding the core measurement. Start here.

## Running an experiment (Psychtoolbox)

```matlab
experiment.set_up_experiment(variant, exp_type, subjectStr)      % once: pre-generate stimuli + subject files
experiment.main.run_camouflage_experiment(subjectStr, exp_type)  % run / resume a session
experiment.analysis.compute_threshold_edge_power(exp_type, subj, bPlot, bBootstrap)
```

Subject data is written to `exp_files/<exp_type>/subject_out/<subject>.mat`. `variant` is one of `'edge_power'` (the original experiment, levels are bands of target edge power), `'all'`, `'diff_bg'`, `'shape_exponent'` or `'texture_exponent'` — see `experiment.set_up_experiment`'s header.

> `set_up_experiment` **does not run as committed** — it loads from a directory that does not exist. See item B2.1 in [`docs/repo-cleanup.md`](docs/repo-cleanup.md).

## Repository layout

```
camouflage_detection/
├── setup.m, config.m       path bootstrap + central config
├── edge_power_demo.m       the one clean, working demo — start here
├── scratch.m, test_erlang.m  scratchpads
├── +lib/        (56 fns)   camouflage-domain helpers: stimulus, masks, edge measures, filters
├── +experiment/ (48 files) PTB experiment: setup → run → analyse
│   ├── +main/              runtime (interval functions, EyeLink, search paradigm)
│   └── +analysis/          psychometric fitting & thresholds
├── +general/    (41 files) model fitting + offline analysis; almost all top-level SCRIPTS
├── +stats/      (12 files) natural-scene luminance/contrast/similarity binning — dead (see below)
├── +vis/         (8 files) plotting
├── +tinker/     (13 files) exploratory prototypes (1/f noise theory, whitening)
├── +tests/       (2 files) ad-hoc scripts, NOT a test suite (no assertions, no runner)
├── por_sim_tx_synth/       vendored third-party
├── data/                   in-repo analysis artifacts, including data/edge_powers/
├── exp_files/              ~100 GB of experiment data — GITIGNORED, nothing tracked
├── docs/                   repo-cleanup.md — the staged cleanup plan
└── paper/, Presentations, reports, abstracts/   write-ups (the latter is gitignored)
```

Shared low-level code lives in `vislab-common`, not here, so it isn't duplicated across the lab's repos. Note that `lib.*` means *this* repo's `+lib`, while `vislab.lib.*` means the shared library — they are different packages.

**Files whose name begins with an underscore are dead.** 29 files across `+stats/`, `+general/`, and `+experiment/+analysis/` have been renamed in place with a leading `_` so they sort to the top of every folder listing. MATLAB cannot resolve a package-qualified name that starts with `_`, so they are no longer callable — including from each other. Reviving one means stripping the prefix from it *and* from every sibling it calls. All of `+stats/` is in this set.

### The edge measures in `+lib/`

There are three generations of edge measurement in `+lib/`, and callers are split across all of them.

| Function | Takes | Returns | Normalisation |
|---|---|---|---|
| `edge.m` | image + mask | edge vector **and** power | ÷ `local_sd` per pixel (`edge.m:92`) |
| `edge_vector_ideal.m` + `edge_measures_ideal.m` | image + mask | edge vector; then power + spectra | ÷ `rms(edge_mag)` (`edge_vector_ideal.m:91`) |
| `edge_energy.m` | image + radius | scalar, 7 `type` variants | 7 competing choices |
| `edge_shape.m` | image + radius | edge vector + autocorrelation + spectrum | none |
| `edge_measures.m` | image | contour density + contour lists | — |
| `edge_props_stim.m` | image | 15 multi-scale histogram LLRs | — |

`edge.m` is the current documented front end. `edge_vector_ideal`/`edge_measures_ideal` produced the deployed edge-power tables in `data/edge_powers/` and match the paper's definition. `edge_energy` and `edge_shape` are historical. Reconciling them is item S3.4 in the cleanup plan.

`edge_props_stim.m` is the ideal-observer statistic that does *not* assume the boundary is known. It histograms gradient magnitude, orientation, and their product in the boundary ribbon (region $a$) against everywhere else (region $b$) at 5 scales, and computes a multinomial same-vs-different log-likelihood ratio

$$\mathrm{LLR} = \sum_{\text{bins}}\left[n_a\ln\frac{n_a}{N_a} + n_b\ln\frac{n_b}{N_b} - (n_a + n_b)\ln\frac{n_a + n_b}{N_a + N_b}\right].$$

### The experiment call chain

```
set_up_experiment → session_settings → generate_target_present_matrix
                                     → generate_camouflage_stimuli   (picks seeds by edge-power bin)
                                     → subject_experiment_file
run_camouflage_experiment → load_current_session        (resume: lowest incomplete session)
                          → vislab.psychframework.run_experiment
                               hooks → load_stimuli_camouflage (dependency-injected loader)
                                     → display_level_start / fixation_interval
                                       / stimulus_interval / response_interval / give_feedback
                                     → save_current_level
compute_threshold_edge_power → fit_psychometric → compute_neg_log_likelihood → psychometric_fun
```

The stimulus loader is injected as a function handle stored *in the settings struct* (`session_settings.m:107`, `loadSessionStimuli = @experiment.load_stimuli_camouflage`), which is what keeps the shared `vislab.psychframework` harness domain-agnostic.

**The psychometric model** (`+experiment/+analysis/psychometric_fun.m:2-5`) is

$$d'(x) = \left(\frac{|x-\mu|}{a}\right)^{b}\operatorname{sign}(x-\mu), \qquad p_{\text{hit}} = \Phi\!\left(\frac{d'(1-c)}{2}\right), \qquad p_{\text{cr}} = \Phi\!\left(\frac{d'(1+c)}{2}\right)$$

with $a$ the threshold, $b$ the slope, $c$ the criterion bias, and $\mu$ fixed at 0 in the current fitter. It is fit by binomial negative log-likelihood over per-level counts. `compute_threshold_edge_power` is the current fitter; the per-trial and 2-parameter variants are `_`-prefixed and dead.

### The model in `+general/`

The current model is a **multivariate-Gaussian ideal observer over edge features, with no free parameters in the classifier**, fused in two stages:

1. `compute_edge_props_exp_pca.m:86` — for each feature family and level, fuse the 5 spatial scales with `classify_normals(...)`. The scalar decision variable is the Gaussian quadratic LLR of the 5-scale response vector.
2. `fit_edge_model_with_exps.m:48` — fuse the 3 feature families, and read off `norm_d_b` (Bayes-optimal $d'$) and `d_con` (per-feature $d'^2$ contributions, the stacked colour bars in the paper figure).

Human $d'$ is $z(\text{hit}) - z(\text{FA})$ per level, falling back to $2z(p_c)$ when infinite. A single global efficiency scalar is the intended free parameter, fit by least squares via `lib.edge_fit_cost`.

The live chain is `fit_edge_model_with_exps.m` ← `compute_edge_props_exp_pca.m` ← `compute_nat_img_eff_coding_bins.m`. Of `+general/`'s 41 files, **exactly one is a function** (`compute_nll_edge_model.m`); the rest are cell-divided top-level scripts that assume variables are already in the workspace, so they must be opened and run rather than called. Converting them is item S3.7 in the cleanup plan.

## Data model

### `exp_files/<exp_type>/exp_settings.mat` → `ExpSettings` (33 fields)

| Field | Size | Note |
|---|---|---|
| `stimuli` | 256×256×30×10×4 double | **0.59 GB per experiment.** Trials × levels × sessions. |
| `seeds` | 30×10×4 | the RNG seed for each stimulus |
| `edgePowers` | 30×10×4 | looked up from the seed table, *not* recomputed |
| `bTargetPresent` | 30×10×4 logical | |
| `edgePowerBlockEdges` / `Centers` | 10×2 / 1×10 | the level definition |
| `loadSessionStimuli` | function handle | dependency injection |
| `pClipped` | 30×10×4 | fraction of boundary-ribbon pixels outside [0,1] |
| `stim_l_groups`, `stim_e_groups` | 30×10×4 cell | appended post-hoc by `+general/compute_edge_group_measures.m` |
| + timing / monitor / geometry scalars | | |

`stimuli` is fully reproducible from `seeds`: `lib.stimulus` does `rng('default'); rng(seed)` at `:82-83` before any random draw, and returns the seed. Storing seeds instead of stimuli would take the repo from ~100 GB to ~10 MB — item S3.1 in the cleanup plan.

### `exp_files/<exp_type>/subject_out/<subject>.mat` → `SubjectExpFile` (8 fields)

`levelCompleted` (4×1), plus `bTargetPresent`, `response`, `hit`, `miss`, `falseAlarm`, `correctRejection`, and `correct`, each 30×10×4 logical. There is **no `edgePowers` field**, which is why the per-trial threshold fitters are dead.

### `data/edge_powers/` — the seed→edge-power tables (in-repo, tracked)

| File | Contents |
|---|---|
| `pink_noise.mat` | `edge_powers` (10,000,000×2), `edgePowerBlockEdges` (10×2) |
| `natural/<texture>.mat` | `edge_powers` only (e.g. `foliage.mat`: 100,000×2) — no `edgePowerBlockEdges` |

Column 1 is the edge power of the *blank* rendering of that seed; column 2 is the *target* rendering. `generate_camouflage_stimuli.m:20-22` selects target seeds whose column-2 value falls in the level's band. **This is the whole experimental manipulation.**

### `exp_files/` on disk — ~100 GB, none of it in git

| Folder | Size | `.mat` files |
|---|---|---|
| `shape_exponent/` | 29 GB | 23 |
| `recast/` | 25 GB | 82 |
| `really old edge strength (...)/` | 17 GB | 58 |
| `search/` | 8.3 GB | 8 |
| `natural/` | 8.2 GB | 121 |
| `pink_noise/` | 7.1 GB | 51 |
| others (`all`, `all1`, `all2`, `diff_bg`, `texture_exponent`) | ~4.6 GB | 55 |

`.gitignore` ignores `exp_files/`, so **every human-subject result is untracked** and exists only in OneDrive. `Presentations, reports, abstracts/` is gitignored too, so the paper draft is untracked as well.

## Status — reorganization in progress

This repo is mid-migration onto the shared `vislab-common` library, aligning it with the texture-learning and texture-segmentation repos. `texture-segmentation` finished the migration; this repo did not.

**Done:** `setup.m` + `config.m` added; the camouflage-domain code extracted into this repo's own `+lib` (56 functions) so the repo is self-contained; the redundant `edgecode/` removed; the Psychtoolbox harness unified onto `vislab.psychframework`; `Rs` donated to `vislab.nat_stat_bayes.dv_spatial`; the triplicated `gamma_correct` consolidated onto one implementation; every data path routed through `config()`.

**Not done:** the experiment-variant generators and runtime validation of the Psychtoolbox harness. All of these are tracked as items in the cleanup plan.

## Documentation

- [`docs/repo-cleanup.md`](docs/repo-cleanup.md) — the staged cleanup plan: the behaviour-preserving readability pass, the structural cleanups, and the full list of bugs found, each with a severity.
- `CLEANUP.md` — the migration checklist and the old→new mapping from the `vislab-common` reorganization.
- `../vislab-common/ARCHITECTURE.md` — how the repos, the shared library, the toolboxes, and `vislab-common/data` fit together.

## License & citation

MIT License (see `LICENSE`). If you use this code, please cite it and the dissertation — see `CITATION.cff`.
