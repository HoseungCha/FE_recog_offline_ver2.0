%-------------------------------------------------------------------------%
% 1. feat_extraction.m
% 2. classficiation_using_DB.m  %---current code---%
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
clc; close all; clear;

%-----------------------Code anlaysis parmaters---------------------------%
% name of raw DB

% name of process DB to analyze in this code
name.DB_process = 'DB_proc';

% load feature set, which was extracted by feat_extration.m
name.DB_analy = 'DB_raw2_n_sub_41_n_seg_60_n_wininc_102_winsize_262';

% decide if validation datbase set
id_DB_val = 'myoexp2'; % myoexp1, myoexp2, both

% decide number of tranfored feat from DB
T = 2;

% decide whether to use emg onset fueatre
id_use_emg_onset_feat = 0;

% decide which attibute to be compared when applying train-less algoritm
% 'all' : [:,:,:,:,:], 'Only_Seg' : [i_seg,:,:,:,:], 'Seg_FE' : [i_seg,:,i_FE,:,:]
T_method = 'Seg_FE'; % 'all', 'Only_Seg', 'Seg_FE'
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of code, which
path.DB_raw = fullfile(cd,'DB','DB_raw');
path.DB_proc = fullfile(cd,'DB','DB_proc');
path.DB_analy = fullfile(path.DB_proc,name.DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% add functions
addpath(fullfile(cd,'functions'));
%-------------------------------------------------------------------------%
% 
% %-----------------------------load DB-------------------------------------%
% % LOAD MODEL of EMG ONSET DETECTION
% load(fullfile(path.DB_proc,'model_tree_emg_onset.mat'));
% %-------------------------------------------------------------------------%

%-----------------------experiment information----------------------------%
% trigger singals corresponding to each facial expression(emotion)
name.emo = {'angry','clench',...
'lip_corner_up_left','lip_corner_up_right',...
'lip_corner_up_both','fear',...
'happy','kiss','neutral',...
'sad','surprised'};

% get name list of subjects
[name.subject,~] = read_names_of_file_in_folder(path.DB_raw);

% name of types of features
name.feat = {'RMS';'WL';'SampEN';'CC'};
%-------------------------------------------------------------------------%



%------------------------------------main---------------------------------%
% get accrucies and output/target (for confusion matrix) with respect to
% subject, trial, number of segment, FE,
for pair = 1 
     
% load feature set, from this experiment
load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('feat_seg_pair_%d',pair)));

load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('feat_seq_pair_%d',pair)));

load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('idx_fe_seq_pair_%d',pair)));

% =============numeber of variables
tmp = strsplit(name.DB_analy,'_');
feat_seg = feat_seg(1:floor(3*2048/str2double(tmp{11})),:,:,:,:);
[N1, K, M, N2, U] = size(feat_seg);
% U = 2;
F = length(name.feat);

%=============indices of variables
u_list = 1 : U;
n2_list = 1 : N2;
n2_val = 1;
nUpSample = 10;

f_list = {[1,2,3,4];[5,6,7,8];[9,10,11,12];13:28};

%== memory allocation
target = NaN(N1,M,U,length(n2_val),T+1,10,length(nUpSample));
output = NaN(N1,M,U,length(n2_val),T+1,10,length(nUpSample));


for R = 1: 10
for u = 1 : U
for n2 = n2_val
    
%display of subject and trial in progress
fprintf('R:%d i_emg_pair:%d i_sub:%d i_trial:%d\n',R,pair,u,n2);

if T>=1
DB = feat_seg(:,:,:,n2,u);
u_db = find(countmember(u_list,u)==0);
DB_c = feat_seg(:,:,:,:,~ismember(u_list,u));
DB_t = get_DB_prime(DB,DB_c,'T',2,'R',R,'fhandle',str2func('transWithDTW'));
% f_list,T,T_method,R,nUpSample);
% DB_t = get_DB_prime(DB,DB_c,f_list,T,T_method);

end

% validate with number of transformed DB
for n_t = 0 : T
if n_t >= 1
    % get feature-transformed with number you want
    xtr_tf = concat_leaving_dim( DB_t(:,:,:,1:n_t),2);
    
    % target for feature transformed
    ytr_tf = get_labels(N1,M, n_t);
else
    xtr_tf = [];
    ytr_tf = [];
end

% feat for anlaysis
xtr_ref = concat_leaving_dim(feat_seg(:,:,:,n2,u,pair),2);
ytr_ref = get_labels(N1,M, 1);

