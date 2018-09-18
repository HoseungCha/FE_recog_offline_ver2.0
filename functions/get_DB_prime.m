%----------------------------------------------------------------------
% DB which you want to transfomr
% DB_c which you will use as reference DB
% DB_t: transfored DB
% T: number of transformation
% N1: number of window segments
% M: number of class
% F: number of feature type
% K: number of total features
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------

function xt = get_DB_prime(x,xc,varargin);

% define defaults
opt = struct('f_list',{{[1,2,3,4];[5,6,7,8];[9,10,11,12];13:28}},...
    'T',1,...
    'T_method','Seg_FE',...
    'R',100,...
    'nUpSample',10,...
    'id_plot',false,...
    'fhandle',str2func('transWithDPW'),...
    'dtw_opt',struct('max_slope_length',3,'speedup_mode',1));

% set argument
opt = chaSetArgument(opt,varargin);

% memory allocation similarily transformed feature set
[N1, K ,M] = size(x);
F = length(opt.f_list);

xt = zeros([size(x),opt.T]);
for m = 1 : M
    
    % you should get access to DB of other experiment with each
    for f = 1 : F
%         for ff = 1 : length(opt.f_list{f}) % perspective of time
        for i = 1 : N1 % perspective of feature type    
            
            % feat from this experiment
%             xtr_ref = DB(i,opt.f_list{f},m); % perspective of time
            xi = x(i,opt.f_list{f},m)'; % perspective of feature type
            
            %---------feat to be compared from this experiment----%
            % [n_seg:30, n_feat:28, n_fe:8, n_trl:20, n_sub:30, n_emg_pair:3]
            switch opt.T_method
                case 'all'
%                     x_db = DB_c(:,opt.f_list{f}(i),:,:,:);
                    x_db = xc(i,opt.f_list{f},:,:,:);
                    
                case 'Only_Seg'
%                     x_db = DB_c(:,opt.f_list{f}(i),:,:,:);
                    x_db = xc(i,opt.f_list{f},:,:,:);
                    
                case 'Seg_FE'
%                     x_db = DB_c(:,opt.f_list{f}(i) ,m,:,:);
                    x_db = xc(i,opt.f_list{f} ,m,:,:);
            end
            
            % to bring about formation of [n_seg, others]
            x_db = concat_leaving_dim(x_db,2)';
            
            % get similar features by determined number of
            % transformed DB
            temp = dtw_search_n_transf(xi, x_db, opt);
            
            
            
            for t = 1 : opt.T
                xt(i,opt.f_list{f},m,t) = temp(:,t);
            end
            %-----------------------------------------------------%
            
        end
    end
end
end