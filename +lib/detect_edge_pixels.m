function edge_pixels=detect_edge_pixels(stim,varargin)

%% parse inputs
parser=inputParser;
parser.KeepUnmatched=true;
addRequired(parser,'stim', @isnumeric);
% edge_detection_filter=lib.diff_of_gaussians_filter(2,4,2);
edge_detection_filter=lib.laplacian_of_gaussian_filter(2,3);
addParameter(parser,'edge_detection_filter', edge_detection_filter, @isnumeric);
addParameter(parser,'thresh', 4, @isscalar);

% parse inputs
parse(parser,stim,varargin{:});
stim=parser.Results.stim;
edge_detection_filter=parser.Results.edge_detection_filter;
thresh=parser.Results.thresh;


%% compute normalized gradients, and thresholded edge pixels
edge_pixels=edge(stim,'zerocross',0,edge_detection_filter);

grad_1px=lib.steerable_grad(stim,'kernel_size',[1 3]);

% threshold by the 1px gradient magnitude:
grad_1px_mag=vecnorm(grad_1px,2,3);
thresholded=grad_1px_mag>thresh;
edge_pixels=edge_pixels&thresholded;