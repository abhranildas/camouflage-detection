%% compute correlation as a function of separation distance of point pairs
% that cross / don't cross the target boundary, for a bunch of pink noise
% stimuli.


bg_size=256;
target_radius=64;
texture_params.type='pink_noise';
n_seeds=4000;

mask=lib.circular_mask(bg_size,target_radius,'center');
x2=repmat((0:bg_size-1).^2,[bg_size,1]); % array of x^2
d=sqrt(unique(x2+x2'));

if exist('global_data/pink_noise_stim_blank_autocorr.mat','file')==2
    load('global_data/pink_noise_stim_blank_autocorr.mat')
    seed_start=size(corr_same,2)+1;
    %corr_same=[corr_same,nan(numel(d),n_seeds)];
    corr_cross=[corr_cross,nan(numel(d),n_seeds)];    
else
    %corr_same=nan(numel(d),n_seeds);
    corr_cross=nan(numel(d),n_seeds);
    seed_start=1;
end

tic
parfor seed=seed_start:seed_start+n_seeds-1
    seed
    stim=lib.stimulus(texture_params,seed,bg_size,0,'center',0,0.5,.15);
    %corr_cross_this=lib.correlations_across(stim,mask);
    %corr_same(:,seed)=corr_same_this;
    corr_cross(:,seed)=lib.correlations_across(stim,mask);
end
toc

figure; hold on
%plot(d,corr_same,'Color',[0 0 1 .05])
%plot(d,mean(corr_same,2),'b')
plot(d,mean(corr_cross,2),'r')
%xlim([0 150])

save('global_data/pink_noise_stim_blank_autocorr.mat','d','corr_cross');


%% log-likelihood-ratio decision variable based on autocorrelations
n_seeds=size(corr_blank_cross,2);

c_b=mean(corr_blank_cross,2);
c_t=mean(corr_target_cross,2);

s_b=std(corr_blank_cross,0,2);
s_t=std(corr_target_cross,0,2);

LLR_blank=nan(n_seeds,1);
LLR_target=nan(n_seeds,1);

for seed=1:n_seeds
    seed
    c=corr_blank_cross(:,seed);
    LLR_blank(seed)=nansum(terms(20:end));
    c=corr_target_cross(:,seed);
    LLR_target(seed)=nansum(log(s_b./s_t)+((c-c_b).^2)./(2*s_b.^2)-((c-c_t).^2)./(2*s_t.^2));
end

lib.compute_dPrime_pCorrect(LLR_blank,LLR_target,100,1);

%save('global_data/pink_noise_stim_corrs.mat','d','corr_blank_cross','corr_target_cross','LLR_blank','LLR_target');

%% d' as a function of distance
dPrime=nan(numel(d),4);
for i=2:numel(d)
    [dPrime_av,dPrime_hf,dPrime_pc,opt_acc]=lib.compute_dPrime_pCorrect(corr_cross(i,:),corr_same(i,:),10,0);
    dPrime(i,:)=[dPrime_av,dPrime_hf,dPrime_pc,opt_acc];
end
%plot(d(floor(d)==d),dPrime(floor(d)==d,4))
