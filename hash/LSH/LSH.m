function [B1, B2, t1, t2] = LSH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  W = randn(size(dataset.X, 2), codeLength);
  B1 = X1 * W > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = X2 * W > 0;
  t2 = toc(timerTest) / N2;

end
