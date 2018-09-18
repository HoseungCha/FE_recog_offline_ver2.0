%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function [featWindow,idxFeatList] = getFeatures(windowDB);
% init
nChannel = size(windowDB{1},2);
idxFeatList = getFeatVector(nChannel);

% feature extraction of each window
nWindows = length(windowDB);
featWindow = zeros(nWindows,idxFeatList{end}(end));
for i = 1 : nWindows
    featWindow(i,:) = getFeatVector(windowDB{i},'idxFeatList',idxFeatList);
end

end