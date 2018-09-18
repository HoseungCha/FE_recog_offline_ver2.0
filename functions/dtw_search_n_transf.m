%--------------------------------------------------------------------------
% x2 신호들에 대해, x1신호 DTW 거리가 작은 N_s 개의 신호를 뽑은 후 변환하는 코드
%
% [xt] = dtw_search_n_transf(ref_singal, signals to transfrom,
% number of singals to extract)
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function [xt] = dtw_search_n_transf(x1, x2, options)
% define defaults

[N_f, N]= size(x2); dist = zeros(N,1);

for i = 1 : N
    dist(i) = dtw(x1, x2(:,i));
%     dist(i) = fastDTW(x1, x2(:,i),max_slope_length, ...
%         speedup_mode, window_width );
end
% Sort
[~, sorted_idx] = sort(dist);
% xs= x2(:,sorted_idx(1:N_s));
xt = zeros(N_f,options.T);
for i = 1 : options.T
%     xt(:,i)= transfromData_accRef_usingDTW(x2(:,sorted_idx(i)), x1, DTW_opt);
    xt(:,i) = options.fhandle(x1, x2(:,sorted_idx(i)), options);
end
% plot
if options.id_plot
h1 = figure(1);
h2 = figure(2);
plot_application_of_dtw(h1,x1,x2(:,sorted_idx(1)),xw)
plot_application_of_dtw(h2,x1,x2(:,sorted_idx(1)),xw2)
end


            
end