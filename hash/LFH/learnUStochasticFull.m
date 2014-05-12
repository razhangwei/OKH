function [Ubest, MAPIter, LIter] = learnUStochasticFull (U0, S, calcS, beta, beta2, batchSize, maxIter, convergeThresh, calcMAP)

  % initialization
  [N, Q] = size(U0);
  iND = find(~eye(N));

  U = U0;
  T = U * U' / 2;
  L = sum(S(iND) .* T(iND)) - sum(logExpTrick(T(iND))) - trace(T) / beta2;

  MAP = calcMAP(U);
  MAPIter(1) = MAP;
  maxMAP = MAP;
  iterBest = 1;
  Ubest = U;
  LIter(1) = L;

  Lp = L; bU = L; bL = L;

  p1 = timerStart();
  for iter = 1: maxIter

    Ss = sampleIdx(N, batchSize);
    [Si, Sj] = ind2sub([N, N], Ss);
    vS = calcS(Si, Sj);
    vT = calcVT(U, Si, Sj);
    vA = 1 ./ (1 + exp(-vT));

    ISi = findIndex(Si, N);
    ISj = findIndex(Sj, N);

    % update U
    for i = 1: N
      j1s = ISi{i}; j1 = Sj(j1s); j2s = ISj{i}; j2 = Si(j2s);
      if ~isempty(j1s) && ~isempty(j2s)
        Gi = (vS(j1s) - vA(j1s))' * U(j1, :) / 2 + (vS(j2s) - vA(j2s))' * U(j2, :) / 2 - U(i, :) / beta;
        Hi = - U(j1, :)' * U(j1, :) / 16 - U(j2, :)' * U(j2, :) / 16 - eye(Q) / beta;
        U(i, :) = U(i, :) - Gi / Hi;
        js = [j1s; j2s];
        vT(js) = sum(U(Si(js), :) .* U(Sj(js), :), 2) / 2;
        vA(js) = 1 ./ (1 + exp(-vT(js)));
      end
    end

    % compute objective
    T = U * U' / 2;
    L = sum(S(iND) .* T(iND)) - sum(logExpTrick(T(iND))) - trace(T) / beta2;

    % record converge process
    MAP = calcMAP(U);
    MAPIter(iter + 1) = MAP;
    if MAP > maxMAP
      maxMAP = MAP;
      iterBest = iter + 1;
      Ubest = U;
    end
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
  t1 = timerStop(p1);
  fprintf('  Average time per iteration: %.4gs\n', t1.etime / iter);
  fprintf('  Best iteration found at %d with MAP %.4g\n', iterBest - 1, maxMAP);

end

function vT = calcVT (U, Si, Sj)

  [N, Q] = size(U);
  vT = zeros(length(Si), 1);
  T = getConst('MEMORY_CAP');
  m = floor(T / (8 * Q));
  p = 1;
  while p <= N
    t = min(p + m - 1, N);
    vT(p: t) = sum(U(Si(p: t), :) .* U(Sj(p: t), :), 2) / 2;
    p = p + m;
  end

end

% randomly sample S entries from an NxN matrix
function idx = sampleIdx (N, S)

  p = [1: S];
  idx = zeros(S, 1);
  while ~isempty(p)
    idx(p) = randi(N * N, length(p), 1);
    [x, y] = ind2sub([N, N], idx(p));
    p = p(find(x == y));
  end

end

% a fast implementation to find all the positions in v for each value from 1 to N
function idx = findIndex (v, N)

  idx = cell(length(v), 1);
  [sv, is] = sort(v);
  [cv, ia, ~] = unique(sv, 'first');
  for i = 1: length(cv)
    a = ia(i);
    if i < length(cv)
      b = ia(i + 1) - 1;
    else
      b = length(sv);
    end
    idx{cv(i)} = is(a: b);
  end

end
