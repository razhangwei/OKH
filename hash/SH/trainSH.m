% Spectral Hashing
% Y. Weiss, A. Torralba, R. Fergus.
% Advances in Neural Information Processing Systems, 2008.
%
% Input
%   X = features matrix [Nsamples, Nfeatures]
%   SHparam.nbits = number of bits (nbits do not need to be a multiple of 8)
%
function SHparam = trainSH (X, SHparam)

  [Nsamples, Ndim] = size(X);
  nbits = SHparam.nbits;

  % PCA
  npca = min(nbits, Ndim);
  [pc, l] = eigs(cov(X), npca);
  X = X * pc;

  % fit uniform distribution
  mn = prctile(X, 5);
  mn = min(X) - eps;
  mx = prctile(X, 95);
  mx = max(X) + eps;

  % enumerate eigenfunctions
  R = (mx - mn);
  maxMode = ceil((nbits + 1) * R / max(R));

  nModes = sum(maxMode) - length(maxMode) + 1;
  modes = ones([nModes, npca]);
  m = 1;
  for i = 1: npca
    modes(m + 1: m + maxMode(i) - 1, i) = 2: maxMode(i);
    m = m + maxMode(i) - 1;
  end
  modes = modes - 1;
  omega0 = pi ./ R;
  omegas = modes .* repmat(omega0, [nModes, 1]);
  eigVal = -sum(omegas .^ 2, 2);
  [yy, ii]= sort(-eigVal);
  modes = modes(ii(2: nbits + 1), :);

  % store paramaters
  SHparam.pc = pc;
  SHparam.mn = mn;
  SHparam.mx = mx;
  SHparam.mx = mx;
  SHparam.modes = modes;

end
