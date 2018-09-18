function [yTest,idxYtest] = get_target(trigger,lenTest,idxExtract)
yTest = NaN(lenTest,1);

% idxExtract = 21:60;

idx= trigger(:,2)-1+idxExtract;


for iClass = 1 : size(trigger,1)
    yTest(idx(iClass,:)) =  trigger(iClass,1);
end
    
if nargout>1
    idxYtest = find(~isnan(yTest));
end
end