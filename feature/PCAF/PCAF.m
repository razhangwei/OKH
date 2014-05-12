function [X1, X2, t1, t2] = PCAF (task, dataset, method, codeLength)

  X1 = dataset.X(dataset.indexTrain, :);
  X2 = dataset.X(dataset.indexTest, :);
  N2 = length(dataset.indexTest);

  timerTrain = tic;
  [X1, W] = PCA(X1, method.PCADim);
  t1 = toc(timerTrain);

  timerTest = tic;
  X2 = X2 * W;
  t2 = toc(timerTest) / N2;

end

% use PCA to reduce X to dimensionality of q.
function [B, W] = PCA (X, q)
  n = size(X, 1);
  Sigma = X' * X / n;
  [U, S, V] = svd(Sigma);
  W = U(:, 1: q);
  B = X * W;
end
