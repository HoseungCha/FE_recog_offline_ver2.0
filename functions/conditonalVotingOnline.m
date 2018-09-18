function yPdCv = conditonalVotingOnline(yPdCv,ypred,Vs,Nv,M)
% condition #1
% template_c1 = logical([1 1 1 1 1]);
% condition #2
% template_c2 = logical([1 1 0 1 1]);
% condition #3
% template_c3 = logical([1 1 1 0 0 0 0 0 0 0 0 0 1]);

persistent cq; % 처음만 생성되고, 다음 부터는 지속되는 변수

try

if isempty(cq) % 초기화
    cq = circlequeue(Vs,1);
end

% get current predicted values
cq.add(ypred);    

% voting에 사용될 사이즈만큼 안모였을 경우 무표정 처리
if cq.datasize<Vs
    yPdCv.add(9); % 무표정
    return;
end

% voting에 사용될 사이즈만큼 모였을 경우
[N,idx] = sort(countmember(1:M,cq.getLastN(Vs)),'descend');
if N(1)>=Nv
    cand_idx = idx(N(1) == N);
    if length(cand_idx)>1
        A = NaN(length(cand_idx),1);
        c = 0;
        for i = cand_idx
            c = c + 1;
            A(c) = find(cq.getLastN(Vs)==i,1,'last');
        end
        [~,idx] = sort(A,'descend');
        yPdCv.add(cand_idx(idx(1)));
    else
        yPdCv.add(cq.getLast);
    end
else
    yPdCv.add(yPdCv.getLast);
end

catch ex
    keyboard;
end
end