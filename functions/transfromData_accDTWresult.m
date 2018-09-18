%data�� DTW ����� ���� transform�ϴ� �Լ�
%data_resampled�� �� �����Ϳ��� resampling �� ������, 
%match_pair_ref_test�� ref, test ���� DTW ���,
%nDivision_4Resampling�� Resampling �� ���� division�� ũ���̴�.
% matPair(:,1): refence signal�� matching point
%
% designed & coded by Dr. Won-Du Chang
% last modified 2017.05.03
% modified by Hoseung Cha (2018.09.06)
function [d_trans,pos_ref_exact_,pos_test_estimated_] = transfromData_accDTWresult(x2, x, matPair, nDiv4Resamp)
    lenResampled = size(x2,1);
    lenOriginal = (lenResampled -1)/nDiv4Resamp +1;
    d_trans = zeros(lenOriginal,1);
    pos_test_estimated_ = zeros(lenOriginal,1);
    pos_ref_exact_ = zeros(lenOriginal,1);
    idx_start2search = 1;
    for i=1:lenOriginal
        pos_ref_exact = (i -1) *nDiv4Resamp +1;
        [pos_test_estimated, idx_start2search] = findNearestPoint_InMatchPairRef(matPair,pos_ref_exact, x,idx_start2search);
        d_trans(i) = x2(pos_test_estimated);
        pos_test_estimated_(i) = pos_test_estimated;
        pos_ref_exact_(i) = pos_ref_exact;
    end
end

%match pair�� �����ϴ� ref ������ �� ���� ����� �����͸� ã�´�.
function [pos_test_estimated, idx_start2search] = findNearestPoint_InMatchPairRef(matPair,xpos, x, idx_start2search)
    try
    idx_matchPair = -1;
    len_match_pair = size(matPair,1);
%     if len_match_pair-idx_start2search-1==0 % ���� Ư¡���� ���� ��� pair�� �̹� ã�ƹ����� ��.. cur ==0�� �ǹǷ�, ���̻� �˻��� ������ �� ����. �ᱹ, 3��° 4��° Ư¡�� �Ȱ�������
%         idx_start2search = idx_start2search-1;
%         disp('Ư¡ ���� �ΰ� ����');
%     end
    for i=idx_start2search:len_match_pair
        cur = len_match_pair - i - 1;
%         if cur==0
%             keyboard;
%             if xpos==31
%                 
%             end
%         end
        if xpos== matPair(cur,1) %�ش� ������ skip ���� ���� ���.
            idx_matchPair = cur;
            idx_start2search = i +1;
            break;
        elseif xpos< matPair(cur,1)
            d_ref_before = x(matPair(cur+1,1));
            d_ref_after = x(matPair(cur,1));
            d_center= x(xpos);
            
            if abs(d_ref_before - d_center) < abs(d_ref_after - d_center) % ���� �����Ͱ� �� ������,
                idx_matchPair = cur +1;
                idx_start2search = i;
                break;
            else                                                          % �׷��� �ʴٸ�, ���� �����͸� ���
                idx_matchPair = cur;
                idx_start2search = i+1;
                break;
            end
%         elseif (cur-1 ==0) % matching pair ��� �˻��Ͽ���,ã�� ���Ͽ��� ��, matching point �� ���� ����
%             idx_matchPair = cur;
%             idx_start2search = i +1;
%             break;
        end
    end
    
    if idx_matchPair<0
        fprintf('findNearestPoint_InMatchPairRef: ����ġ ���� ���� �߻�\n');
    end
    
    pos_test_estimated = matPair(idx_matchPair,2);
    catch ex
        keyboard;
    end
end