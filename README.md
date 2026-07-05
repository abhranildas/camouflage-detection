# camouflage_detection

Code for the Geisler-lab camouflage-detection project — how well an ideal observer
and human observers can detect a camouflaged target embedded in a naturalistic
texture background, as a function of the target's edge power. Includes the ideal-
observer edge/spectral model, Psychtoolbox detection experiments, Portilla-Simoncelli
synthesized stimuli, and psychometric-threshold analysis. See `paper/` and
`Presentations, reports, abstracts/` for write-ups.

## What's here

- **Stimulus generation** — camouflaged-target stimuli over binned edge power, with
  Portilla-Simoncelli texture synthesis (`+experiment`, `por_sim_tx_synth/`, root `+lib`).
- **Human experiments (Psychtoolbox)** — a detection task with session/level/trial
  structure, optional EyeLink eye tracking, and per-subject output
  (`+experiment/+main`, `exp_files/`).
- **Ideal-observer / edge model** — edge-power and spectral decision variables and model
  fits (`+general`, root `+lib`).
- **Scene statistics** — filter-bank scene statistics infrastructure (`+stats`).
- **Analysis & visualization** — psychometric fitting, thresholds vs edge power,
  plotting (`+experiment/+analysis`, `+vis`).

## Dependencies

- **[vision-commons](https://github.com/abhranildas/vision-commons)** — the lab's shared MATLAB library (a
  sibling folder next to this repo; `setup.m` clones it automatically if it's missing). Provides `vislib.*` (optics,
  filters, normalization) and `nat_stat_bayes.*` (decision-variable toolkit).
- **lab-root `+lib`** — *temporary*: camouflage-domain code (`lib.stimulus`,
  `lib.target_mask`, `lib.edge_measures*`, filter-bank builders) still lives there.
  Extracting it into this repo and dropping this dependency is tracked in `CLEANUP.md`.
- **[IntClassNorm](https://github.com/abhranildas/IntClassNorm)** and
  **[gx2](https://github.com/abhranildas/gx2)** — installed MATLAB **add-on toolboxes**
  (`classify_normals`, `quad2fun`); `setup.m` verifies/self-heals them.
- **por_sim_tx_synth** — vendored Portilla-Simoncelli texture-synthesis toolbox
  (`matlabPyrTools` + `textureSynth`); `setup.m` adds it to the path.
- **global_data** — the shared data store (~23 GB: natural images, textures, source images, edge-power
  bins), a sibling folder like vision-commons but **too large to auto-download** — obtain it separately and
  place it next to this repo (`setup.m` warns if it's missing; edit `cfg.paths.data_root` if elsewhere).
- **Psychtoolbox-3** (+ EyeLink toolbox for peripheral runs) — required only to *run*
  the experiments. MATLAB with Image Processing / Statistics toolboxes.

## Setup

```matlab
setup            % adds this repo + vision-commons + por_sim_tx_synth; self-heals the toolboxes
cfg = config;    % data paths + shared constants; edit cfg.paths.data_root if needed
```

## Running an experiment (Psychtoolbox)

```matlab
experiment.setUpExperiment(exp_type, subjectStr)              % once: pre-generate stimuli + subject files
experiment.main.runCamouflageExperiment(subjectStr, exp_type) % run / resume a session
```
Subject data is written to `exp_files/<exp_type>/subject_out/<subject>.mat`; analyze with
`experiment.analysis.computeThreshold_edgePower`.

## Repository layout

```
camouflage_detection/
├── setup.m, config.m     path bootstrap + central configuration
├── +experiment/          PTB detection experiment (+main runtime, +analysis fitting) + stimulus gen
├── +general/             edge/spectral model fits, edge-power computation, analysis scripts
├── +stats/               scene-statistics infrastructure (filter banks)
├── +vis/                 visualization
├── +tinker/, +tests/     exploratory prototypes / ad hoc tests
├── edgecode/             standalone legacy DV code (flagged in CLEANUP.md)
├── por_sim_tx_synth/     vendored Portilla-Simoncelli synthesis
├── data/, exp_files/     analysis artifacts + human-subject experiment output
└── paper/                write-up
```

Shared low-level code lives in `vision-commons` (not here), so it isn't duplicated
across the lab's repos.

## Status & caveats — reorganization in progress

This repo is mid-migration onto `vision-commons` (aligning it with the
texture-learning / texture-segmentation repos; see `../REORGANIZATION_PLAN.md`).

- **Done:** `setup.m` + `config.m` added (was ambient path + stale hardcoded paths);
  `nat_stat_bayes.dv_spatial` promoted to commons; the Psychtoolbox harness unified onto the shared
  `vision-commons/+psychframework`; removed the redundant `edgecode/` and dead/duplicate `+experiment`
  functions (`occludingTarget`, `saveCurrentSession`, `subjectExperimentFile_alpha`).
- **Intentionally left as-is** (owner's decision — see `CLEANUP.md` for details): the camouflage-domain
  code still lives in the lab-root `+lib` (not extracted into this repo); the
  `generate_camouflage_stimuli_*`/`sessionSettings_*`/`setUpExperiment_*` variant families are not merged;
  the exploratory `+tinker` prototypes (with some dead `lib.*` references) are kept; and
  `computeBootstrappedThreshold` is left as stale.

## Documentation

- `CLEANUP.md` — the full migration/cleanup checklist and old→new mapping.
- `../vision-commons/ARCHITECTURE.md` — how the repos, the shared library, the
  toolboxes, and `global_data` fit together.

## License

MIT License (see `LICENSE`).
