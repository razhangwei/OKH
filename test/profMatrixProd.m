function profMatrixProd (N, M, T)

  profile('-memory', 'on');
  sub(N, M, T);
  profile('off');
  profreport;

end

function sub (N, M, T)

  for i = 1: T
    P1 = rand(N, M);
    P2 = rand(N, M);
    D = P1 * P2';
  end

end
