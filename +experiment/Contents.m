% +experiment  (package namespace: experiment.*)
% Everything that defines and runs a camouflage detection experiment: choosing
% the stimuli and levels, writing the settings and per-subject result files,
% preparing a session for display, and recording what the subject did. The
% files listed here are the setup and bookkeeping half; the Psychtoolbox
% runtime is experiment.main and the threshold fitting is experiment.analysis,
% each with its own Contents.m.
%
% Call functions as experiment.<function>. Every path in this package is
% relative to the repo root, so the working directory must be the repo root
% (see setup.m). Note that the edge-power and source-image directories these
% files load from do not currently exist on disk (B2.1); S3.2 repoints them.
%
% Setting up an experiment
%   setUpExperiment                 - create settings, stimuli and subject files
%   sessionSettings                 - build the full ExpSettings struct
%   generate_camouflage_stimuli     - synthesise the stimuli for all levels
%   generateTargetPresentMatrix     - draw which trials carry a target
%   subjectExperimentFile           - preallocate one subject's result file
%   transform_camouflage_stimuli    - reuse an experiment's stimuli at a new
%                                     mean luminance and contrast
%
% Experiment variants
% Four near-duplicate families of the three files above, differing only in what
% varies across levels. S3.3 collapses them into one parameterised function;
% until then an edit to one belongs in all five.
%   *_all              - level is the texture, drawn from a texture list
%   *_diff_bg          - level is the background's 1/f exponent
%   *_shape_exponent   - level is the target boundary's 1/f exponent
%   *_texture_exponent - level is the texture's 1/f exponent
%
% A separate paradigm, not one of those variants
%   setUpExperiment_search          - peripheral search / detection over a ring
%                                     of candidate target locations
%
% Running and recording a session
%   loadCurrentSession              - find and load the next session to run
%   loadStimuliCamouflage           - prepare one session's stimuli for display
%   gammaCorrect                    - gamma-compress and quantise an image
%   saveCurrentLevel                - score a finished level into the subject file
%
% Patch samplers from the earlier natural-image experiments, currently uncalled
%   samplePatchesForExperiment      - sample natural-image patches from a bin
%   sampleNoisePatchForExperiment   - synthesise 1/f-noise stimuli instead
%   sampleUniformPatchForExperiment - uniform-luminance control stimuli
%
% Serialisation. Every field of ExpSettings and SubjectExpFile is frozen: about
% 100 GB of collected human data under exp_files/ depends on those names, so
% renaming one needs a migration script (S3.10). Several are already misnomers
% and stay that way for now — .monitor_distance holds pixels per degree (B3.8),
% .moniter_brightness is misspelled, and .alphas means a boundary shape exponent
% in one variant and a texture exponent in another.
