function [idx_Xt_new,idUpdate] = getIdxXnew(idxFE,N1,ypr,idYtr)
idx_Xt_new = NaN(N1,length(idxFE));
idUpdate = true;
n_min = N1+1;
c = 0;
for i_class = idxFE
    c = c + 1;
    tmp = ypr;
    tmp(ypr~=i_class) = 0;
    idx = countStayedConst(ypr)';
    idx_class = find(ypr==i_class);
    [~,idx_sorted] = sort(idx(idx_class),'descend');
    
    % check max number of training examples
    n_len = length(idx_sorted);
    if  n_len < n_min
        n_min = n_len; % 작으면 n_min 업데이트
    end
%     if n_min ==0
%         keyboard;
%     end
    if n_len>N1
        idx_Xt_new(:,c) = idx_class(idx_sorted(1:N1));
    else
        idx_Xt_new(1:n_len,c) = idx_class(idx_sorted);
    end
end
if  n_min > 20 && n_min < N1
    idx_Xt_new = idx_Xt_new(1:n_min,:);
elseif n_min <= 20
    disp('use previous model')
    idUpdate = false;
    
end

end