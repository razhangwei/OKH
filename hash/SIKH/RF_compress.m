function XX = RF_compress (X, RFparam)

  N = size(X, 1);
  B = repmat(RFparam.B, N, 1);

  % compute random features
  W = sqrt(2) * cos(X * RFparam.R + B);

  % compute signs of random features
  T = repmat(RFparam.T, N, 1);

  XX = W + T;

end
