function [predict, succ] = kNearestNeighbor (method, B1, B2, V1)

  if ~isfield(method, 'preserveTie')
    method.preserveTie = false;
  end
  if ~isfield(method, 'softWeight')
    method.softWeight = false;
  end
  if ~isfield(method, 'binaryCode')
    method.binaryCode = true;
  end

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  K = method.numNeighbor;
  if method.binaryCode
    [distH, orderH] = calcHammingRank(B1, B2);
  else
    [distH, orderH] = calcEuclideanRank(B1, B2);
  end

  if method.preserveTie
    DN = distH(sub2ind(size(distH), uint32([1: N2])', orderH(:, K)));
    T = bsxfun(@le, distH, DN);
  else
    ind = sub2ind(size(distH), repmat(uint32([1: N2])', 1, K), orderH(:, 1: K));
    T = false(size(distH));
    T(ind) = true;
  end

  V1M = repmat(V1', N2, 1);
  V1M(~T) = 0;
  if method.softWeight
    W = 1 ./ (double(distH) .^ 2 + method.soft ^ 2) .^ method.alpha;
    W(~T) = 0;
    predict = sum(V1M .* W, 2) ./ sum(W, 2);
  else
    predict = sum(V1M, 2) ./ sum(T, 2);
  end
  succ = true(N2, 1);

end
