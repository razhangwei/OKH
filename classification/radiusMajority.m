function [predict, succ] = radiusMajority (method, B1, B2, L1)

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  distH = double(calcHammingRank(B1, B2));

  T = distH <= method.radius;
  S = sum(T, 2);
  succ = S > 0;
  LC = unique(L1);
  L1M = repmat(L1', N2, 1);
  L1M(~T) = NaN;
  RC = hist(L1M', LC)';
  [C, I] = max(RC, [], 2);
  predict = NaN(N2, 1);
  predict(succ) = LC(I(succ));

end
