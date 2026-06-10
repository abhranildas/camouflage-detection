%% process detection experiment responses
SubjectExpFile.tLocation=logical(Stimulus.tLocation);
SubjectExpFile.hit=SubjectExpFile.tLocation&SubjectExpFile.response;
SubjectExpFile.miss=SubjectExpFile.tLocation&(~SubjectExpFile.response);
SubjectExpFile.falseAlarm=(~SubjectExpFile.tLocation)&SubjectExpFile.response;
SubjectExpFile.correctRejection=(~SubjectExpFile.tLocation)&(~SubjectExpFile.response);

hitRate=sum(SubjectExpFile.hit)./sum(SubjectExpFile.tLocation);
faRate=sum(SubjectExpFile.falseAlarm)./sum(~SubjectExpFile.tLocation);

% finite-trial Hautus (1995) correction
N_t=sum(SubjectExpFile.tLocation);
N_b=sum(~SubjectExpFile.tLocation);

SubjectExpFile.hitRate = max(min(hitRate, 1 - 1./(2*N_t)), 1./(2*N_t));
SubjectExpFile.faRate = max(min(faRate, 1 - 1./(2*N_b)), 1./(2*N_b));

SubjectExpFile.dPrime = norminv(SubjectExpFile.hitRate) - norminv(SubjectExpFile.faRate);

%% detection stimulus with overlaid rings
% load experiment settings

spotRadius = Stimulus.spotLength / 2;
centers = fliplr(Stimulus.spotCenters); % x and y seem to be flipped

stim = Stimulus.stimuli(:,:,2,2);

% Display the 'stim' image
figure;
imshow(stim, []);
hold on;

% Define the properties of the white rings
lineWidth = .1;
color = 'w';

% Overlay the set of thin circular rings
viscircles(centers, repmat(spotRadius, size(centers, 1), 1), ...
           'EdgeColor', color, 'LineWidth', lineWidth);

%% process search experiment responses

SubjectExpFile.tLocation = Stimulus.tLocation;
% Flatten arrays to easily process all trials at once
tLoc = SubjectExpFile.tLocation(:);
resp = SubjectExpFile.response(:);

% 1. Compute Overall False Alarm Rate
% Target absent trials are when tLoc == 0
absentTrials = (tLoc == 0);
nNoise = sum(absentTrials); 

% False Alarms: target was absent, but subject clicked a location (~= 0)
numFA = sum(absentTrials & (resp ~= 0));

% Hautus Correction for False Alarms: add 0.5 to count, 1 to total N
faAdj = (numFA + 0.5) / (nNoise + 1);

% Calculate the Z-score for the overall False Alarm rate
zFA = norminv(faAdj);

% 2. Compute Hit Rate and d' for each of the 19 locations
dPrime = zeros(1, 19);
hitRate = zeros(1, 19); % Preallocate the hitRate array

for i = 1:19
    % Trials where target was physically at location i
    signalTrials_i = (tLoc == i);
    nSignal_i = sum(signalTrials_i);
    
    % Hits: target was at i AND subject responded i
    numHits_i = sum(signalTrials_i & (resp == i));
    
    % Compute and store the HAUTUS-ADJUSTED hit rate for this location
    hitRate(i) = (numHits_i + 0.5) / (nSignal_i + 1);
    
    % Compute d' for this location using the adjusted hit rate
    dPrime(i) = norminv(hitRate(i)) - zFA;
end

SubjectExpFile.hitRate = hitRate;
SubjectExpFile.falseAlarm = faAdj;
SubjectExpFile.dPrime = dPrime;


%% plot average detection/search performance across subjects
% 1. Find all .mat files in the current directory
files = dir('*.mat');
numFiles = length(files);

% Preallocate array to store all d' values (assuming 19 spots per file)
all_dPrimes = zeros(numFiles, 19); 

% 2. Loop through and load the data
for i = 1:numFiles
    % Load only the specific structure to save memory and time
    load(files(i).name);
    
    % Store the 19-element dPrime array as a row vector
    all_dPrimes(i, :) = SubjectExpFile.dPrime(:)'; 
end

% 3. Average across all files (ignoring NaNs just in case of missing data)
avg_dPrime = mean(all_dPrimes, 1, 'omitnan');

% 4. Plotting variables
% centers = Stimulus.spotCenters;
radius = Stimulus.spotLength / 2;

% 5. Create the heatmap plot
figure('Position', [100, 100, 1200, 1200]); 
hold on;

% Create a circle template for plotting
theta = linspace(0, 2*pi, 100);

% Draw each filled circle using patch
for i = 1:19
    x_circle = centers(i, 1) + radius * cos(theta);
    y_circle = centers(i, 2) + radius * sin(theta);
    
    patch(x_circle, y_circle, avg_dPrime(i), 'EdgeColor', 'none');
end

% --- FORMATTING THE PLOT ---
axis image;

% Force the coordinate limits to be exactly 1200x1200 to recreate the image canvas
xlim([1, 1200]);
ylim([1, 1200]);
set(gca, 'YDir', 'reverse'); % Crucial: Image coordinates start at top-left

colormap('copper'); 
colorbar;           
clim([min(avg_dPrime), max(avg_dPrime)]); 
set(gca,'xtick',[],'ytick',[])