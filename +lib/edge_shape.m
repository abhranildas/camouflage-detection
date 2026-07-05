function [edge_grid, th_grid, edge_autocorr, th_lags, edge_spectrum_amps, edge_spectrum_phases] = edge_shape(stim,target_radius,n_th,bPlot)
% Return a gridded edge, edge autocorrelation and spectrum.
bg_size=size(stim,1);
target_center=floor(bg_size/2)*[1 1];

% array of angles
thetas=zeros(bg_size);
for i=1:bg_size
    for j=1:bg_size
        vec=[i,j]-target_center;
        thetas(i,j)=cart2pol(vec(1),vec(2));
    end
end

% calculate stimulus gradient using steerable filter:
stim_grad=lib.steerable_grad(stim,[1 3]);

% create target mask
[~,mask_edge,mask_normal]=lib.circular_mask(size(stim,1),target_radius,'center');

% normal gradient
grad_normal=mask_normal(:,:,1).*stim_grad(:,:,1)+mask_normal(:,:,2).*stim_grad(:,:,2);

% table of theta and edge
th_edge=sortrows([thetas(mask_edge),grad_normal(mask_edge)]);

% make unique
[~,unique_idx]=unique(th_edge(:,1));
th_edge=th_edge(unique_idx,:);

% wrap on either side to help interpolation
th_edge_wrap=[[th_edge(:,1)-2*pi; th_edge(:,1); th_edge(:,1)+2*pi],repmat(th_edge(:,2),[3 1])];

% gridded interpolation
F = griddedInterpolant(th_edge_wrap(:,1),th_edge_wrap(:,2));

th_grid=linspace(-pi,pi,n_th+1);
th_grid=th_grid(2:end);
edge_grid=F(th_grid);

% edge autocorrelation:
n_corr=floor(n_th/2)+1; % # of items in autocorr
th_lags=(0:n_corr-1)*2*pi/n_th;
%th_lags=th_lags(1:end-1);
edge_autocorr=zeros(1,n_corr);
for i=1:n_corr    
    edge_autocorr(i)=mean(edge_grid.*circshift(edge_grid,i-1));
end

% edge spectrum amplitude and phase:
edge_fft=fft(edge_grid);
edge_spectrum_amps=abs(edge_fft(1:ceil((n_th+1)/2))); % remove repeated part
edge_spectrum_phases=angle(edge_fft);

if bPlot
    figure
    subplot(3,1,1)
    plot(th_grid,edge_grid)    
    hold on
    plot(th_edge(:,1),th_edge(:,2),'.')
    title 'gridded edge'
    
    subplot(3,1,2)
    plot(th_lags,edge_autocorr)
    title 'edge autocorrelation'
    
    subplot(3,1,3)
    plot(edge_spectrum_amps)
    title 'edge spectrum'
end