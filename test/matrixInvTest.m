function matrixInvTest (N, T)

  ns = round(logspace(0, log10(N)));
  t = zeros(1, length(ns));
  for ni = 1: length(ns)
    n = ns(ni);
    ts = zeros(1, T);
    for k = 1: T
      A = rand(n);
      b = rand(1, n);
      tic;
      b / A;
      % inv(A);
      % eye(n) / A;
      ts(k) = toc;
    end
    t(ni) = median(ts);
    fprintf('%d: %.4f\n', n, t(ni));
  end

  ps = [3 2.807 2.376 2.373 2];
  cv = ['r' 'g' 'b' 'c' 'm'];
  figure;
  hold on;
  for i = 1: length(ps)
    plot(ns, ns .^ ps(i) ./ t, ['-' cv(i)]);
  end
  hold off;
  legend('Gauss-Jordan (3)', 'Strassen (2.807)', 'Coppersmith-Winograd (2.376)', 'Williams (2.373)', 'Lower Bound (2)');

  saveas(gcf, 'matrixInv', 'fig');

end
