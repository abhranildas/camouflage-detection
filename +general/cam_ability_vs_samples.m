load ('global_data/seed_energy_pink_noise.mat')
n_list=round(10.^(1:.1:4));
nTrials=100;
n_stats=zeros(numel(n_list),4);
samples=zeros(nTrials,3);
for i=1:numel(n_list)
    n=n_list(i)
    for iTrial=1:nTrials        
        energy_sample=randsample(seed_energy(:,3),n);
        samples(iTrial,:)= [mean(energy_sample), min(energy_sample), max(energy_sample)];
    end
    n_stats(i,:)=[n, mean(samples)];
end

plot(n_stats(:,1),n_stats(:,4),'-o');
hold on
plot(n_stats(:,1),n_stats(:,2),'-o');
plot(n_stats(:,1),n_stats(:,3),'-o');
%xlim([min(n_list) max(n_list)])
xlabel 'number of samples'
ylabel 'edge strength'
legend('maximum','mean','minimum')
legend boxoff
set(gca,'fontsize',13)
