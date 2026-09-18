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
%   set_up_experiment              - create settings, stimuli and subject files
%   session_settings               - build the full ExpSettings struct
%   generate_camouflage_stimuli    - synthesise the stimuli for all levels
%   generate_target_present_matrix - draw which trials carry a target
%   subject_experiment_file        - preallocate one subject's result file
%   transform_camouflage_stimuli   - reuse an experiment's stimuli at a new
%                                    mean luminance and contrast
%
% Experiment variants
% Five variants, differing only in what varies across levels. set_up_experiment
% and session_settings take the variant as their first argument (S2.3); the
% generators stay five separate files, because past the shared bookkeeping they
% share no computation.
%   'edge_power'       - level is a band of target edge power (the original)
%   'all'              - level is the texture, drawn from a texture list
%   'diff_bg'          - level is the background's 1/f exponent
%   'shape_exponent'   - level is the target boundary's 1/f exponent
%   'texture_exponent' - level is the texture's 1/f exponent
%   generate_camouflage_stimuli_all, _diff_bg, _shape_exponent, _texture_exponent
%
% A separate paradigm, not one of those variants
%   set_up_experiment_search            - peripheral search / detection over a ring
%                                         of candidate target locations
%
% Running and recording a session
%   load_current_session    - find and load the next session to run
%   load_stimuli_camouflage - prepare one session's stimuli for display
%   gamma_correct           - gamma-compress and quantise an image
%   save_current_level      - score a finished level into the subject file
%
% Patch samplers from the earlier natural-image experiments, currently uncalled
%   sample_patches_for_experiment       - sample natural-image patches from a bin
%   sample_noise_patch_for_experiment   - synthesise 1/f-noise stimuli instead
%   sample_uniform_patch_for_experiment - uniform-luminance control stimuli
%
% Serialisation. Every field of ExpSettings and SubjectExpFile is frozen: about
% 100 GB of collected human data under exp_files/ depends on those names, so
% renaming one needs a migration script (S3.10). Several are already misnomers
% and stay that way for now — .monitor_distance holds pixels per degree (B3.8),
% .moniter_brightness is misspelled, and .alphas means a boundary shape exponent
% in one variant and a texture exponent in another.
