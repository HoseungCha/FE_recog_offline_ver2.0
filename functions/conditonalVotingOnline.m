function yPdCv = conditonalVotingOnline(yPdCv,ypred,Vs,Nv,M)
% condition #1
% template_c1 = logical([1 1 1 1 1]);
% condition #2
% template_c2 = logical([1 1 0 1 1]);
% condition #3
% template_c3 = logical([1 1 1 0 0 0 0 0 0 0 0 0 1]);

persistent cq; % ó���� �����ǰ�, ���� ���ʹ� ���ӵǴ� ����

try

if isempty(cq) % �ʱ�ȭ
    cq = circlequeue(Vs,1);
end

% get current predicted values
cq.add(ypred);    

% voting�� ���� �����ŭ �ȸ��� ��� ��ǥ�� ó��
if cq.datasize<Vs
    yPdCv.add(9); % ��ǥ��
    return;
end

% voting�� ���� �����ŭ ���� ���
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