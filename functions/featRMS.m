%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function y = featRMS(x)
if size(x,1)==1 && size(x,2)==1
   y = x; % dimension   
   return;
end
y = sqrt(mean(x.^2));
end