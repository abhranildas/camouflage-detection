function plot_edge_energy_hists()
% plots histograms of edge energies for 1/f samples with and without
% target.
load seed_energy
figure
histogram(seed_energy(:,2),1000,'Normalization','probability','LineStyle','none','FaceAlpha',1);
hold on
histogram(seed_energy(:,3),1000,'Normalization','probability','LineStyle','none','FaceColor',[255 76 76]/255,'FaceAlpha',1);
xlim([-0.5 1.51])
set(gca,'xtick',-.5:.5:1.5)
xlabel 'edge strength E'
%ylim([0 .024])
set(gca,'ytick',[])
ylabel 'frequency'
%legend('background','background + target')
%legend boxoff
set(gca,'FontSize',13)
box off




