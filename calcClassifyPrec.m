% compute classification precision
function classifyPrec = calcClassifyPrec (orderH, neighbor, numGuess)

  [Q, ~] = size(neighbor);
  prec = 0;
  for i = 1: Q
    ngb = neighbor(i, orderH(i, 1: numGuess));
    if sum(ngb) > 0
      prec = prec + 1;
    end
  end
  classifyPrec = prec / Q;

end
