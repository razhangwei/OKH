function [X1, X2, t1, t2] = OriginF (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  t1 = toc(timerTrain);

  timerTest = tic;
  t2 = toc(timerTest) / N2;

end
