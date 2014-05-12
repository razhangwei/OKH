function checkSemiDefinite (A)
  eps = 1e-9;
  d = eig((A + A') / 2);
  r = min(d);
  if (r < -eps)
    fprintf('not semi-definite: %.4g\n', r);
  end
end
