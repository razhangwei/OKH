% Input:
%   B1: binary codes of training data
%   B2: binary codes of testing data
%   S: true neighbors
%   R: hash lookup radius
% Output:
%   meanPrec: mean precision
%   succRate: success rate
function [meanPrec, succRate] = evalHashLookup2 (B1, B2, S, R)

  [distH, orderH] = calcHammingRank(B1, B2);

  T = distH <= R;
  retrieved = sum(T, 2);
  succ = retrieved > 0;
  succRate = mean(succ);
  truePos = sum(T & S, 2);
  prec = zeros(size(succ));
  prec(succ) = truePos(succ) ./ retrieved(succ);
  meanPrec = mean(prec);

end
