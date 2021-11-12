%% vary sd
e=0:.01:100;

figure; hold on

for s=[1 2 3]
    pc=normcdf(e/s);
    plot(e,pc);
end

set(gca,'xscale','log')

%% vary bias

s=1;
figure; hold on;
for k=0:.05:.5
    pc=(normcdf(k*e/s)+normcdf((1-k)*e/s))/2;
    plot(e,pc,'-k');
end

set(gca,'xscale','log')
