function i = getClassMaxFP(mdl,M)
cvmodel = mdl.crossval('kfold',10);
target = getSimplex(mdl.Y,M);
output = getSimplex(cvmodel.kfoldPredict,M);
[err,mat_conf,idx_of_samps_with_ith_target,~] = ...
confusion(target,output);
disp(err);
h = plotconfusion(target,output);
idxDiagnal = 1:M+1:numel(mat_conf);
mat_conf(idxDiagnal) =0;
[~,idx] = sort(mat_conf(:),'descend');
[i,j] = ind2sub(size(mat_conf),idx(1));
end