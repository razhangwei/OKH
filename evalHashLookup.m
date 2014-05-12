% Input:
%   B1: binary codes of training data
%   B2: binary codes of testing data
%   S: true neighbors
%   R: hash lookup radius
% Output:
%   meanPrec: mean precision
%   succRate: success rate
function [meanPrec, succRate] = evalHashLookup (B1, B2, S, R)

  N1 = size(B1, 1);
  N2 = size(B2, 1);
  Q = size(B1, 2);

  % build hash table
  tic;
  table = containers.Map;
  for i = 1: N1
    key = num2str(B1(i, :), '%d');
    if isKey(table, key)
      table(key) = [table(key), i];
    else
      table(key) = [i];
    end
  end
  toc;

  % generate bit flipping positions
  tic;
  BF = [];
  for i = 0: R
    T = nchoosek(1: Q, i);
    U = zeros(size(T, 1), Q);
    for j = 1: size(T, 1)
      U(j, T(j, :)) = 1;
    end
    BF = [BF; U];
  end
  toc;

  % hash lookup for each testing data
  tic;
  succ = false(N2, 1);
  prec = zeros(N2, 1);
  for i = 1: N2
    BR = bsxfun(@xor, B2(i, :), BF);
    key = num2str(BR, '%d');
    key = mat2cell(key, ones(1, size(key, 1)));
    id = values(table, key(isKey(table, key)));
    id = [id{:}];
    succ(i) = ~isempty(id);
    if ~isempty(id)
      prec(i) = sum(S(i, id)) / length(id);
    end
  end
  toc;

  succRate = mean(succ);
  meanPrec = mean(prec);

end
