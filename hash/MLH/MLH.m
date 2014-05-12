% A MLH wrapper for preparing appropriate data for the core implementation
% Input:
%   dataset: a structure containing dataset info
%   method: a structure containing method info
%   codeLength: length of the binary codes
% Output:
%   B1: binary encoding of the trainning data
%   B2: binary encoding of the testing data
%   t1: training time
%   t2: testing time
function [B1, B2, t1, t2] = MLH (task, dataset, method, codeLength)

  timerTrain = tic;

  if isfield(method, 'dimPCA')
    dataset.X = do_pca(dataset.X, method.dimPCA);
  end

  N1 = length(dataset.indexTrain);
  X1 = dataset.X(dataset.indexTrain, :);
  N2 = length(dataset.indexTest);
  X2 = dataset.X(dataset.indexTest, :);
  N3 = length(dataset.indexValidation);
  X3 = dataset.X(dataset.indexValidation, :);
  S3 = dataset.neighborValidation;

  indexSample = randperm(N1, min(method.numSample, N1));
  data.Ntraining = length(indexSample);
  data.Xtraining = X1(indexSample, :)';
  data.Straining = calcNeighbor(dataset, dataset.indexTrain(indexSample));

  data.Ntest = N3;
  data.Xtest = X3';
  data.StestTraining = S3(:, indexSample);

  W = MLHCore(data, codeLength, method.valIteration, method.trainIteration, method.epochSize);

  B1 = (W * [X1'; ones(1, N1)] > 0)';
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = (W * [X2'; ones(1, N2)] > 0)';
  t2 = toc(timerTest) / N2;

end
