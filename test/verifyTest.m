function verifyTest (N)

  X = rand(N, 1);
  eps = 1e-6;

  G = calcG(X);
  G2 = zeros(size(G));
  L = calcL(X);
  for i = 1: N
    X(i) = X(i) + eps;
    L2 = calcL(X);
    G2(i) = (L2 - L) / eps;
    X(i) = X(i) - eps;
  end

  EG = mean((G2 - G) .^ 2);
  fprintf('mean error: %.4g\n', EG);

end

function L = calcL (X)

  L = sum(sin(X));

end

function G = calcG (X)

  G = cos(X);

end
