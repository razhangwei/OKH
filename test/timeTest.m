T = rand(200, 200, 100);
tic; t = cputime;
for i = 1: 100
  eig(T(:, :, i));
end
t1 = toc; t2 = cputime - t;
fprintf('%.4f, %.4f, %.4f\n', t1, t2, t2 / t1);
