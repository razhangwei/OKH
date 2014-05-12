function t = parallelEig (M)

  tid = tic;
  parfor (i = 1: 200, M)
    c(:, i) = eig(rand(200));
  end
  t = toc(tid);

end
