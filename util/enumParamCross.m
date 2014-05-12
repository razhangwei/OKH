function Z = enumParamCross (X, Y)

  N1 = size(X, 1);
  N2 = size(Y, 1);
  Z = zeros(N1 * N2, size(X, 2) + size(Y, 2));
  k = 0;
  for i = 1: N1
    for j = 1: N2
      k = k + 1;
      Z(k, :) = [X(i, :), Y(j, :)];
    end
  end

end
