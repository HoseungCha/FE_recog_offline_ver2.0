function [idx_Xt_new,idUpdate] = getIdxXnewV2(idxFE,N1,ypr)
len = N1-20;
idx_Xt_new = NaN(len,length(idxFE));
idUpdate = true;
c = 0;
for i_class = idxFE
    c = c + 1;
    tmp = ypr;
    tmp(ypr~=i_class) = 0;
    idx = countStayedConst(ypr)';
    idx_class = find(ypr==i_class);
    [~,idx_max] = max(idx(idx_class));
    idx_Xt_new(:,c) = (idx_class(idx_max):idx_class(idx_max)+len-1)';
    
end

end