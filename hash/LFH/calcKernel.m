function X = calcKernel (X0, XK, equalVariance, equalLength)

  Dsq = calcEuDist(X0, XK) .^ 2;
  X = exp(-Dsq / (2 * mean(Dsq(:))));

  mu = mean(X);
  X = bsxfun(@minus, X, mu);

  if equalVariance
    sigma = std(X);
    nz = find(sigma > 0);
    X(:, nz) = bsxfun(@rdivide, X(:, nz), sigma(nz));
  end

  if equalLength
    normX = sqrt(sum(X .^ 2, 2));
    nz = find(normX > 0);
    X(nz, :) = bsxfun(@rdivide, X(nz, :), normX(nz));
  end

end
