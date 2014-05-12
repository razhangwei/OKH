function [distH, orderH] = calcEuclideanRank (B1, B2)

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  distH = zeros(N2, N1);
  orderH = zeros(N2, N1, 'uint32');
  T = getConst('MEMORY_CAP');
  m = floor(T / (8 * N1));
  p = 1;
  while p <= N2
    t = min(p + m - 1, N2);
    distH(p: t, :) = calcEuDist(B2(p: t, :), B1);
    [~, orderH(p: t, :)] = sort(distH(p: t, :), 2);
    p = p + m;
  end

end
