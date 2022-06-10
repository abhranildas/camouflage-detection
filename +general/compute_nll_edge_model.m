function [nll,p_c,d_all,responses] = compute_nll_edge_model(p,edge_model,n_bdry_pixels,subj_id)

    sig_n=p(1);
    
    if sig_n>0
        d_all=cell(numel(edge_model),1);
        ll=0;
        for exp_id=1:numel(edge_model)
            target=edge_model(exp_id).target;
            nTrials=size(target,1);
            nLevels=size(target,2);
            
            %     n_bdry_pixels=edge_model.n_bdry_pixels;
            n_bdry_edge_pixels=edge_model(exp_id).n_bdry_edge_pixels;
            txtr_edge_density=edge_model(exp_id).txtr_edge_density;
            %         responses=cellfun(@(stim) lib.new_edge(stim,'bdry_strip',bdry_strip,'sig_n',sig_n),stimuli);
            d_n=(n_bdry_edge_pixels-n_bdry_pixels*txtr_edge_density)./sqrt(sig_n^2+n_bdry_pixels*txtr_edge_density.*(1-txtr_edge_density));
            responses=d_n;
            
            % mean and sd of edge responses for blanks and targets in each level
            r_b_means=nan(1,nLevels); r_b_sds=nan(1,nLevels);
            r_t_means=nan(1,nLevels); r_t_sds=nan(1,nLevels);
            for iLevel=1:nLevels
                r_level=responses(:,iLevel);
                r_b=r_level(~target(:,iLevel)); r_t=r_level(target(:,iLevel));
                r_b_means(iLevel)=mean(r_b); r_b_sds(iLevel)=sqrt(var(r_b)+1); % response noise of sd=1
                r_t_means(iLevel)=mean(r_t); r_t_sds(iLevel)=sqrt(var(r_t)+1);
            end
            
            % d'_e
            d=abs(r_t_means-r_b_means)./((r_b_sds+r_t_sds)/2);
            d_all{exp_id}=d;
            
            % ignoring bias
            p_c=normcdf(d/2);
            if subj_id==0 % optimal
                ll=ll+mean(p_c);
            else
                num_correct=sum(edge_model(exp_id).subject_data(subj_id).correct);
                ll=ll+sum(log(binopdf(num_correct,nTrials,p_c)));
            end
            
            % incorporating bias
            %         p_h=normcdf(d*(1-gamma)/2); % prob. of hits
            %         p_cr=normcdf(d*(1+gamma)/2); % prob. of correct rejection
            %         p_c=(p_h+p_cr)/2; % prob. of correct
            %         ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...
            %             sum(log(binopdf(num_cr,num_blanks,p_cr)));
            
        end
        nll = -ll;
    else
        nll = inf;
    end