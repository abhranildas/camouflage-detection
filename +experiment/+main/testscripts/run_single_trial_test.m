% RUN_SINGLE_TRIAL_TEST  Ad-hoc scratch script for testing single-trial Psychtoolbox display setup.
%   Not a function; run as a script. Opens a Psychtoolbox window, builds an
%   experiment_struct (see experiment.main.testscripts.test_experiment_struct)
%   and a two-frame random-noise-disc stimulus_array, then stops -- it never
%   calls a trial-runner. See this tranche's findings log: line 18 references
%   an undefined variable w (the window handle is opened into `window` on the
%   line above), so this script errors immediately if run as-is.
%
%   See also experiment.main.testscripts.TEST_EXPERIMENT_STRUCT.

% This script calls Psychtoolbox commands available only in OpenGL-based
% versions of the Psychtoolbox. (So far, the OS x_grid Psychtoolbox is the
% only OpenGL-based Psychtoolbox.)  The Psychtoolbox command AssertOpenGL will issue
% an error message if someone tries to execute this script on a computer without
% an OpenGL Psychtoolbox
AssertOpenGL;

% Get the list of screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screen_number = max(Screen('Screens'));

% Open a double buffered fullscreen window.
[window, window_rect] = PsychImaging('OpenWindow', screen_number, .5, [], 32, 2);

Screen('Flip', w);

experiment_struct.window = w;
experiment_struct.fixcrossPosX(1:2) = 100;
experiment_struct.fixcrossPosY(1:2) = 540;

experiment_struct.stimulusPosX(1:2) = 600;
experiment_struct.stimulusPosY(1:2) = 540;

experiment_struct.stimulusDuration = 3;
experiment_struct.ppd = 120;
experiment_struct.correctResponse(1) = 0;
experiment_struct.correctResponse(2) = 0;
experiment_struct.MAX_TRIALS = 2;
experiment_struct.target = zeros(21, 21);
experiment_struct.backgroundcolour = .5;
experiment_struct.STIMULUSDELAY = 1;

[x_grid, y_grid] = meshgrid(-120:120, -120:120);
win = sqrt(x_grid.^2 + y_grid.^2) < 100;
bg = randn(241)*.5*127 + 127;
bg(~win) = 127;
stimulus = bg;

stimulus_array = zeros([size(stimulus), 1]);
stimulus_array(:, :, 1) = stimulus;
stimulus_array(:, :, 2) = stimulus;
