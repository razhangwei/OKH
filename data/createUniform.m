% Create a uniformly distributed synthetic dataset.
function createUniform (N, D, fileName)

  X = rand(N, D) * 2 - 1;
  save(fileName, 'X', '-v7.3');

end
