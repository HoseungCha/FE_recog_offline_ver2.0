%--------------------------------------------------------------------------
% feat extracion code for faicial unit recognition using Myo Expression DB
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear all; close all;

%------------------------code analysis parameter--------------------------%
% decide the raw DB to analyse
name_DB_raw = 'MyoExp';

% decide number of segments in 3-sec long EMG data
t_wininc = 0.1; % s
t_winsize = 0.1;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
path.DB_raw = fullfile(cd,'DB','DB_raw');
path.DB_proc = fullfile(cd,'DB','DB_proc');
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
% trigger singals corresponding to each facial expression(emotion)
name_trg = {"ȭ��",1;"��ݴϱ�����",2;"�����(����)",3;"�����(������)",4;...
    "�� ���� ����",5;"�η���",6;"�ູ",7;"Ű��",8;"��ǥ��",9;"����",10;"���",11};

name_fe = name_trg(:,1);
idx_trg = cell2mat(name_trg(:,2));
clear Name_Trg;
n_fe = length(name_fe);% Number of facial expression
n_trl = 20; % Number of Trials
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%
% filter parameters
fp.SF2use = 2048;
fp.filter_order = 4; fp.Fn = fp.SF2use/2;
fp.freq_notch = [58 62];
fp.freq_BPF = [20 450];
[fp.nb,fp.na] = butter(fp.filter_order,fp.freq_notch/fp.Fn,'stop');
[fp.bb,fp.ba] = butter(fp.filter_order,fp.freq_BPF/fp.Fn,'bandpass');

% read file path of subjects
[name_sub,path_sub] = read_names_of_file_in_folder(path.DB_raw);
n_sub= length(name_sub);

% experiments or feat extractions parameters
n_feat = 28;
n_emg_pair = 3;
n_ch = 4;
idx_pair_right = [1,2;1,3;2,3]; %% ������ ���� ����
idx_pair_left = [10,9;10,8;9,8]; %% ���� ���� ����
period_FE = 5; % 3-sec
period_post_FE = 0;
n_seg = (period_FE+period_post_FE)/t_wininc; % choose 30 or 60
n_wininc = floor(t_wininc*fp.SF2use); 
n_winsize = floor(t_winsize*fp.SF2use); % win

% subplot �׸� �� ���� �׷��ִ� �Լ�
id_subplot_make_it_tight = true; subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~id_subplot_make_it_tight,  clear subplot;  end
%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
name_folder4saving = sprintf(...
'%s_n_sub_%d_n_seg_%d_n_wininc_%d_winsize_%d',...
    name_DB_raw,n_sub,n_seg,n_wininc,n_winsize);
path_save = make_path_n_retrun_the_path(fullfile(path.DB_proc),...
    name_folder4saving);
%-------------------------------------------------------------------------%


% memory alloation
feat_seg = NaN(n_seg,n_feat,n_fe,n_trl,n_sub);
feat_seq = cell(n_trl,n_sub);
idx_fe_seq = cell(n_trl,n_sub);
for i_emg_pair = 1 : n_emg_pair
for i_sub= 1 : n_sub
    % read BDF
    try
    [~,path_file] = read_names_of_file_in_folder(path_sub{i_sub},'*bdf');
    catch ex
    if strcmp(ex.identifier,'MATLAB:unassignedOutputs')
    [name_file,path_file] = read_names_of_file_in_folder(fullfile(...
        path_sub{i_sub},'emg'),'*bdf');  
    end
    end
    n_trl_curr = length(path_file);
    % for saving feature Set (processed DB)
    for i_trl = 1 : n_trl
        if n_trl_curr<i_trl
           continue; 
        end    
        fprintf('i_emg_pair-%d i_sub-%d i-trl-%d\n',i_emg_pair,i_sub,i_trl);
        
        % get bdf file
        out = pop_biosig(path_file{i_trl});
        
        % load trigger
        tmp_trg = cell2mat(permute(struct2cell(out.event),[1 3 2]))';
        
        % check which DB type you are working on
        % total number of trigger 33: Myoexpression1 ����
        % total number of trigger 23: Myoexpression2 ����
        
        switch length(tmp_trg)
            case 33
                [lat_trg,idx_seq_FE] = get_trg_myoexp1(tmp_trg);
            case 23
                [lat_trg,idx_seq_FE] = get_trg_myoexp2(tmp_trg);
            case 24 % which happens of subject 10 and trial 10
            otherwise
                keyboard;
                error('unexpected triggers from E-prime');
                continue; 
        end
       
        % get raw data and bipolar configuration
