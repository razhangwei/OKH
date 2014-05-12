function [B1, B2, t1, t2] = AGH (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N1 = length(dataset.indexTrain);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  opts = statset('MaxIter', method.numIterKMeans);
  [~, anchor] = kmeans(X1, min(N1, method.numAnchor), 'Options', opts);
  [RX, W, sigma] = OneLayerAGH_Train(X1, anchor, codeLength, method.numNearAnchor, 0);
  B1 = RX > 0;
  t1 = toc(timerTrain);

  timerTest = tic;
  RtX = OneLayerAGH_Test(X2, anchor, W, method.numNearAnchor, sigma);
  B2 = RtX > 0;
  t2 = toc(timerTest) / N2;

end
