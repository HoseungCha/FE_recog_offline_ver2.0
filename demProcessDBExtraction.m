%-------------------------------------------------------------------------%
% This code is how extracted DB with changing hyperparameters
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
clc; close all; clear;

% addpath
addpath(genpath('E:\OneDrive\연구지식\Remanian classification\covariancetoolbox-master\covariancetoolbox-master\'));
addpath(fullfile(cd,'functions'));

% code analysis
code = reportCodeExecution();

% set hyperparameter
winsizeList = 0.05:0.01:0.5;
% get proccess DB
for iEMGpair = 1 :3
for i = 1 : length(winsizeList)
folderName = ['win_',num2str(winsizeList(i)),...
            '_emgPair_',num2str(iEMGpair)];

pathSaveDB = getProcessDB(...
    'pathDB',fullfile(cd,'DB','DB_raw'),...
    'pathOut',fullfile(cd,'DB','DB_proc'),...
    'idBipolarConfigure',true,...
    'idWinExtraction',false,...
    'winSize',winsizeList(i),...
    'saveFolderName',folderName,...
    'emgPair',iEMGpair...
);
end
end