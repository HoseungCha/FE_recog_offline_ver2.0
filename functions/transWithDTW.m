% data를 ref에 따라 warping 하는 함수
% designed & coded by Hoseung Cha
% last modified 2018.09.05
function xw = transWithDTW(x, x2, opt)
r = opt.R;
nSample = opt.nUpSample;

    %Normalization
%     data_norm_test = NormalizeFeature_4DTW(data_ref, data_test);
%     nSample = 10;
    %Add additional Data
    xResample  = Resampling(x, nSample);
    x2Resample = Resampling(x2, nSample);
    
    %DTW calculation
%     [dc,i,j] = dtw(xResample,x2Resample,r);
    [~,i1,i2] = dtw(xResample',x2Resample',r);
    match_pairs = flipud([i1,i2]);
    
%     

    xw = transfromData_accDTWresult(x2Resample, xResample, match_pairs,...
        nSample);
        
%     xResample(i);
%     h1 = figure(1);
%     plot_application_of_dtw(h1,x,x2,xw)

    
end
