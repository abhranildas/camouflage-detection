function r=autocorr(stim,span)
% 2d circular auto-correlation of a square image
% can later be changed to cross-correlation between a and b
bg_size=size(stim,1);
shifts=-span:span;
r_size=length(shifts);
r=nan(r_size);
parfor i=1:r_size
    i
    for j=1:r_size
        stim_shifted=circshift(circshift(stim,-shifts(i),1),-shifts(j),2);
        %             c=corrcoef(stim(:),stim_shifted(:));
        r(i,j)=dot(stim(:),stim_shifted(:));
    end
end
r=r/bg_size^2;