function [p_c,p_h,p_cr,y]=psychometricFun_trials(x,mu,a,b,c,y_blanks)
    [~,p_h,~,y]=experiment.analysis.psychometricFun(x,mu,a,b,c);
    yc=y*(1+c)/2;
    p_cr=mean(normcdf(yc-y_blanks)); % prob. of correct rejection
    p_c=(p_h+p_cr)/2; % prob. of correct
    
