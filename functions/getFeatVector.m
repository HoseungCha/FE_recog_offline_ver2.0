%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function featVector = getFeatVector(d,varargin);
% define defaults
opt = struct(...
    'featList',{{'RMS','CC','WL','SamplEN'}},...
    'idxFeatList',[]...
    );
% set argument
opt = chaSetArgument(opt,varargin);
% dispatch argument
temp = structvars(opt); for i=1:size(temp,1), eval(temp(i,:));end
clear temp;
 

if size(d,1) ==1 && size(d,2) ==1
 nDims = d;
 idInit = true;
else
    idInit = false;
    if isempty(idxFeatList)
       error('please input idxFeatList obtained by init')
    end
end

nFeatType = length(featList);

if idInit  %init 할 경우

% init
dimsList = zeros(nFeatType,1);
idxFeatList = cell(nFeatType,1);
for i = 1 : nFeatType
    % get Feature Functions
    funcFeat = str2func(['feat',featList{i}]);
    dimsList(i) = funcFeat(nDims);
    idxFeatList{i} = (1:dimsList(i)) + sum(dimsList(1:i-1)); 
end
    featVector = idxFeatList;
    return;
    
else % init은 끝났을 경우

nFeatDims = idxFeatList{end}(end);
featVector = zeros(1, nFeatDims);

for i = 1 : nFeatType
    % get Feature Functions
    funcFeat = str2func(['feat',featList{i}]);
    featVector(idxFeatList{i}) = funcFeat(d);
end
end
end