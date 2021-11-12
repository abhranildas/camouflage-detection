lum_cont=[
.01 .05;
.01 .15;
.01 .25;
.01 .35;

.1 .05;
.1 .15;
.1 .25;
.1 .35;

.3 .05;
.3 .15;
.3 .25;
.3 .35;

.5 .05;
.5 .15;
.5 .25;
.5 .35;

.7 .05;
.7 .15
];

thresholds_lum_cont=struct;
for i=1:size(lum_cont,1)
    luminance=lum_cont(i,1); contrast=lum_cont(i,2);
    exp_name=['1fnoise_L' num2str(luminance) '_C' num2str(contrast)];
    [a, aStd, sessions] = analysis.computeThresholdInBin(exp_name, 'ad', 1, 1);
    thresholds_lum_cont(i).luminance=luminance;
    thresholds_lum_cont(i).contrast=contrast;
    thresholds_lum_cont(i).sessions=sessions;
    thresholds_lum_cont(i).threshold=a;
    thresholds_lum_cont(i).threshold_std=aStd;
end

[xData, yData, zData] = prepareSurfaceData([thresholds_lum_cont.luminance],[thresholds_lum_cont.contrast],[thresholds_lum_cont.threshold]);
sf = fit( [xData, yData], zData, 'thinplateinterp', 'Normalize', 'on' );
%Or use Thin-plate spline interpolant with centering and scaling from the
%curve fitting toolbox. This code is doing the same thing.
[xq,yq] = meshgrid(.1:.03:.7, .05:.03:.35);

zq = sf(xq,yq);

figure;
surf(xq,yq,zq,'EdgeAlpha', .2,'FaceAlpha',.7);
hold on
plot3([thresholds_lum_cont.luminance],[thresholds_lum_cont.contrast],[thresholds_lum_cont.threshold],'.','MarkerSize',12,'MarkerEdgeColor','black','MarkerFaceColor','black')
hold off
xlim([.1 .7])
xlabel 'luminance'

ylim([.05 .35])
ylabel 'contrast'

zlim([0 1])

zlabel 'threshold'
set(gca,'FontSize',13)
    