%=================PREPARE DB FOR TRAIN====================%
xtr = cat(1,xtr_ref,xtr_tf);
ytr = cat(1,ytr_ref,ytr_tf);
%=========================================================%

%============NORMALIZATION
% max_v = max(xtrain);
% min_v = min(xtrain);
% xtrain = (xtrain - min_v)./(max_v-min_v);

% get input and targets for test DB
test_list = find(n2_list~=n2==1);

count = 0;
for j = test_list
    count = count + 1;
    
    %==================TRAIN EACH EMOTION=====================%
%     a = dataset(xtr,ytr);
%     a = setlabtype(a,'soft');
    % W1 = ldc(a);
%     W = a*ldc*classc;
%     mdl = fitcdiscr(xtr,ytr);
    mdl = fitcdiscr(xtr,ytr,'OptimizeHyperparameters','auto',...
        'HyperparameterOptimizationOptions',...
        struct('AcquisitionFunctionName','expected-improvement-plus',...
        'UseParallel',true,'ShowPlots',false));
    %=========================================================%

    %================= TEST=====================%
    xte = feat_seq{j,u};   
%     xtest_ref = (xtest-min_v)./(max_v-min_v);

    m_seq = idx_fe_seq{j,u};
     %====PASS THE TEST FEATURES TO CLASSFIERS=============%
            
    %----EMOTION CLASSFIER
    [ypr,~] = predict(mdl,xte);
%     ypr = xte*W*labeld;
    
    % post processing
    ypr_cv = conditonal_voting_(ypr,5,5,M);
    
    %- ground truth
    yte = get_target(m_seq,length(xte),0,N1);
    
%--------------------- plot voting methods-----------------%
%     figure(1);
% %     subplot(2,1,1);clf;
% %     hold on;
% %     plot(ypr);
% %     plot(yte,'r','LineWidth',3);
% %     set(gca,'YTickLabel',strrep(name.emo,'_',' '))
%     
% %     subplot(2,1,2);
%     clf;
%     hold on;
%     plot(ypr_cv);
%     plot(yte,'r','LineWidth',3);
%     set(gca,'YTickLabel',strrep(name.emo,'_',' '))
%     hold off;
%     drawnow;
%----------------------------------------------------------%

    % validation 
    ypr_cv = ypr_cv(~isnan(yte));
    ypr_cv = reshape(ypr_cv,[N1,M]);

    yte = yte(~isnan(yte));
    yte = reshape(yte,[N1,M]);
    
    target(:,:,u,n2,n_t+1,count,R) = yte;
    output(:,:,u,n2,n_t+1,count,R) = ypr_cv;
    disp(length(find(yte(:)==ypr_cv(:)))/numel(ypr_cv));
    %=====================================================%
end      
end
end
end
end
end
%-------------------------------------------------------------------------%

%-------------------------------save results------------------------------%
% set folder name
name.saving = sprintf('pair_%d_sub_%s_val_ses_%s_t_%s',...
    pair, strrep(num2str(1:U),' ',''),strrep(num2str(1:n2),' ',''),...,
    strrep(num2str(0:T),' ',''));

% set saving folder for windows
path_saving = make_path_n_retrun_the_path(path.DB_analy,name.saving);
    
% save
save(fullfile(path_saving,name.saving),'target','output');
%-------------------------------------------------------------------------%

%----------------------------plotting results------------------------------%
accr = NaN(19,N1,T);
for r = 1 : R
for n_t = 0:T
for n1 = 1: N1;
for j = 1:19
    tmp = cat(3,output(n1,:,1:U,1,n_t+1,j,r));
    tmp1 = tmp(:);
    
    tmp = cat(3,target(n1,:,1:U,1,n_t+1,j,r));
    tmp2 = tmp(:);
    
    output_tmp = full(ind2vec(tmp1',M));
    target_tmp = full(ind2vec(tmp2',M));
    [err,mat_conf,idx_of_samps_with_ith_target,~] = ...
    confusion(target_tmp,output_tmp);
    
    accr(j,n1,n_t+1,r) = 1- err;

%     figure;
%     h = plotconfusion(target_tmp,output_tmp);
%     name.conf = strrep(name.emo,'_',' ');
%     h.Children(2).XTickLabel(1:n_fe) = name.conf;
%     h.Children(2).YTickLabel(1:n_fe)  = name.conf;
end
end
end
end
[~,idx] = max(mean(squeeze(mean(accr(:,N1/2,:,:)))))

figure;
count = 0;
for n_t = 0:T
    count = count +1;
    subplot(1,T+1,count);
    plot(squeeze(mean(accr(:,:,n_t+1))))
end

%=========================================================================%

        