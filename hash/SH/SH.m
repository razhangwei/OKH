function [B1, B2, t1, t2] = SH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  SHparam.nbits = codeLength;
  SHparam = trainSH(X1, SHparam);
  B1 = compressSH(X1, SHparam) > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = compressSH(X2, SHparam) > 0;
  t2 = toc(timerTest) / N2;

end
