%data�� ref�� ���� transform�ϴ� �Լ�
%
% designed & coded by Dr. Won-Du Chang
% last modified 2017.05.03
function d_trans = transWithDPW(data_ref,data_test, opt)
    %Normalization
%     data_norm_test = NormalizeFeature_4DTW(data_ref, data_test);
    
    %Add additional Data
    data_reSampled_ref  = Resampling(data_ref, opt.nUpSample);
    data_reSampled_test = Resampling(data_test, opt.nUpSample);
    
    %DTW calculation
    [dist, ~, match_pair_ref_test] = fastDPW(data_reSampled_ref, data_reSampled_test, opt.dtw_opt.max_slope_length, opt.dtw_opt.speedup_mode);  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %dist�� ���� ũ�� �̻��̸� transform ���ϴ� �ڵ尡 �ʿ��� ��
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %transformation
    [d_trans,pos_ref_exact_,pos_test_estimated_] = transfromData_accDTWresult(data_reSampled_test, data_reSampled_ref, match_pair_ref_test, opt.nUpSample);
%     disp(match_pair_ref_test(1,:));
    % ���߿� �� �� �뵵
%     close all;
%     figure(2)
%     plot(data_reSampled_ref);
%     hold on;
%     plot(data_reSampled_test);
%     for i = 1 : length(match_pair_ref_test)
%         idx_ref = match_pair_ref_test(i,1);
%         idx_test = match_pair_ref_test(i,2);
% 
%         temp4plot = [[idx_ref,data_reSampled_ref(idx_ref)];...
%             [idx_test,data_reSampled_test(idx_test)]];
%         hold on;
%         plot(temp4plot(:,1),temp4plot(:,2),'k')
%     end
%     
%     for i = 1 : 6
%         scatter(pos_ref_exact_(i),data_reSampled_ref(pos_ref_exact_(i)),'magenta');
%         scatter(pos_test_estimated_(i),data_reSampled_test(pos_test_estimated_(i)),'red');
%     end
% 
%     figure(1)
%     plot(data_ref);
%     hold on;
%     plot(data_test);
%     hold on;
%     plot(d_trans);
end
