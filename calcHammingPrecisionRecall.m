% compute precision recall for each Hamming radius
function [precision, recall] = calcHammingPrecisionRecall (orderH, distH, neighbor)

  [N2, N1] = size(neighbor);
  R = max(distH(:));
  retrieved = zeros(1, R + 1);
  truePos = zeros(1, R + 1);

  for i = 1: N2
    neighbor(i, :) = neighbor(i, orderH(i, :));
    distH(i, :) = distH(i, orderH(i, :));
  end

  totRelevant = sum(neighbor(:));
  for i = 1: N2
    tp = 0;
    j = 1;
    for d = 0: R
      while j <= N1 & distH(i, j) <= d
        tp = tp + neighbor(i, j);
        j = j + 1;
      end
      retrieved(d + 1) = retrieved(d + 1) + (j - 1);
      truePos(d + 1) = truePos(d + 1) + tp;
    end
  end

  nz = find(retrieved ~= 0);
  zr = find(retrieved == 0);
  precision(zr) = 1;
  precision(nz) = truePos(nz) ./ retrieved(nz);
  recall = truePos / totRelevant;

end
