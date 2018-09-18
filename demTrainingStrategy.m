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

% leave out some facial expressions
iFErej = [3,5,6];
% iFErej = [];

%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of code, which
path.DB_raw = fullfile(cd,'DB','DB_raw');
path.DB_proc = fullfile(cd,'DB','DB_proc');
path.DB_analy = fullfile(path.DB_proc,name.DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% add functions
addpath(genpath(fullfile(cd,'functions')));
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
name.emo(iFErej) = [];
idxFE = find(ismember(1:11,iFErej)==0);

% get name list of subjects
[name.subject,~] = read_names_of_file_in_folder(path.DB_raw);

% name of types of features
name.feat = {'RMS';'WL';'SampEN';'CC'};
%-------------------------------------------------------------------------%



%------------------------------------main---------------------------------%
% get accrucies and output/target (for confusion matrix) with respect to
% subject, trial, number of segment, FE,
pair = 1; 
     
% load feature set, from this experiment
load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('feat_seg_pair_%d',pair)));
load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('feat_seq_pair_%d',pair)));
load(fullfile(path.DB_proc,name.DB_analy,...
    sprintf('idx_fe_seq_pair_%d',pair)));

% =============numeber of variables
tmp = strsplit(name.DB_analy,'_');
nOrgWin =60;
feat_seg = feat_seg(21:floor(3*2048/str2double(tmp{11})),:,~ismember(1:11,iFErej),:,:,:);
[N1, K, M, N2, U] = size(feat_seg);
% method = {'none', 'supervised', 'unsupervised'};
method = {'supervised'};
% hyper parameters
% betaList = 0:0.1:0.5; % regularized parameter for pooled covariance; 0--> do nothing
% alphaList = 0:0.1:0.5; % R.P. for pooled mean 
alphaList = 0;
betaList = 0;
uList = 1:41;

% result allocation
perf = NaN(N2,length(method),length(uList),length(alphaList),length(betaList));
for mtd = 1 : length(method);
c_a = 0;
for alpha = alphaList
c_a = c_a + 1;
c_b = 0;
for beta = betaList
c_b = c_b + 1;
c_u = 0;
for u = uList
c_u = c_u+1;

% display
fprintf('alpha:%.2f beta: %.2f u:%d method:%s\n',alpha,beta,u,method{mtd});

% 초기화
mdl = cell(N2,1);
curSess = 1;% prepare DB of session 1
xtr = concat_leaving_dim(feat_seg(:,:,:,1,u,pair),2);% 1번째 Session DB 추출 및 fitting
ytr =  get_labels(N1,idxFE, 1);
mdl{1} = fitLDA('X',xtr,'Y', ytr);
mdlNew = mdl{1};
mdlOld = mdl{1};

% test/adaptive training
while curSess < 20
   curSess = curSess + 1; % 다음 세션 테스트 진행
     
   % get test data
   xte = feat_seq{curSess,u};   
   
   % prediction 
   ypr = predLDA(mdlNew,xte);
   
   % evaluation
   temp = idx_fe_seq{curSess,u};
   temp(ismember(idx_fe_seq{curSess,u}(:,1),iFErej),:) = [];
   perf(curSess,mtd,c_u,c_a,c_b) = evalPerf(xte,ypr,temp,N1,M,nOrgWin);
   
   % batch adaption (methods: none, supervised, unsupervised)
   mdlOld = mdlNew;
   mdlNew = adapLDAFromTest(mdl{1},mdlOld,xtr,ytr,xte,ypr,temp,...
       'nWin',N1,'method',method{mtd},'nClass',M,...
       'alpha',alpha,'beta',beta);
end
end
end
end
end
%-------------------------------------------------------------------------%

% performance analysis
% result = squeeze(nanmean(perf,1));
% [~,idx] = max(result(:));
% [i,j] = ind2sub(size(result),idx)
result = squeeze(nanmean(nanmean(perf,1),3));
% result = permute(result,[2 3 1]);
% for mtd = 1 : 2
% acc{mtd} = squeeze(result(:,:,mtd));
% [~,idx] = max(acc{mtd}(:));
% [i,j] = ind2sub(size(result),idx)
% end

%-------------------------------save results------------------------------%
% % set folder name
% name.saving = sprintf('pair_%d_sub_%s_val_ses_%s_t_%s',...
%     pair, strrep(num2str(1:U),' ',''),strrep(num2str(1:n2),' ',''),...,
%     strrep(num2str(0:T),' ',''));
% 
% % set saving folder for windows
% path_saving = make_path_n_retrun_the_path(path.DB_analy,name.saving);
%     
% % save
% save(fullfile(path_saving,name.saving),'target','output');
%-------------------------------------------------------------------------%

%----------------------------plotting results------------------------------%
% accr = NaN(19,N1,T);
% for n_t = 0:T
% for n1 = 1: N1;
% for j = 1:19
%     tmp = cat(3,output(n1,:,1:U,1,n_t+1,j));
%     tmp1 = tmp(:);
%     
%     tmp = cat(3,target(n1,:,1:U,1,n_t+1,j));
%     tmp2 = tmp(:);
%     
%     output_tmp = full(ind2vec(tmp1',M));
%     target_tmp = full(ind2vec(tmp2',M));
%     [err,mat_conf,idx_of_samps_with_ith_target,~] = ...
%     confusion(target_tmp,output_tmp);
%     
%     accr(j,n1,n_t+1) = 1- err;
% 
% %     figure;
% %     h = plotconfusion(target_tmp,output_tmp);
% %     name.conf = strrep(name.emo,'_',' ');
% %     h.Children(2).XTickLabel(1:n_fe) = name.conf;
% %     h.Children(2).YTickLabel(1:n_fe)  = name.conf;
% end
% end
% end
% squeeze(mean(accr(:,N1/2,:)))
% squeeze(mean(accr(:,N1,:)))
% 
% figure;
% count = 0;
% for n_t = 0:T
%     count = count +1;
%     subplot(1,T+1,count);
%     plot(squeeze(mean(accr(:,:,n_t+1))))
% end

%=========================================================================%

        