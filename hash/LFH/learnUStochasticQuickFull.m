function [Ubest, MAPIter, LIter] = learnUStochasticQuickFull (U0, SF, calcS, beta, beta2, sampleColumn, maxIter, convergeThresh, windowSize, calcMAP)

  % initialization
  [N, Q] = size(U0);
  iND = find(~eye(N));

  U = U0;
  TF = U * U' / 2;
  L = sum(SF(iND) .* TF(iND)) - sum(logExpTrick(TF(iND))) - trace(TF) / beta2;

  MAP = calcMAP(U);
  MAPIter(1) = MAP;
  maxMAP = MAP;
  iterBest = 1;
  Ubest = U;
  LIter(1) = L;

  canConverge = false;

  p1 = timerStart();
  for iter = 2: maxIter + 1

    % sample a subset of columns
    Sc = randperm(N, sampleColumn);

    % update rows of U not in Sc
    S = calcS(Sc);
    T = U * U(Sc, :)' / 2;
    A = 1 ./ (1 + exp(-T));
    ix = setdiff(1: N, Sc);
    G = (S(ix, :) - A(ix, :)) * U(Sc, :) - U(ix, :) / beta; % NQ^2
    H = - U(Sc, :)' * U(Sc, :) / 8 - eye(Q) / beta;
    U(ix, :) = U(ix, :) - G / H;

    % update rows of U in Sc
    S = S';
    T = U(Sc, :) * U' / 2; % NQ^2
    A = 1 ./ (1 + exp(-T)); % NQ^2
    H = - U' * U / 8 - eye(Q) / beta; % NQ^2
    for i = 1: length(Sc) % Q
      ix = Sc(i);
      j = setdiff(1: N, ix); % N
      Gi = (S(i, j) - A(i, j)) * U(j, :) - U(ix, :) / beta; % NQ
      Hi = H + U(ix, :)' * U(ix, :) / 8; % Q^2
      Uit = U(ix, :);
      U(ix, :) = U(ix, :) - Gi / Hi; % Q^3
      T(:, ix) = U(Sc, :) * U(ix, :)' / 2; % Q^2
      A(:, ix) = 1 ./ (1 + exp(-T(:, ix))); % Q^2
      H = H + (Uit' * Uit - U(ix, :)' * U(ix, :)) / 8; % Q^2
    end

    % compute objective
    TF = U * U' / 2;
    L = sum(SF(iND) .* TF(iND)) - sum(logExpTrick(TF(iND))) - trace(TF) / beta2;

    % record converge process
    MAP = calcMAP(U);
    MAPIter(iter) = MAP;
    if MAP > maxMAP
      maxMAP = MAP;
      iterBest = iter;
      Ubest = U;
    end
    LIter(iter) = L;

    % check for convergence
    if iter >= windowSize
      MAPWindow = MAPIter(iter - windowSize + 1: iter);
      MAPDiff = max(MAPWindow) - min(MAPWindow);
      if MAPDiff >= convergeThresh
        canConverge = true;
      else
        if canConverge
          break;
        end
      end
    end

  end
  iter = iter - 1;
  fprintf('  Number of iterations: %d\n', iter);
  t1 = timerStop(p1);
  fprintf('  Average time per iteration: %.4gs\n', t1.etime / iter);
  fprintf('  Best iteration found at %d with MAP %.4g\n', iterBest - 1, maxMAP);

end
