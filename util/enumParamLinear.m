function Z = enumParamLinear (X, X0, Y, Y0)

  Z = [X, repmat(Y0, size(X, 1), 1); repmat(X0, size(Y, 1), 1), Y];

end
