function [B1, B2, t1, t2] = ITQ (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  [W, ~] = eigs(cov(X1), codeLength);
  X1 = X1 * W;
  R = ITQCore(X1, method.numIter);
  X1 = X1 * R;
  B1 = X1 > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = X2 * W * R > 0;
  t2 = toc(timerTest) / N2;

end
