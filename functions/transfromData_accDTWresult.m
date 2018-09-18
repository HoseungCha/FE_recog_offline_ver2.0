%data를 DTW 결과에 따라 transform하는 함수
%data_resampled는 원 데이터에서 resampling 된 데이터, 
%match_pair_ref_test는 ref, test 간의 DTW 결과,
%nDivision_4Resampling는 Resampling 시 사용된 division의 크기이다.
% matPair(:,1): refence signal의 matching point
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

%match pair가 존재하는 ref 데이터 중 가장 가까운 데이터를 찾는다.
function [pos_test_estimated, idx_start2search] = findNearestPoint_InMatchPairRef(matPair,xpos, x, idx_start2search)
    try
    idx_matchPair = -1;
    len_match_pair = size(matPair,1);
%     if len_match_pair-idx_start2search-1==0 % 이전 특징으로 부터 모든 pair를 이미 찾아버렸을 때.. cur ==0이 되므로, 더이상 검색을 진행할 수 있음. 결국, 3번째 4번째 특징은 똑같아질듯
%         idx_start2search = idx_start2search-1;
%         disp('특징 끝에 두개 같음');
%     end
    for i=idx_start2search:len_match_pair
        cur = len_match_pair - i - 1;
%         if cur==0
%             keyboard;
%             if xpos==31
%                 
%             end
%         end
        if xpos== matPair(cur,1) %해당 지점이 skip 되지 않은 경우.
            idx_matchPair = cur;
            idx_start2search = i +1;
            break;
        elseif xpos< matPair(cur,1)
            d_ref_before = x(matPair(cur+1,1));
            d_ref_after = x(matPair(cur,1));
            d_center= x(xpos);
            
            if abs(d_ref_before - d_center) < abs(d_ref_after - d_center) % 앞의 데이터가 더 가까우면,
                idx_matchPair = cur +1;
                idx_start2search = i;
                break;
            else                                                          % 그렇지 않다면, 뒤의 데이터를 사용
                idx_matchPair = cur;
                idx_start2search = i+1;
                break;
            end
%         elseif (cur-1 ==0) % matching pair 모두 검색하여도,찾지 못하였을 때, matching point 끝 값을 넣음
%             idx_matchPair = cur;
%             idx_start2search = i +1;
%             break;
        end
    end
    
    if idx_matchPair<0
        fprintf('findNearestPoint_InMatchPairRef: 예상치 못한 에러 발생\n');
    end
    
    pos_test_estimated = matPair(idx_matchPair,2);
    catch ex
        keyboard;
    end
end