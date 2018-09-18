%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function y = featCC(x,order)
if nargin < 2
    order = 4;
end

if size(x,1)==1 && size(x,2)==1
   y = order*x; % dimension   
   return;
end

cur_xlpc = real(lpc(x,order)');
cur_xlpc = cur_xlpc(2:(order+1),:);
Nsignals = size(x,2);
cur_CC = zeros(order,Nsignals);
for i_sig = 1 : Nsignals
  cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
end
y = reshape(cur_CC,[1,order*Nsignals]);
end

function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

c = NaN(cp,1);
for n=1:cp
    sum=0;
    if n<p+1
        for k=1:n-1
            sum=sum+(n-k)*c(n-k)*a(k);
        end
        c(n)=-a(n)-sum/n;
    else
        for k=1:p
            sum=sum+(n-k)*c(n-k)*a(k);
        end
        c(n)=-sum/n;
    end
end
end