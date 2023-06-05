x=[edge_props_b.ep16];

A=[-1 0; 1 -1]; b=[0 0];

m=mean(x); v=var(x);

% initial guesses for lambda_1 and lambda_2
% are made from the mean and sd, see journal notes:
lambda0=2./(m+sqrt(2*v-m^2)*[1 -1]);
% force the lambda_2 to be larger:
lambda0(2)=max(lambda0(2),lambda0(1)+eps)

lambda=fmincon(@(lambda) lib.hyperexp_nll(x,lambda),lambda0,A,b)

figure; hold on
histogram(x,'normalization','pdf','edgecolor','none');
fplot(@(x) lambda(1)*lambda(2)/(lambda(2)-lambda(1))*(exp(-lambda(1)*x)-exp(-lambda(2)*x)),[0 max(x)])
