% check if sift_learn is a subset of sift_base

datapath = '../data/SIFT-1M/raw/';

X = fvecs_read([datapath 'sift_base.fvecs']);
X2 = fvecs_read([datapath 'sift_learn.fvecs']);
X2s = X2(:, randperm(size(X2, 2), 10));

for i = 1: size(X2s, 2)
  x = X2s(:, i);
  d = bsxfun(@minus, x, X);
  dl = sum(d .^ 2);
  fprintf('%g\n', min(dl));
end
