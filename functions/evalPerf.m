% evaluation
function perf = evalPerf(xte,ypr,idx_fe_seq,N1,M,nOrgWin)
%- ground truth
yte = get_target(idx_fe_seq,length(xte),0,N1,nOrgWin);
try
    perf=length(find(...
        ypr(~isnan(yte)) == ...
        get_labels(N1,idx_fe_seq(:,1)', 1)))...
        /((N1)*M);
catch ex
    keyboard;
end
end