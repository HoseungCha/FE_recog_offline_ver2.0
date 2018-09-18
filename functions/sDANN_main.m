% 20161221
% sDANN: Shallow Domain-Adversarial Training of Neural Networks (toy
% example)
% written by BISPL, KAIST, Jaejun Yoo
% e-mail: jaejun2004@gmail.com
% reference : https://arxiv.org/pdf/1505.07818v4.pdf

function Y_adapt = sDANN_main(X,Y,X_adapt,varargin)
% define defaults
opt = struct(...
    'lernRate',0.05,...
    'hidden_layer_size',25,...
    'lambda_adapt','6',...
    'maxiter',800,...
    'adversarial_representation',true,...
    'seed',1);

% set argument
opt = chaSetArgument(opt,varargin);

nb_labels = length(unique(Y));

[W,V,b,c] = sDANN(X, Y, X_adapt, opt.lernRate, opt.hidden_layer_size,...
    opt.maxiter, opt.lambda_adapt, opt.adversarial_representation, opt.seed);

Y_adapt = predict(X_adapt,W,V,b,c);

end

function y = sigmoid(z)
y = 1./(1+exp(-1*z));
end
function y = softmax(z)
y = exp(z)./repmat(sum(exp(z)),size(z,1),1);
end
function output_layer=forward(X,W,V,b,c)
    hidden_layer = sigmoid(W*X'+ repmat(b,1,length(X))); % dim: 15 by 200
    output_layer = softmax(V*hidden_layer + repmat(c,1,length(X))); % dim: 2 by 200
end
function result = predict(X,W,V,b,c)
    output_layer = forward(X,W,V,b,c);
    [~, result] = max(output_layer,[],1); % dim: 1 by 200
end
