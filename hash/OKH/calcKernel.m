function X = calcKernel (X0, XK)

  Dsq = calcEuDist(X0, XK) .^ 2;
  X = exp(-Dsq / (2 * mean(Dsq(:))));

  mu = mean(X);
  X = bsxfun(@minus, X, mu);

end
