function out = getPair(tmp)
backup = tmp;
    for j = 1 : 2
        [~,ia,~] = unique(tmp(:,j));
        tmp = tmp(ia,:);
    end
    out = flipud(tmp);
end