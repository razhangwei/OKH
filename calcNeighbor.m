% calculate a logic matrix indicating whether a pair of items are neighbors.
function R = calcNeighbor (dataset, idx1, idx2)

  if ~exist('idx2', 'var')
    idx2 = idx1;
  end

  switch dataset.neighborType

    case 'dist'
      N1 = length(idx1);
      N2 = length(idx2);
      R = false(N1, N2);
      T = getConst('MEMORY_CAP');
      m = floor(T / (8 * N1));
      p = 1;
      while p <= N2
        t = min(p + m - 1, N2);
        P1 = dataset.X(idx1, :);
        P2p = dataset.X(idx2(p: t), :);
        Dsp = calcEuDist(P1, P2p);
        R(:, p: t) = Dsp <= dataset.neighborThreshold;
        p = p + m;
      end

    case 'affinity'
      Af = dataset.affinity(idx1, idx2);
      R = Af >= dataset.neighborThreshold;
      R = full(R);

    case 'value'
      N1 = length(idx1);
      N2 = length(idx2);
      V = dataset.value;
      Af = -abs(repmat(V(idx1), 1, N2) - repmat(V(idx2)', N1, 1));
      R = Af >= dataset.neighborThreshold;

    case 'label'
      N1 = length(idx1);
      N2 = length(idx2);
      R = false(N1, N2);
      T = getConst('MEMORY_CAP');
      m = floor(T / (8 * N1));
      p = 1;
      while p <= N2
        t = min(p + m - 1, N2);
        L1 = dataset.label(idx1);
        L2p = dataset.label(idx2(p: t));
        Dp = repmat(L1, 1, length(L2p)) - repmat(L2p', length(L1), 1);
        R(:, p: t) = Dp == 0;
        p = p + m;
      end

    case 'tag'
      T1 = dataset.tag(idx1, :);
      T2 = dataset.tag(idx2, :);
      T = T1 * T2';
      R = T > 0;

  end

end
