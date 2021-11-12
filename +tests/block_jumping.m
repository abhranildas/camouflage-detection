load('exp_files/1fnoise_L0.5_C0.15/exp_settings.mat')
eOld=[ExpSettings.edgeEnergies(:,:,1); ExpSettings.edgeEnergies(:,:,2); ExpSettings.edgeEnergies(:,:,3); ExpSettings.edgeEnergies(:,:,4)];
bT=[ExpSettings.bTargetPresent(:,:,1); ExpSettings.bTargetPresent(:,:,2); ExpSettings.bTargetPresent(:,:,3); ExpSettings.bTargetPresent(:,:,4)];

figure; hold on
for block=1:10
    stem(eOld(bT(:,block)==1,block),ones(size(eOld(bT(:,block)==1,block))),'marker','none')
end

eNew=zeros(size(eOld));
seeds=[ExpSettings.stimuliSeed(:,:,1); ExpSettings.stimuliSeed(:,:,2); ExpSettings.stimuliSeed(:,:,3); ExpSettings.stimuliSeed(:,:,4)];

bg_size=256;                              % background width
target_radius=64;
cont=0.15;                                % image RMS contrast
ml=0.5;                                   % image mean luminance
kernel_size=[1 3];
texture_params.type='pink_noise';

for i=1:size(seeds,1)    
    for j=1:size(seeds,2)
        [i j]
        seed=seeds(i,j);
        stim_target=lib.stimulus(texture_params,seed,bg_size,target_radius,'center',0,ml,cont,'match','match');
        eNew(i,j)=lib.edge_energy(stim_target,target_radius,'center',kernel_size,'grad_by_norm');
    end
end

figure; hold on
for block=1:10
    stem(eNew(bT(:,block)==1,block),ones(size(eNew(bT(:,block)==1,block))),'marker','none')
end

figure; hold on
for block=1:10
    plot(eOld(bT(:,block)==1,block),eNew(bT(:,block)==1,block),'.')
end


bBad=zeros(size(eNew));

for col=1:9
    bBad(eNew(:,col)>min(eNew(:,col+1)),col)=1;
end

for col=2:10
    bBad(eNew(:,col)<max(eNew(:,col-1)),col)=1;
end


sum(sum(bBad(bT)))/sum(sum(bT))

