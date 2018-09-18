function acc = crossVal(x,y,mdlNew,kFold)
if nargin<4
    kFold = 10;
end
n = size(x,1);

cv = cvpartition(n,'KFold',kFold);
for i =1 : kFold
    
    x(cv.training(i),:)

end