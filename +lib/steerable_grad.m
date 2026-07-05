function grad=steerable_grad(stim,varargin)
% compute stimulus gradient using steerable filters:

parser=inputParser;
parser.KeepUnmatched=true;
addRequired(parser,'stim');
addParameter(parser,'kernel_size', [], @isnumeric);
addParameter(parser,'filter', [], @isnumeric);
addParameter(parser,'pad_val', nan, @isscalar);
addParameter(parser,'normalize', 2e-4); % smallest offset to remove artifacts
% if normalize = false, don't normalize
% if = true, normalize by sd
% if = k (numeric value), normalize by sqrt(sd^2+k)

% parse inputs
parse(parser,stim,varargin{:});
stim=parser.Results.stim;
kernel_size=parser.Results.kernel_size;
filt=parser.Results.filter;
pad_val=parser.Results.pad_val;
normalize=parser.Results.normalize;

if isempty(filt)
    filt=lib.steerable_filter(kernel_size);
end

% assume stim is M×N, filt is R×C
[M,N] = size(stim);
[R,C,~] = size(filt);

grad=nan(M,N,2);

if isnan(pad_val)
    % get the valid output
    valid_1 = filter2(filt(:,:,1), stim, 'valid');
    valid_2 = filter2(filt(:,:,2), stim, 'valid');

    % 3) locate where to paste it
    r1 = ceil(R/2);           % first row index in grad
    r2 = M-floor(R/2);      % last  row index in grad
    c1 = ceil(C/2);           % first col index in grad
    c2 = N-floor(C/2);      % last  col index in grad

    grad(r1:r2,c1:c2,1) = valid_1;
    grad(r1:r2,c1:c2,2) = valid_2;

    % leave out the edges of the image
    % padsize=kernel_size(1)*kernel_size(2);
    % grad(padsize+1:end-padsize,padsize+1:end-padsize,1)=filter2(filt(:,:,1),stim,'valid');
    % grad(padsize+1:end-padsize,padsize+1:end-padsize,2)=filter2(filt(:,:,2),stim,'valid');
else
    % pad the image
    pad_len = floor(size(filt,1)/2);
    stim_padded = padarray(stim, [pad_len, pad_len], pad_val, 'both');

    % filter and keep valid region
    grad(:,:,1)=filter2(filt(:,:,1),stim_padded,'valid');
    grad(:,:,2)=filter2(filt(:,:,2),stim_padded,'valid');
end

% normalize by local luminance and contrast, i.e. by local std
if normalize
    stim_sd=lib.local_sd(stim,kernel_size,varargin{:});
    % stim_sd=std(stim(:));
    if normalize==true
        grad=grad./stim_sd;
        grad(isnan(grad))=0; % change 0/0 to 0
    else
        grad=grad./sqrt(stim_sd.^2+normalize);
    end
end