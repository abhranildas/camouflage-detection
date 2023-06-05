function grad=steerable_grad(stim,varargin)
% compute stimulus gradient using steerable filters:

parser=inputParser;
parser.KeepUnmatched=true;
addRequired(parser,'stim');
addParameter(parser,'kernel_size', [1 3], @isnumeric);
addParameter(parser,'normalize', 2e-4); % smallest offset to remove artifacts
% if normalize = false, don't normalize
% if = true, normalize by sd
% if = k (numeric value), normalize by sqrt(sd^2+k)

% parse inputs
parse(parser,stim,varargin{:});
stim=parser.Results.stim;
kernel_size=parser.Results.kernel_size;
normalize=parser.Results.normalize;

steerable_filter=lib.steerable_filter(kernel_size);
grad=zeros([size(stim),2]);

% leave out the edges of the image
padsize=kernel_size(1)*kernel_size(2);
grad(padsize+1:end-padsize,padsize+1:end-padsize,1)=filter2(steerable_filter(:,:,1),stim,'valid');
grad(padsize+1:end-padsize,padsize+1:end-padsize,2)=filter2(steerable_filter(:,:,2),stim,'valid');

% normalize by local luminance and contrast, i.e. by local std
if normalize
    stim_sd=lib.local_sd(stim,kernel_size);
    if normalize==true
        grad=grad./stim_sd;
        grad(isnan(grad))=0; % change 0/0 to 0
    else
        grad=grad./sqrt(stim_sd.^2+normalize);
    end
end