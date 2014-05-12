% each row in P1 and P2 is a data point
% compute the euclidean distance between every pair of data points
function D = calcEuDist (P1, P2)

  if ~exist('P2', 'var')
    P2 = P1;
  end

  % compact code for memory efficient
  D = sqrt(repmat(sum(P1 .^ 2, 2), 1, size(P2, 1)) + repmat(sum(P2 .^ 2, 2), 1, size(P1, 1))' - 2 * P1 * P2');

end
