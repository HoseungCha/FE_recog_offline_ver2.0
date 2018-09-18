% this code was written by Hoseung Cha
% contact: hoseungcha@gmail.com
function mdlNew = adapLDAFromTest(mdl,mdlOld,xtr,ytr,xte,ypr,fe_seq,varargin)
% define defaults
opt = struct(...
    'nClass',11,...
    'nWin',50,...
    'method','supervised',...
    'alpha',0.5,...
    'beta',0,...
    'nOrgWin',60);

% set argument
opt = chaSetArgument(opt,varargin);

if strcmp(opt.method,'supervised')
    % get DB from test session
    % Supervised
    yte = get_target(fe_seq,length(xte),0,opt.nWin,opt.nOrgWin);
    xtr_new = xte(~isnan(yte),:);
    ytr_new = get_labels(opt.nWin,fe_seq(:,1)', 1);
    
    % Step2: fit new LDA
    mdlNew = fitLDA('X',xtr_new,'Y', ytr_new);
    
    % Sep3: adaption LDA with old LDA
    mdlNew = adapLDA(mdlOld,mdlNew,opt.alpha,opt.beta);
    
elseif strcmp(opt.method,'unsupervised')
    % temporarily
    idYtr = get_target(fe_seq,length(xte),0,opt.nWin,opt.nOrgWin);
    
%     yte = get_target(fe_seq,length(xte),0,opt.nWin,opt.nOrgWin);
%     xtr_new = xte(idYtr,:);
%     ytr_new = get_labels(opt.nWin,fe_seq(:,1)', 1);
    
    % Assumed by prediction results (unsupervised)
%     [idx_Xt_new,idUpdate] = getIdxXnew(fe_seq(:,1)',opt.nWin,ypr,idYtr);
    [idx_Xt_new,idUpdate] = getIdxXnewV2(fe_seq(:,1)',opt.nWin,ypr);
    if idUpdate == false % 어떤 클래스는 분류가 안되었을 경우.. 이전 모델 사용
        mdlNew = mdl;
        return;
    end
    xtr_new = xte(idx_Xt_new(:),:);
    ytr_new = get_labels(size(idx_Xt_new,1),fe_seq(:,1)', 1);
     
    % Step2: fit new LDA
    mdlNew = fitLDA('X',xtr_new,'Y', ytr_new);
    % Sep3: adaption LDA with old LDA
    mdlNew = adapLDA(mdlOld,mdlNew,opt.alpha,opt.beta);
    
    %     mdl_unsv{curSess} = fitcdiscr(xtr2,ytr2);
elseif strcmp(opt.method,'DANN')
    % Assumed by prediction results (unsupervised)
%     [idx_Xt_new,idUpdate] = getIdxXnew(fe_seq(:,1)',opt.nWin,ypr);
%     if idUpdate == false % 어떤 클래스는 분류가 안되었을 경우.. 이전 모델 사용
%         mdlNew = mdl;
%         return;
%     end
%     xtr = xte(idx_Xt_new(:),:);
%     ytr = get_labels(size(idx_Xt_new,1),fe_seq(:,1)', 1);
    
    ypr = sDANN_main(xtr, ytr, xte(40:end,:));

    % Step2: fit new LDA
    mdlNew = fitLDA('X',xtr,'Y', ytr);
    % Sep3: adaption LDA with old LDA
    mdlNew = adapLDA(mdlOld,mdlNew,opt.alpha,opt.beta);
end


end