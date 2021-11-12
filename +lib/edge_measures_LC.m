function [n_groups,l_groups,e_groups]=edge_measures_LC(edge)
s=sign([edge,edge]);
sign_changes=diff(s);
sign_changes=sign_changes(1:length(edge));
locs=find(sign_changes);

% circularly shift to begin at a group
edge=circshift(edge,-locs(1));
sign_changes=circshift(sign_changes,-locs(1));

locs=find(sign_changes);
n_groups=length(locs);
locs=[0,locs];
l_groups=diff(locs);

e_groups=nan(1,n_groups);
for i=1:n_groups
    e_groups(i)=mean(edge(locs(i)+1:locs(i+1)).^2);
end
