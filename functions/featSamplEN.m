%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function y = featSamplEN(x,dimension4Entropy)
if nargin<2
    dimension4Entropy = 2;
end
if size(x,1)==1 && size(x,2)==1
   y = x; % dimension   
   return;
end
N_sig = size(x,2);
y = zeros(1,N_sig);
R = 0.2*std(x);
for i_sig = 1 : N_sig
    y(i_sig) = sampleEntropy(x(:,i_sig), dimension4Entropy, R(i_sig),1); %%   SampEn = sampleEntropy(INPUT, M, R, TAU)
end
end