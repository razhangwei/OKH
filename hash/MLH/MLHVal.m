% Copyright (c) 2011, Mohammad Norouzi and David Fleet
% Performs validation on sets of parameters by calling appropriate instances of learnMLH function.
%
% Input:
%    data: data structure for training the model made by create_data.m
%    nb: number of bits
%    eta_set: choices for learning rate
%    momentum: momentum parameter for gradient descent (we always use .9)
%    size_batches_set: mini-batch size for gradient descent (we always use 100)
%    trainset: can be either 'train' or 'trainval'. Using 'train' splits the training set into train
%      and validation sets. Using 'trainval' performs training on the complete training set.
%    maxiter: number of iterations
%    zerobias_set: either 0 or 1, meaning whether the hashing hyper-planes' biases should be all
%      zero or should be learned. Both possibilities can be provided for validation.
%    nval_after: how many validation after training (to account for validation noise)
%
% Output:
%    A structure array storing sets of weight matrices (W), parameters (params), average precision
%      (ap), etc. learned by MLH

function [Wset] = MLHVal (data, rho_set, lambda_set, nb, eta_set, momentum, epochSize, size_batches_set, trainset, maxiter, zerobias_set, nval_after, shrink_w_set, shrink_eta)

  % LSH
  initW = [0.1 * randn(nb, size(data.Xtraining, 1)) zeros(nb, 1)];

  % generate parameter set
  paramSet = enumParamCross(size_batches_set', eta_set');
  paramSet = enumParamCross(paramSet, shrink_w_set');
  paramSet = enumParamCross(paramSet, rho_set');
  paramSet = enumParamCross(paramSet, lambda_set');
  paramSet = enumParamCross(paramSet, zerobias_set');

  % run MLH on each parameter setting
  for i = 1: size(paramSet, 1)
    param = struct();
    param.size_batches = paramSet(i, 1);
    param.eta = paramSet(i, 2);
    param.shrink_w = paramSet(i, 3);
    param.rho = paramSet(i, 4);
    param.lambda = paramSet(i, 5);
    param.zerobias = paramSet(i, 6);
    param.nb = nb;
    param.maxiter = maxiter;
    param.momentum = momentum;
    param.trainset = trainset;
    param.nval_after = nval_after;
    param.shrink_eta = shrink_eta;
    param.epochSize = epochSize;

    [ap W params] = learnMLH(data, param, initW);

    Wset(i).ap = ap;
    Wset(i).W = W;
    Wset(i).params = params;
  end

end
