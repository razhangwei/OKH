function [B1, B2, t1, t2] = PCAH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  [W, ~] = eigs(cov(X1), codeLength);
  B1 = X1 * W > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = X2 * W > 0;
  t2 = toc(timerTest) / N2;

end
