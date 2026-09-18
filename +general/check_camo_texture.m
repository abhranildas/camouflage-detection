% check_camo_texture  Display each texture in `texture_list` as a
%     camouflage stimulus, titled with its subject/model error rates.
%
%     check_camo_texture
%
% Script, no arguments. Expects `texture_list` (a struct array with an
% `.img` name field), `errs_subj` and `errs_model` (per-texture error
% rates, dimensionless, one per `texture_list` entry) already in the
% workspace.
%
% Inputs: none from disk; reads the workspace variables above.
% Output: one figure per texture, showing the synthesised camouflage
%     stimulus. Nothing is saved to disk.
%
% NOTE: `bg_size`/`luminance`/`contrast` below are set but never passed to
% `lib.stimulus` — the call hardcodes 0.5/0.15 for `ml_b`/`cont_b`/`ml_t`/
% `cont_t` instead of referencing `luminance`/`contrast`, and `bg_size`
% is not in the call's argument list at all. Left as found; renaming
% `lum`/`cont` only followed 0.1.6's precedent for these two unused locals.
%
% See also general.compute_avg_acc_for_texture, general.analyze_shape_exps.

%% check images from texture list

bg_size = 256;
luminance = 0.5;
contrast = 0.15;
target_radius = 64;

for i_tex = 1:length(texture_list)
    i_tex  % deliberate: progress display
    texture = texture_list(i_tex);
    stim = lib.stimulus('texture', texture, 'ml_b', 0.5, 'cont_b', 0.15, ...
        'ml_t', 0.5, 'cont_t', 0.15, 'target_radius', target_radius);
    figure;
    imshow(stim, []);
    title(sprintf('%s %.2f, %.2f', texture.img, 1-errs_subj(i_tex), 1-errs_model(i_tex)), ...
        'Interpreter', 'none')
end
