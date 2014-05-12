function [B1, B2, t1, t2] = SPLH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N1 = length(dataset.indexTrain);
  N2 = length(dataset.indexTest);

  L = min(method.numSample, N1);
  indexSample = randperm(N1, L);
  Xv = X1(indexSample, :);
  Re = calcNeighbor(dataset, dataset.indexTrain(indexSample));
  S = -ones(L);
  S(Re) = 1;
  S(logical(eye(L))) = 0;

  timerTrain = tic;
  SPLHparam.nbits = codeLength;
  SPLHparam.eta = method.eta;
  SPLHparam = trainSPLH(X1, SPLHparam, Xv', S);
  [~, B1] = compressSPLH(X1, SPLHparam);
  t1 = toc(timerTrain);

  timerTest = tic;
  [~, B2] = compressSPLH(X2, SPLHparam);
  t2 = toc(timerTest) / N2;

end
