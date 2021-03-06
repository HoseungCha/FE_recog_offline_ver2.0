%-------------------------------------------------------------------------%
% This Code is about adaption with user's data with classfier which is
% constructed by other database using Riemannian Adaption
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

% get proccess DB
% pathSaveDB = getProcessDB(...
%     'pathDB',fullfile(cd,'DB','DB_raw'),...
%     'pathOut',fullfile(cd,'DB','DB_proc'),...
%     'idBipolarConfigure',false,...
%     'saveFolderName','demRiemannian',...
%     'idSaveDB', true,...
%     'idFeatExtraction',false);


% 피험자 2명으로 테스트!
pathDB = 'D:\research\EMG_FE_recog_offline\DB\DB_proc\DB_raw_demRiemannian';
load(fullfile(pathDB,'ParameterOption'));

% [E,T] = size(winSeg{1});
a=1;
M = 11;
idxSegment = 21:60;
update = 1;
idxTrainUser = 1; 
idxTrainSession = 1:20;
% idxTestUser = 34;
idxTestUserList = 2:42;
idxTestSession = 2:20;
idxCaliSession = 1;

% load(fullfile(pathDB,'ParameterOption'));
acc = zeros(11,11,41);
acc_cali = zeros(11,11,41);
acc_train = zeros(11,11,41);

c = 0;
for idxTestUser= idxTestUserList
c = c + 1;
%========== Prepare training data ============%
% Read File
fileName = sprintf('winSeg-sub-%02d',idxTrainUser);
load(fullfile(pathDB,fileName));

% Compute Covariances
xTrainCov = getCovFromWinSeg(...
    winSeg(idxSegment,:,idxTrainSession));

% Tangent space mapping
method_mean = 'riemann';
CTrain = mean_covariances(xTrainCov,method_mean);

STrain = Tangent_space(xTrainCov,CTrain)';
yTrain = get_labels(length(idxSegment),M,...
    length(idxTrainSession)*length(idxTrainUser));

% LDA training of Expert User
mdlExpertUser = fitLDA('X',STrain,'Y',yTrain);
%==============================================%

%========== Prepare Calibratoin Session ============%
if update == 1
    % Read Calibration/Test File
    fileName = sprintf('winSeg-sub-%02d',idxTestUser);
    load(fullfile(pathDB,fileName));

    % Compute Covariances
    xCaliCov = getCovFromWinSeg(...
    winSeg(idxSegment,:,idxCaliSession));

    % Tangent space mapping
    CAdap = mean_covariances(xCaliCov,method_mean);
end
SCali= Tangent_space(xCaliCov,CAdap)';
yCali = get_labels(length(idxSegment),M,...
    length(idxCaliSession)*length(idxTestUser));

% LDA training of calibration
mdlCali = fitLDA('X',SCali,'Y',yCali);
%==============================================%

%========== Prepare Test Session ============%
% Compute Covariances
xTestCov = getCovFromWinSeg(...
    winSeg(idxSegment,:,idxTestSession));

% Tangent space mapping
STest= Tangent_space(xTestCov,CAdap)';
yTest = get_labels(length(idxSegment),M,...
    length(idxTestSession)*length(idxTestUser));

% 자신과 다른사람의 모델을 적절히 adaption한 결과
alphaList = 0:0.1:1;
betaList = 0:0.1:1;
c_a = 0;
for alpha = alphaList
c_a = c_a + 1;
c_b = 0;
for beta = betaList
c_b = c_b + 1;

    mdlNew = adapLDA(mdlExpertUser,mdlCali,alpha,beta);
    yPd = predLDA(mdlNew,STest);
    acc(c_a,c_b,c) = length(find(yTest==yPd))/length(yTest);
    
%     yPdCali = predLDA(mdlNew,SCali);
%     acc_cali(c_a,c_b,c)  = length(find(yCali==yPdCali))/length(yCali);
%     
%     yPdTrain= predLDA(mdlNew,STrain);
%     acc_train(c_a,c_b,c)  = length(find(yTrain==yPdTrain))/length(yTrain);
    
end
end
end

% 결과 정리 
[accSubject, meanAcc] = reportAccWithSubject(acc);



