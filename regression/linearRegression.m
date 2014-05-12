function [predict, succ] = linearRegression (method, B1, B2, V1)

  N1 = size(B1, 1);
  N2 = size(B2, 1);

  lambda = N1 / size(B1, 2);
  W = learnW(double(B1), V1, lambda);
  predict = B2 * W;
  succ = true(N2, 1);

end

function W = learnW (X, U, lambda)
  W = (X' * X + lambda * eye(size(X, 2))) \ X' * U;
end
