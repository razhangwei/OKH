% performing PCA on the data structure
function X = do_pca (X, nb)

  if nb >= size(X, 2)
    return;
  end

  opts.disp = 0;
  [pc, l] = eigs(cov(X), nb, 'LM', opts);
  X = X * pc;

end
