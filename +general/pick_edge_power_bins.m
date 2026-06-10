% load edge powers
histogram(edge_powers(:,1))
hold on
histogram(edge_powers(:,2))
ylim([60 60000])
set(gca,'yscale','log')

% find leftmost and rightmost bin locations
bins=linspace(.759,.899,10);

% now use xline to mark bins, and add to:
edgePowerBlockEdges=[];

% then save edge_powers and block edges in the edge power file
% then run experiment.setUpExperiment
