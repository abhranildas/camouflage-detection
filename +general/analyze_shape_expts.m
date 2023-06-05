hold on

% circle experiments
load('exp_files/texture_exponent/ecc_0/subject_out/neel.mat')
perf_circ=mean(SubjectExpFile.correct,[1 3]);
perf_circ=[perf_circ([5 6 7 8]) .9898];
% the last perf value here for exponent 1.2 is extracted from the
% psychometric fit
perf_circ_sd=sqrt(perf_circ.*(1-perf_circ)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));

% 0.8
load('exp_files/shape_exponent/0.8/subject_out/neel.mat')
exponents_0_8=linspace(0,1.6,7);
perf_0_8=mean(SubjectExpFile.correct,[1 3]);
% perf_0_8_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
perf_0_8_sd=sqrt(perf_0_8.*(1-perf_0_8)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));
errorbar([exponents_0_8 3],[perf_0_8 perf_circ(1)],[perf_0_8_sd perf_circ_sd(1)],'-om');
% plot(exponents_0_8,perf_0_8,'-ok');
xline(0.8,'m')

% 0.9
load('exp_files/shape_exponent/0.9/subject_out/neel.mat')
exponents_0_9=sort([linspace(0,2,7) [5 7 9]/6]);
perf_0_9=mean(SubjectExpFile.correct,[1 3]);
% perf_0_9_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
perf_0_9_sd=sqrt(perf_0_9.*(1-perf_0_9)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));
errorbar([exponents_0_9 3],[perf_0_9 perf_circ(2)],[perf_0_9_sd perf_circ_sd(2)],'-ok');
% plot(exponents_0_8,perf_0_8,'-ok');
xline(0.9,'k')

% 1
load('exp_files/shape_exponent/1/subject_out/neel.mat')
exponents_1=sort([linspace(0,2,7) [5 7 9]/6]);
perf_1=mean(SubjectExpFile.correct,[1 3]);
% perf_1_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
perf_1_sd=sqrt(perf_1.*(1-perf_1)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));
errorbar([exponents_1 3],[perf_1 perf_circ(3)],[perf_1_sd perf_circ_sd(3)],'-ob');
% plot(exponents_1,perf_1,'-ob');
xline(1,'b')

% 1.1
load('exp_files/shape_exponent/1.1/subject_out/neel.mat')
exponents_1_1=sort([linspace(0,2.2,7) .8249 .9166 1.2833]);
perf_1_1=mean(SubjectExpFile.correct,[1 3]);
% perf_1_1_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
perf_1_1_sd=sqrt(perf_1_1.*(1-perf_1_1)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));
errorbar([exponents_1_1 3],[perf_1_1 perf_circ(4)],[perf_1_1_sd perf_circ_sd(4)],'-or');
% plot(exponents_1_1,perf_1_1,'-or');
xline(1.1,'r')

% 1.2
load('exp_files/shape_exponent/1.2/subject_out/neel.mat')
exponents_1_2=linspace(0,2.4,7);
perf_1_2=mean(SubjectExpFile.correct,[1 3]);
% perf_1_2_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
perf_1_2_sd=sqrt(perf_1_2.*(1-perf_1_2)/(size(SubjectExpFile.correct,1)*size(SubjectExpFile.correct,3)));
errorbar([exponents_1_2 3],[perf_1_2 perf_circ(5)],[perf_1_2_sd perf_circ_sd(5)],'-og');
% plot(exponents_1_2,perf_1_2,'-og');
xline(1.2,'g')