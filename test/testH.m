function testH (N, T)

  for i = 1: T
    Ui = rand(N, 1) - 0.5;
    Z = rand(N);
    Z = (Z + Z') / 2;
    A = Z .* (Ui * Ui');
    checkSemiDefinite(eye(N));
  end

end
