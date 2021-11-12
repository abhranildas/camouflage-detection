function [acc,hr,fa]=discrim_accuracy(values_left,values_right,criterion)
% return overall accuracy, hit rate and false alarm rate.
% this weighs the left and right distribution counts according to their sample sizes,
% so returns the effective results for equal sample size.
n_a=numel(values_left); n_b=numel(values_right);
acc=1-(sum(values_left>criterion)/n_a+sum(values_right<criterion)/n_b)/2;
hr=sum(values_right>criterion)/n_b;
fa=sum(values_left>criterion)/n_a;
