% analyze_search_exps  Score detection/search-experiment hit and false-alarm
%     rates and plot per-location d' for a spot-search experiment.
%
%     analyze_search_exps
%
% Script, no arguments; each %% cell is meant to be run on its own, against
% whatever `Stimulus`/`SubjectExpFile` struct is currently in the workspace
% (loaded separately, by hand, before running that cell).
%
% Cells
%     1. Detection experiment: scores `SubjectExpFile.hit`/`.miss`/
%        `.falseAlarm`/`.correctRejection` from `Stimulus.tLocation` and
%        `SubjectExpFile.response`, then writes the Hautus (1995)
%        clip-corrected `SubjectExpFile.hitRate`/`.faRate`/`.dPrime`
%        (scalars, one detection experiment).
%     2. Displays the detection stimulus (`Stimulus.stimuli(:,:,2,2)`) with
%        the spot locations overlaid as thin white rings.
%     3. Search experiment: scores per-location hit rate and d' (Hautus
%        1995 log-linear correction) across all 19 spot locations, and
%        writes `SubjectExpFile.hitRate`/`.falseAlarm`/`.dPrime` (19-element
%        vectors, one search experiment). NOTE: this reuses the same three
%        field names as cell 1 for a different-shaped quantity — see the
%        header note below.
%     4. Loads every `*.mat` file in the current directory (each assumed to
%        contain a `SubjectExpFile` from cell 3), averages `.dPrime` across
%        subjects, and plots it as a heatmap of filled circles at the 19
%        spot locations.
%
% Inputs (workspace, not file arguments): `Stimulus.tLocation`,
%     `Stimulus.response`/`SubjectExpFile.response`, `Stimulus.spotLength`
%     (pixels), `Stimulus.spotCenters` (pixels, [x, y] per the comment at
%     the fliplr below), `Stimulus.stimuli`.
% Output: two figures (rings-overlay display, per-location d' heatmap); no
%     file is written. Cells 1 and 3 write `SubjectExpFile.hitRate`/
%     `.dPrime` (see the cell-3 note above about the shared field names).
%
% See also general.analyze_shape_exps, general.analyze_shuffled_exp.

%% process detection experiment responses
SubjectExpFile.tLocation = logical(Stimulus.tLocation);
SubjectExpFile.hit = SubjectExpFile.tLocation & SubjectExpFile.response;
SubjectExpFile.miss = SubjectExpFile.tLocation & (~SubjectExpFile.response);
SubjectExpFile.falseAlarm = (~SubjectExpFile.tLocation) & SubjectExpFile.response;
SubjectExpFile.correctRejection = (~SubjectExpFile.tLocation) & (~SubjectExpFile.response);

hit_rate = sum(SubjectExpFile.hit)./sum(SubjectExpFile.tLocation);
false_alarm_rate = sum(SubjectExpFile.falseAlarm)./sum(~SubjectExpFile.tLocation);

% finite-trial Hautus (1995) correction
n_target_trials = sum(SubjectExpFile.tLocation);
n_blank_trials = sum(~SubjectExpFile.tLocation);

SubjectExpFile.hitRate = max(min(hit_rate, 1 - 1./(2*n_target_trials)), 1./(2*n_target_trials));
SubjectExpFile.faRate = max(min(false_alarm_rate, 1 - 1./(2*n_blank_trials)), ...
    1./(2*n_blank_trials));

SubjectExpFile.dPrime = norminv(SubjectExpFile.hitRate) - norminv(SubjectExpFile.faRate);

%% detection stimulus with overlaid rings
% load experiment settings

spot_radius = Stimulus.spotLength / 2;
spot_centers = fliplr(Stimulus.spotCenters);  % x and y seem to be flipped

display_stim = Stimulus.stimuli(:, :, 2, 2);

% Display the 'display_stim' image
figure;
imshow(display_stim, []);
hold on;

% Define the properties of the white rings
line_width = .1;
ring_color = 'w';

% Overlay the set of thin circular rings
viscircles(spot_centers, repmat(spot_radius, size(spot_centers, 1), 1), ...
    'EdgeColor', ring_color, 'LineWidth', line_width);

%% process search experiment responses

SubjectExpFile.tLocation = Stimulus.tLocation;
% Flatten arrays to easily process all trials at once
target_location = SubjectExpFile.tLocation(:);
response_flat = SubjectExpFile.response(:);

% 1. Compute Overall False Alarm Rate
% Target absent trials are when target_location == 0
target_absent_trials = (target_location == 0);
n_absent_trials = sum(target_absent_trials);

% False Alarms: target was absent, but subject clicked a location (~= 0)
n_false_alarms = sum(target_absent_trials & (response_flat ~= 0));

% Hautus Correction for False Alarms: add 0.5 to count, 1 to total N
false_alarm_rate_adj = (n_false_alarms + 0.5) / (n_absent_trials + 1);

% Calculate the Z-score for the overall False Alarm rate
z_false_alarm = norminv(false_alarm_rate_adj);

% 2. Compute Hit Rate and d' for each of the 19 locations
d_prime = zeros(1, 19);
hit_rate = zeros(1, 19);  % Preallocate the hit_rate array

for i_location = 1:19
    % Trials where target was physically at location i_location
    target_present_trials = (target_location == i_location);
    n_target_present_trials = sum(target_present_trials);

    % Hits: target was at i_location AND subject responded i_location
    n_hits = sum(target_present_trials & (response_flat == i_location));

    % Compute and store the HAUTUS-ADJUSTED hit rate for this location
    hit_rate(i_location) = (n_hits + 0.5) / (n_target_present_trials + 1);

    % Compute d' for this location using the adjusted hit rate
    d_prime(i_location) = norminv(hit_rate(i_location)) - z_false_alarm;
end

SubjectExpFile.hitRate = hit_rate;
SubjectExpFile.falseAlarm = false_alarm_rate_adj;
SubjectExpFile.dPrime = d_prime;


%% plot average detection/search performance across subjects
% 1. Find all .mat files in the current directory
mat_files = dir('*.mat');
n_files = length(mat_files);

% Preallocate array to store all d' values (assuming 19 spots per file)
all_d_primes = zeros(n_files, 19);

% 2. Loop through and load the data
% i_location indexes files here, not locations — check_stage1's rename map
% is one-old-name-to-one-new-name per file, and this script's other two
% uses of the bare counter "i" are genuine location indices (see below);
% this loop's counter keeps that name for that reason, not because it
% indexes a location.
for i_location = 1:n_files
    % Load only the specific structure to save memory and time
    load(mat_files(i_location).name);

    % Store the 19-element d_prime array as a row vector
    all_d_primes(i_location, :) = SubjectExpFile.dPrime(:)';
end

% 3. Average across all files (ignoring NaNs just in case of missing data)
avg_d_prime = mean(all_d_primes, 1, 'omitnan');

% 4. Plotting variables
% spot_centers = Stimulus.spotCenters;
circle_radius = Stimulus.spotLength / 2;

% 5. Create the heatmap plot
figure('Position', [100, 100, 1200, 1200]);
hold on;

% Create a circle template for plotting
theta = linspace(0, 2*pi, 100);

% Draw each filled circle using patch
for i_location = 1:19
    x_circle = spot_centers(i_location, 1) + circle_radius * cos(theta);
    y_circle = spot_centers(i_location, 2) + circle_radius * sin(theta);

    patch(x_circle, y_circle, avg_d_prime(i_location), 'EdgeColor', 'none');
end

% --- FORMATTING THE PLOT ---
axis image;

% Force the coordinate limits to be exactly 1200x1200 to recreate the image canvas
xlim([1, 1200]);
ylim([1, 1200]);
set(gca, 'YDir', 'reverse');  % Crucial: Image coordinates start at top-left

colormap('copper');
colorbar;
clim([min(avg_d_prime), max(avg_d_prime)]);
set(gca, 'xtick', [], 'ytick', [])
