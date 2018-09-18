% clear; clc
function model = ds_gplvm_main(data_in,labels_full,train_ind,test_ind)

%% Load data
% load view1;
% % load labels1;
% tmp_model = myPCA(view1, .95);
% data_in{1} = tmp_model.params;
% labels_full{1} = labels1;
% load view2;
% load labels2;
% tmp_model = myPCA(view2, .95);
% data_in{2} = tmp_model.params;
% labels_full{2} = labels2;

%% Specify indices for training, validation, test (leave validation and test empty for training mode only)

% train_ind = 1:470;
% val_ind = 500:1000;
% test_ind = 1050:1531;

for i = 1:numel(data_in)
    test_ind2{i} = test_ind;
end

ind = {train_ind, test_ind2};
if isempty(ind{2})
    validation = 0;
else
    validation = 1;
end

%% Select Covariance function and initialize parameters for GPs
covfunc = {@covSum_mod, {@covSEiso_mod, @covConst_mod, @covNoise_mod}};
likfunc = @likGauss;

hyp.cov = log([1; 1; sqrt(.1); sqrt(.1)]);
hyp.lik = log(sqrt(.1));


%% Create model

model.prior = 50;                   % efect of the prior
model.prior_type = 'lpp';           % possible options lpp, lda

%%%% back projection settings. Only one can be active !!!!
model.bp = 0;                       % standard back projection defined by Lawrence and used in D-GPLVM
model.sbp = 0;                      % SBP setting of the DS-GPVLM
model.ibp = 1;                      % IBP setting of the DS-GPVLM

%%%% validation setting, and corresponding indices 
model.validation = validation;
model.ind = ind;

%%%%
model.X = [];                       % latent space
model.Laplacian = [];               % Laplacian matrix of the constrain
model.labels_full = labels_full;    % labels of the dataset

%%%% rho and max value for \mu parameters of the adm
model.rho = 1.1;
model.max_mu = 1e3;
model.T = 100;                      % No. of ADM cycles (default is 100)

%%%% parameters for the GP mappings
model.covfunc = covfunc;
model.likfunc = likfunc;
model.hyp = hyp;

%%%% OUTPUT of the model. If validation is not set, predictions only for
%%%% the train set are returned
model.out.ac_val = []; model.out.ac_test = []; model.out.ac_train = []; model.out.labels_val = []; model.out.labels_test = []; model.out.labels_train = [];

%%%% Do we want plots?
model.verbose = 1;

model = initialize_dsgplvm(data_in, model);

tic
model = ds_gplvm_adm(data_in, model);
toc
end