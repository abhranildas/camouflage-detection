function pClipped=compute_pClipped(stim)
    % calculate percentage of elements in the input that are outside 0 to 1
    pClipped=(sum(stim(:)<0)+sum(stim(:)>1))/numel(stim);
    if pClipped>0
        if pClipped>0.01
            fprintf(2,'%.2f%% of boundary ribbon clipped\n', 100*pClipped);
        else
        %fprintf('%f of boundary ribbon clipped\n', pClipped);
        end
    end
