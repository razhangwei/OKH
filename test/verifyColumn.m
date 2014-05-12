function verifyColumn (N, Q)

  S = randi([0, 1], N, N);
  Z = randi([0, 1], N, N);
  U = rand(N, Q);
  beta = 1;
  eps = 1e-6;

  L = calcL(U, S, Z, beta);
  for i = 1: Q
    G = calcG(U, i, S, Z, beta);
    G2 = zeros(size(G));
    for k = 1: N
      U(k, i) = U(k, i) + eps;
      L2 = calcL(U, S, Z, beta);
      G2(k) = (L2 - L) / eps;
      U(k, i) = U(k, i) - eps;
    end
    EG(i) = mean((G2 - G) .^ 2);
  end
  fprintf('max error on G: %.4g\n', max(EG));

  for i = 1: Q
    G = calcG(U, i, S, Z, beta);
    H = calcH(U, i, S, Z, beta);
    H2 = zeros(size(H));
    for k = 1: N
      U(k, i) = U(k, i) + eps;
      G2 = calcG(U, i, S, Z, beta);
      H2(:, k) = (G2 - G) / eps;
      U(k, i) = U(k, i) - eps;
    end
    EH(i) = mean(mean((H2 - H) .^ 2));
  end
  fprintf('max error on H: %.4g\n', max(EH));

end

function L = calcL (U, S, Z, beta)

  T = U * U' / 2;
  L = sum(sum((S .* T - logExpTrick(T)) .* Z)) - sum(sum(U .^ 2)) / (2 * beta);

end

function G = calcG (U, i, S, Z, beta)

  Ui = U(:, i);
  T = U * U' / 2;
  A = 1 ./ (1 + exp(-T));
  G = ((S - A) .* Z) * Ui / 2 + ((S - A) .* Z)' * Ui / 2 - Ui / beta;

end

function H = calcH (U, i, S, Z, beta)

  Ui = U(:, i);
  T = U * U' / 2;
  A = 1 ./ (1 + exp(-T));
  H = - (A .* (1 - A) .* Z) .* (Ui * Ui') / 4 - (A .* (1 - A) .* Z)' .* (Ui * Ui') / 4 + (S - A) .* Z / 2 + ((S - A) .* Z)' / 2 - eye(size(S, 1)) / beta - diag((A .* (1 - A) .* Z) * (Ui .^ 2)) / 4 - diag((A .* (1 - A) .* Z)' * (Ui .^ 2)) / 4;

end

function Y = logExpTrick (X)
  Y = X;
  dx = find(X < 100);
  Y(dx) = log(1 + exp(X(dx)));
end
