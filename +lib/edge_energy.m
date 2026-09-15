function energy = edge_energy(stim, target_radius, target_loc, kernel_size, measure_type)
% EDGE_ENERGY  Scalar edge energy of a target against its background.
%   energy = lib.edge_energy(stim, target_radius)
%   energy = lib.edge_energy(stim, target_radius, target_loc, kernel_size, measure_type)
%
%   Eight alternative ways of reducing the image gradient along a circular
%   target boundary to one number. This is the exploratory predecessor of
%   lib.edge and lib.edge_vector_ideal, which return a whole edge vector
%   rather than a single energy.
%
%   Inputs
%     stim          - greyscale stimulus image, in normalised luminance units.
%     target_radius - target radius in pixels.
%     target_loc    - [row, col] target centre in pixels, or 'center'
%                     (default).
%     kernel_size   - 2-element [sigma, n_sigma] of the steerable gradient
%                     filter: Gaussian sd in pixels, and the number of sds at
%                     which the kernel is truncated. Default [1 3].
%     measure_type  - which energy to return. One of:
%                     'mag'          sum of gradient magnitudes on the edge
%                     'cos'          as 'normal', on unit-normalised gradients
%                     'normal'       sum of |normal gradient| on the edge
%                     'perp_ratio'   log of normal-to-tangential ratio
%                     'grad_by_lum'  normal gradient over local luminance
%                     'grad_by_norm' normal over total magnitude, minus 2/pi
%                                    (the value for a random gradient field);
%                                    the default
%                     'grad_by_sd'   normal gradient over the global sd
%                     'rms'          RMS normal over RMS magnitude
%
%   Output
%     energy - scalar. Units depend on measure_type: 'perp_ratio',
%              'grad_by_norm' and 'rms' are dimensionless ratios, the rest
%              carry the units of the gradient. Left unassigned, and therefore
%              an error, if measure_type matches none of the eight.
%
%   This function does not currently run. Line 18 calls lib.steerable_grad
%   positionally, but that function takes name-value arguments, so it errors
%   with "Expected a string scalar or character vector for the parameter
%   name"; and the 'cos' branch uses dsp.Normalizer, which was removed in
%   R2024b. Both are recorded as B2.3 in the plan and are not fixed here.
%
%   The argument was called "type" before this pass, shadowing the builtin
%   TYPE; it is a positional argument, so the new name is local only.
%
%   See also lib.EDGE, lib.EDGE_VECTOR_IDEAL, lib.STEERABLE_GRAD,
%   lib.TARGET_MASK, lib.CREATE_AVERAGING_FILTER.

    % Default parameters
    if ~exist('target_loc', 'var')
        target_loc = 'center';
    end

    if ~exist('measure_type', 'var')
        measure_type = 'grad_by_norm';
    end

    if ~exist('kernel_size', 'var')
        kernel_size = [1 3];
    end

    % calculate stimulus gradient using steerable filter:
    stim_grad = lib.steerable_grad(stim, kernel_size);

    % create target mask
    [~, mask_edge, mask_normal] = lib.target_mask('bg_size', size(stim, 1), ...
        'target_radius', target_radius, 'target_loc', target_loc);

    edge_grad = mask_edge.*stim_grad;
    [~, edge_magnitude] = cart2pol(edge_grad(:, :, 1), edge_grad(:, :, 2));

    % 1. mag: sum gradient magnitudes
    if strcmp(measure_type, 'mag')
        energy = sum(edge_magnitude(:));
        return
    end

    % 2. cos: sum (cos of angle bw gradients & normals)
    if strcmp(measure_type, 'cos')
        % normalize gradient vectors:
        normalizer_3 = dsp.Normalizer('Method', '2-norm', 'Dimension', 'Custom', ...
            'CustomDimension', 3);
        stim_grad = normalizer_3(stim_grad);
    end

    grad_normal = mask_normal(:, :, 1).*stim_grad(:, :, 1) ...
        + mask_normal(:, :, 2).*stim_grad(:, :, 2);

    % 3. normal: sum normal gradient magnitudes
    if strcmp(measure_type, 'normal') || strcmp(measure_type, 'cos')
        energy = sum(abs(grad_normal(:)));
        return
    end

    % 4. perp_ratio: log (sum normal gradient magnitudes) / (sum tangent gradient magnitudes)
    if strcmp(measure_type, 'perp_ratio')
        mask_tangent = [];
        mask_tangent(:, :, 1) = mask_normal(:, :, 2);
        mask_tangent(:, :, 2) = -mask_normal(:, :, 1);
        grad_tangent = mask_tangent(:, :, 1).*stim_grad(:, :, 1) ...
            + mask_tangent(:, :, 2).*stim_grad(:, :, 2);
        energy = log(sum(abs(grad_normal(:)))/sum(abs(grad_tangent(:))));
        return
    end

    % 5. grad_by_lum: sum (normal gradient magnitudes / local luminance)
    if strcmp(measure_type, 'grad_by_lum')
        averaging_filter = lib.create_averaging_filter(kernel_size);
        energy = sum(sum(abs(grad_normal)./conv2(stim, averaging_filter, 'same')));
        return
    end

    % 6. grad_by_norm: (sum normal gradient magnitudes)/(sum gradient magnitudes)
    if strcmp(measure_type, 'grad_by_norm')
        energy = sum(abs(grad_normal(:))) ...
            /lib.edge_energy(stim, target_radius, target_loc, kernel_size, 'mag') - 2/pi;
        return
    end

    % 7. grad_by_sd: (sum normal gradient magnitudes) / global luminance*contrast
    if strcmp(measure_type, 'grad_by_sd')
        energy = sum(abs(grad_normal(:)))/std(stim(:));
        return
    end

    if strcmp(measure_type, 'rms')
        energy = rms(grad_normal(:))/rms(edge_magnitude(:));
        %e=rms(edge_normal(:));
        return
    end
end
