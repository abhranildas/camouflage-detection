%% Compute edge contour features of pink noise stimuli
clearvars
texture.type='pink_noise';
target_radius=64;
lum=0.5;
cont=0.15;
ppd=60;
[~,~,~,bd_strip]=lib.target_mask('kernel_size',[1 2]);
n_samples=1e3;
edge_density_b=nan(n_samples,1);
edge_density_t=nan(n_samples,1);

for seed=1:n_samples
    seed
    [stim_t,stim_b]=lib.stimulus('seed',seed,'texture',texture,'ml_b',lum,'cont_b',cont,'target_radius',target_radius);

    % target edge properties
    stim_otf=vislib.otf_filter(stim_t,ppd,4,555);
    edge_pixels=lib.detect_edge_pixels(stim_otf);
    bd_pixels=single(edge_pixels&bd_strip)';
    bd_pixels(~bd_strip)=nan; % nan the non-boundary region to compute densities correctly
    [edge_props,mean_edge_props]=lib.edge_props_stim(stim_otf,'edge_pixels',bd_pixels);
    edge_density_t(seed)=mean_edge_props.dens;
    if ~exist('edge_props_t','var')
        edge_props_t=edge_props;
    else
        edge_props_t=[edge_props_t edge_props];
    end

    % blank edge properties
    stim_otf=vislib.otf_filter(stim_b,ppd,4,555);
    edge_pixels=lib.detect_edge_pixels(stim_otf);
    bd_pixels=single(edge_pixels&bd_strip)';
    bd_pixels(~bd_strip)=nan; % nan the non-boundary region to compute densities correctly
    [edge_props,mean_edge_props]=lib.edge_props_stim(stim_otf,'edge_pixels',bd_pixels);
    edge_density_b(seed)=mean_edge_props.dens;
    if ~exist('edge_props_b','var')
        edge_props_b=edge_props;
    else
        edge_props_b=[edge_props_b edge_props];
    end

end

%% plot statistics of a feature
figure; hold on
histogram(log([edge_props_b.pos_al]),'normalization','pdf','edgecolor','none')
histogram(log([edge_props_t.pos_al]),'normalization','pdf','edgecolor','none')

