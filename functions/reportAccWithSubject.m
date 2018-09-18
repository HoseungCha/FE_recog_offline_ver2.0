function [accSubject, meanAcc] = reportAccWithSubject(acc)
meanAcc = mean(acc,3);

[~,idx] = max(meanAcc(:));
[i,j] = ind2sub(size(meanAcc),idx);

accSubject = [squeeze(acc(1,1,:)),squeeze(acc(end,end,:)),squeeze(acc(i,j,:))];
% bar(accSubject,'DisplayName','accSubject');
end