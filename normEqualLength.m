% make each data vector to have unit length (as in MLH)
function X = normEqualLength (X)

  normX = sqrt(sum(X .^ 2, 2));
  nz = find(normX > 0);
  X(nz, :) = bsxfun(@rdivide, X(nz, :), normX(nz));

end
