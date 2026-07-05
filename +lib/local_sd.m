function stim_sd=local_sd(stim,kernel_size,varargin)
% local luminance*contrast (std) of an image

parser=inputParser;
parser.KeepUnmatched=true;
addRequired(parser,'stim');
addParameter(parser,'pad_val', nan, @isscalar);

% parse inputs
parse(parser,stim,varargin{:});
pad_val=parser.Results.pad_val;

% define local patch neighbourhood
filter_radius=kernel_size(1)*kernel_size(2);
filter_size=2*ceil(filter_radius)+1;
nhood=false(filter_size);
nhood_center=(floor(filter_size/2)+1)*[1 1];
for i=1:filter_size
    for j=1:filter_size
        if norm([i,j]-nhood_center)<=filter_radius
            nhood(i,j)=true;
        end
    end
end


if isnan(pad_val)
    stim_sd=stdfilt(stim,nhood);
else
    % pad the image
    pad_len = floor(filter_size/2);
    stim_padded = padarray(stim, [pad_len, pad_len], pad_val, 'both');

    % filter and keep valid region
    stim_sd_padded=stdfilt(stim_padded,nhood);
    stim_sd = stim_sd_padded(pad_len+1:end-pad_len, pad_len+1:end-pad_len);
end

end