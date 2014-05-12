function [predict, succ] = radiusBound (method, B1, B2, V1)

  if ~isfield(method, 'softWeight')
    method.softWeight = false;
  end

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  R = method.radius;
  distH = calcHammingRank(B1, B2);

  T = distH <= R;
  S = sum(T, 2);
  succ = S > 0;
  V1M = repmat(V1', N2, 1);
  V1M(~T) = 0;
  predict = zeros(N2, 1);
  if method.softWeight
    W = 1 ./ (double(distH) .^ 2 + method.soft ^ 2) .^ method.alpha;
    W(~T) = 0;
    predict(succ) = sum(V1M(succ, :) .* W(succ, :), 2) ./ sum(W(succ, :), 2);
  else
    predict(succ) = sum(V1M(succ, :), 2) ./ S(succ);
  end

end
