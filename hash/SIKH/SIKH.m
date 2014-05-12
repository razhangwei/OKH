function [B1, B2, t1, t2] = SIKH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  RFparam.gamma = 1;
  RFparam.D = size(X1, 2);
  RFparam.M = codeLength;
  RFparam = RF_train(RFparam);
  B1 = RF_compress(X1, RFparam) > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  B2 = RF_compress(X2, RFparam) > 0;
  t2 = toc(timerTest) / N2;

end
