% This code was devloped by Hosueng Cha in refernce with
% "https://kr.mathworks.com/matlabcentral/answers/118828-how-to-count-the-number-of-consecutive-numbers-of-the-same-value-in-an-array"

function y = countStayedConst(x)
% check input was 1 X n vector
if ismatrix(x) && size(x,1) == 1 && size(x,2) > 1
    input = x;
elseif ismatrix(x) && size(x,2) == 1 && size(x,1) > 1
    input = x';
end


i = find(diff(input)) ;
n = [i numel(x')] - [0 i];
c = arrayfun(@(X) X-1:-1:0, n , 'un',0);
y = cat(2,c{:});
end