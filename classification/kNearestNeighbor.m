function [predict, succ] = kNearestNeighbor (method, B1, B2, L1)

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  K = method.numNeighbor;
  [distH, orderH] = calcHammingRank(B1, B2);

  if method.preserveTie
    DN = distH(sub2ind(size(distH), uint32([1: N2])', orderH(:, K)));
    T = bsxfun(@le, distH, DN);
  else
    ind = sub2ind(size(distH), repmat(uint32([1: N2])', 1, K), orderH(:, 1: K));
    T = false(size(distH));
    T(ind) = true;
  end

  LC = unique(L1);
  L1M = repmat(L1', N2, 1);
  L1M(~T) = NaN;
  RC = hist(L1M', LC)';
  [C, I] = max(RC, [], 2);
  predict = LC(I);
  succ = true(N2, 1);

end
