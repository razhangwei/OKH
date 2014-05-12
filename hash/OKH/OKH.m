% A KSH wrapper for preparing appropriate data for the core implementation
% Input:
%   dataset: a structure containing dataset info
%   method: a structure containing method info
%   codeLength: length of the binary codes
% Output:
%   B1: binary encoding of the trainning data
%   B2: binary encoding of the testing data
%   t1: training time
%   t2: testing time
function [B1, B2, t1, t2, extra] = OKH (task, dataset, method, codeLength)
  if ~isfield(method, 'alpha')
    method.alpha = 0.2;
  end
  if ~isfield(method, 'C')
    method.C = 0.1;
  end
  if ~isfield(method, 'initMethod')
    method.initMethod = 'LSH';
  end
  if ~isfield(method, 'kernelNum')
    method.kernelNum = 300;
  end
  if ~isfield(method, 'MAPThres')
    method.MAPThres = 2000;
  end

  % feature mapping
  alpha = method.alpha;  
  C = method.C;
  N1 = length(dataset.indexTrain);
  indexAnchor = dataset.indexTrain(randperm(min(N1, method.kernelNum)) );  
  X = calcKernel(dataset.X, dataset.X(indexAnchor, :) );  
  X1 = X(dataset.indexTrain, :);
  X2 = X(dataset.indexTest, :);

  % initialize W
  [~, D] = size(X);
  R = codeLength;
  W = mvnrnd(zeros(R, D), eye(D) )';
  switch method.initMethod
    case 'LSH'
      W = mvnrnd(zeros(R, D), eye(D))';
    case 'identity'
      W = eye(D, R);
  end

  NoIter = [0];
  MAPIter = [0];
  timerTrain = tic;
  t3 = 0;
  for t = 1 : length(dataset.train_label)
    xi = X(dataset.train_pair(t, 1), :)';
    xj = X(dataset.train_pair(t, 2), :)';
    s = dataset.train_label(t);
    W = learnW(xi, xj, s, W, alpha, C);  

    % do the evaluation
    timerDebug = tic;
    if mod(t, task.MAPstep) == 0
      B1 = sign(X1 * W);
      B2 = sign(X2 * W);
      [~, orderH] = calcHammingRank(B1, B2);
      NoIter = [NoIter, t];
      MAPIter = [MAPIter, calcMAP(orderH, dataset.neighborTest)];
      fprintf('%d pairs are done. MAP = %0.4f\n', t, MAPIter(end) );
    end   
    t3 = t3 + toc(timerDebug);
  end
  B1 = sign(X1 * W);
  t1 = toc(timerTrain) - t3;

  timerTest = tic;
  B2 = sign(X2 * W);
  t2 = toc(timerTest);

  % cacheDir = sprintf('%s/MAPIter_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
  % save(cacheDir, 'NoIter', 'MAPIter', '-v7.3');
  % return some extra result
  extra.MAPIter = MAPIter;
  extra.NoIter = NoIter;
end

function h = sign(X)
  h = (X > 0) * 2 - 1;
end

