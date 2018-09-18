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
addpath(genpath('E:\OneDrive\연구지식\Gaussian Process Latent Variable Model\ds_gplvm_v0.9'));
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
feat_seg = feat_seg(20:floor(3*2048/str2double(tmp{11})),:,:,:,:);
[N1, K, M, N2, U] = size(feat_seg);
% U = 2;
F = length(name.feat);

%=============indices of variables
u_list = 1 : U;
n2_list = 1 : N2;
n2_val = 1;

f_list = {[1,2,3,4];[5,6,7,8];[9,10,11,12];13:28};

% DB preperation
xDB = cell(U,1);
yDB = cell(U,1);

% % feat for anlaysis
% xDB{u} = concat_leaving_dim(feat_seg(:,:,:,n2,u),2);
% yDB{u} = get_labels(N1,M, 1);

for u = 1:U
xDB{u} = concat_leaving_dim(feat_seg(:,:,:,:,u),2);
yDB{u} = get_labels(N1,M, N2);
end
idx = get_labels(N1*M,N2,1); % for training and test set



%== memory allocation
target = NaN(N1,M,U,length(n2_val),T+1,N2-1);
output = NaN(N1,M,U,length(n2_val),T+1,N2-1);
% for u = 1 : U
for n2 = n2_val

% train_ind = find(idx==n2);
train_ind = find(idx==n2);
test_ind = find(idx~=n2);

% gplvm
model = ds_gplvm_main(xDB,yDB,train_ind,test_ind);


end
end
% end
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
for n_t = 0:T
for n1 = 1: N1;
for j = 1:19
    tmp = cat(3,output(n1,:,1:U,1,n_t+1,j));
    tmp1 = tmp(:);
    
    tmp = cat(3,target(n1,:,1:U,1,n_t+1,j));
    tmp2 = tmp(:);
    
    output_tmp = full(ind2vec(tmp1',M));
    target_tmp = full(ind2vec(tmp2',M));
    [err,mat_conf,idx_of_samps_with_ith_target,~] = ...
    confusion(target_tmp,output_tmp);
    
    accr(j,n1,n_t+1) = 1- err;

%     figure;
%     h = plotconfusion(target_tmp,output_tmp);
%     name.conf = strrep(name.emo,'_',' ');
%     h.Children(2).XTickLabel(1:n_fe) = name.conf;
%     h.Children(2).YTickLabel(1:n_fe)  = name.conf;
end
end
end
squeeze(mean(accr(:,N1/2,:)))
squeeze(mean(accr(:,N1,:)))

figure;
count = 0;
for n_t = 0:T
    count = count +1;
    subplot(1,T+1,count);
    plot(squeeze(mean(accr(:,:,n_t+1))))
end

%=========================================================================%