function [UIter, LIter] = learnU (U0, S, Q, beta, maxIter, convergeThresh, binarize)

  % initialization
  N = size(S, 1);
  iND = find(~eye(N));

  U = U0;
  if binarize
    U(U >= 0) = 1;
    U(U < 0) = -1;
  end
  T = U * U' / 2;
  A = 1 ./ (1 + exp(-T));
  L = sum(S(iND) .* T(iND)) - sum(logExpTrick(T(iND))) - trace(T) / beta;

  UIter(:, :, 1) = U;
  LIter(1) = L;

  Lp = L;
  bU = L;
  bL = L;

  tid = tic;
  for iter = 1: maxIter

    % update U

    for i = 1: N
      idxS = [1: i - 1, i + 1: N];
      Gi = ((S(i, idxS) - A(i, idxS)) + (S(idxS, i) - A(idxS, i))') * U(idxS, :) / 2 - U(i, :) / beta;
      Hi = -U(idxS, :)' * U(idxS, :) / 8 - eye(Q) / beta;
      U(i, :) = U(i, :) - Gi / Hi;
      if binarize
        U(i, find(U(i, :) >= 0)) = 1;
        U(i, find(U(i, :) < 0)) = -1;
      end
      T(i, :) = U(i, :) * U' / 2;
      T(:, i) = T(i, :)';
      A(i, :) = 1 ./ (1 + exp(-T(i, :)));
      A(:, i) = A(i, :)';
    end

    % compute objective
    L = sum(S(iND) .* T(iND)) - sum(logExpTrick(T(iND))) - trace(T) / beta;

    % record converge process
    UIter(:, :, iter + 1) = U;
    LIter(iter + 1) = L;

    % check for convergence
    bU = max(bU, L);
    bL = min(bL, L);
    if abs(L - Lp) / (bU - bL) < convergeThresh
      break;
    end
    Lp = L;

  end
  fprintf('  Number of iterations: %d\n', iter);
  fprintf('  Average time per iteration: %.4gs\n', toc(tid) / iter);

end
