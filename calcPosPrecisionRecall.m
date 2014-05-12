% compute precision recall for each position in the ranking list
function [precision, recall] = calcPosPrecisionRecall (orderH, neighbor)

  [N2, N1] = size(neighbor);
  precision = zeros(1, N1);
  recall = zeros(1, N1);

  for i = 1: N2
    neighbor(i, :) = neighbor(i, orderH(i, :));
  end

  totRelevant = sum(neighbor(:));
  retrieved = 0;
  truePos = 0;
  for i = 1: N1
    retrieved = retrieved + N2;
    truePos = truePos + sum(neighbor(:, i));
    precision(i) = truePos / retrieved;
    recall(i) = truePos / totRelevant;
  end

end
