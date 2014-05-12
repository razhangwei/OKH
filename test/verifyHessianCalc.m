function verifyHessianCalc (T, N, Q)

  E = zeros(T, N);
  for t = 1: T
    U = rand(N, Q) - 0.5;
    A = rand(N, N);
    for i = 1: N
      H1 = calc1(i, U, A);
      H2 = calc2(i, U, A);
      E(t, i) = mean(mean((H1 - H2) .^ 2));
    end
  end
  fprintf('average error: %.4g\n', mean(mean(E)));

end

function H = calc1 (i, U, A)

  [N, Q] = size(U);
  H = zeros(Q);
  for j = [1: i - 1, i + 1: N]
    H = H + (A(i, j) * (1 - A(i, j))) * (U(j, :)' * U(j, :));
  end

end

function H = calc2 (i, U, A)

  [N, Q] = size(U);
  j = [1: i - 1, i + 1: N];
  H = U(j, :)' * diag(A(i, j) .* (1 - A(i, j))) * U(j, :);

end