%         raw_data = double(OUT.data'); % raw data
%         temp_chan = cell(1,6);
        % get raw data and bipolar configuration        
        data_bip.RZ= out.data(idx_pair_right(i_emg_pair,1),:) - out.data(idx_pair_right(i_emg_pair,2),:);%Right_Zygomaticus
        data_bip.RF= out.data(4,:) - out.data(5,:); %Right_Frontalis
        data_bip.LF= out.data(6,:) - out.data(7,:); %Left_Corrugator
        data_bip.LZ= out.data(idx_pair_left(i_emg_pair,1),:) - out.data(idx_pair_left(i_emg_pair,2),:); %Left_Zygomaticus
        data_bip = double(cell2mat(struct2cell(data_bip)))';
        clear out;
        % Filtering
        data_filtered = filter(fp.nb, fp.na, data_bip,[],1);
        data_filtered = filter(fp.bb, fp.ba, data_filtered, [],1);
        clear data_bip;
        % for plot
%         figure;plot(filtered_data)
        % Feat extration with windows 
        
%         wininc = floor(0.05*SF2use); 
        n_win = floor((length(data_filtered) - n_winsize)/n_wininc)+1;
        temp_feat = zeros(n_win,n_feat); idx_trg_as_window = zeros(n_win,1);
        st = 1;
        en = n_winsize;
        for i = 1: n_win
            idx_trg_as_window(i) = en;
            curr_win = data_filtered(st:en,:);
            temp_rms = sqrt(mean(curr_win.^2));
            temp_CC = featCC(curr_win,n_ch);
            temp_WL = sum(abs(diff(curr_win,2)));
            temp_SampEN = SamplEN(curr_win,2);
%             temp_feat(i,:) = [temp_CC,temp_rms,temp_SampEN,temp_WL];
            temp_feat(i,:) = [temp_rms,temp_WL,temp_SampEN,temp_CC];
            % moving widnow
            st = st + n_wininc;
            en = en + n_wininc;                 
        end
        clear temp_rms temp_CC temp_WL temp_SampEN st en
        feat_seq{i_trl,i_sub}  = temp_feat;
 
        % cutting trigger 
        idx_trg_start = zeros(n_fe,1);
        for i_emo_orer_in_this_exp = 1 : n_fe
            idx_trg_start(i_emo_orer_in_this_exp,1) = find(idx_trg_as_window >= lat_trg(i_emo_orer_in_this_exp),1);
        end
        
        idx_fe_seq{i_trl,i_sub} = [idx_seq_FE,idx_trg_start];
        
        % To confirm the informaion of trrigers were collected right
%         hf =figure(i_sub);
%         hf.Position = [1921 41 1920 962];
%         subplot(n_trl,1,i_trl);
%         tmp_plot = temp_feat(1:end,1:4);
%         plot(tmp_plot)
%         v_min = min(min(tmp_plot(100:end,:)));
%         v_max = max(max(tmp_plot(100:end,:)));
%         hold on;
%         stem(idx_trg_start,repmat(v_min,[n_fe,1]),'k');
%         stem(idx_trg_start,repmat(v_max,[n_fe,1]),'k');
%         ylim([v_min v_max]);
%         drawnow;
        
       % Get Feature sets(preprocessed DB)
       % [n_seg,n_feat,n_fe,n_trl,n_sub,n_comb]
%         temp = [];
        for i_emo_orer_in_this_exp = 1 : n_fe
            if idx_trg_start(i_emo_orer_in_this_exp)+floor(((period_FE+period_post_FE)*fp.SF2use)/n_wininc)-1> length(temp_feat)
                feat_seg(1:length(temp_feat)-idx_trg_start(i_emo_orer_in_this_exp)+1,...
                    :,idx_seq_FE(i_emo_orer_in_this_exp),i_trl,i_sub) = ...
                        temp_feat(...
                        idx_trg_start(i_emo_orer_in_this_exp):...
                        end ,:);
            else
                    
            feat_seg(:,:,idx_seq_FE(i_emo_orer_in_this_exp),i_trl,i_sub) = ...
                        temp_feat(...
                        idx_trg_start(i_emo_orer_in_this_exp):...
                        idx_trg_start(i_emo_orer_in_this_exp)...
                        +floor(((period_FE+period_post_FE)*fp.SF2use)/n_wininc)-1 ,:);
            end                 
%             temp = [temp;temp_feat(idx_trg_start(i_emo_orer_in_this_exp):...
%                         idx_trg_start(i_emo_orer_in_this_exp)+floor((period_FE*fp.SF2use)/n_wininc)-1 ,:)];
        end 
        
    end  
    % plot the DB 
%     c = getframe(hf);
%     savefig(hf,fullfile(path_save,[name_sub{i_sub},'.fig']));
%     imwrite(c.cdata,fullfile(path_save,[name_sub{i_sub},'.png']));
%     close(hf);
end
    % ��� ����
    save(fullfile(path_save,['feat_seg_pair_',num2str(i_emg_pair)]),'feat_seg');
    save(fullfile(path_save,['feat_seq_pair_',num2str(i_emg_pair)]),'feat_seq');
    save(fullfile(path_save,['idx_fe_seq_pair_',num2str(i_emg_pair)]),'idx_fe_seq');
end




%==========================FUNCTIONS======================================%
function [lat_trg,idx_seq_FE] = get_trg_myoexp1(trg)
%Trigger latency �� FE ��
if ~isempty(find(trg(:,1)==16385, 1)) || ...
        ~isempty(find(trg(:,1)==16384, 1))
    trg(trg(:,1)==16384,:) = [];
    trg(trg(:,1)==16385,:) = [];
end

idx_seq_FE = trg(2:3:33,1);
lat_trg = trg(2:3:33,2);

% idx2use_fe = zeros(11,1);
% for i_fe = 1 : 11
%     tmp_fe = find(trg_cell(:,1)==i_fe);
%     idx2use_fe(i_fe) = tmp_fe(2);
% end
% [~,idx_seq_FE] = sort(idx2use_fe);
% lat_trg = trg_cell(idx2use_fe,2);
% lat_trg = lat_trg(idx_seq_FE);
end

function [lat_trg,idx_seq_FE] = get_trg_myoexp2(trg)
% get trigger latency when marker DB acquasition has started
lat_trg_onset = trg(1,2);

% check which triger is correspoing to each FE and get latency
tmp_emg_trg = trg(2:end,:);
Idx_trg_obtained = reshape(tmp_emg_trg(:,1),[2,size(tmp_emg_trg,1)/2])';
tmp_emg_trg = reshape(tmp_emg_trg(:,2),[2,size(tmp_emg_trg,1)/2])';
lat_trg = tmp_emg_trg(:,1);

% get sequnece of facial expression in this trial
[~,idx_in_order] = sortrows(Idx_trg_obtained);    
tmp_emg_trg = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
idx_seq_FE = tmp_emg_trg(:,2); 
end
