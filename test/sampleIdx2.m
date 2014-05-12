% improved random sampling of S entries from an NxN matrix
% distinct, symmetric, and roughly equal in each line and column
% assume S is dividable by N
function idx = sampleIdx21 (N, S)

  px = zeros(2 * S, 1);
  py = zeros(2 * S, 1);
  T = S / N;
  NS = 0;
  for i = 1: N
    s = randperm(N, T)';
    u = repmat([i], length(s), 1);
    px(NS + 1: NS + length(s) * 2) = [u; s];
    py(NS + 1: NS + length(s) * 2) = [s; u];
    NS = NS + length(s) * 2;
  end
  idx = unique(sub2ind([N, N], px, py));

end

% improved random sampling of S entries from an NxN matrix
% distinct, symmetric, and roughly equal in each line and column
% assume S is dividable by N
function idx = sampleIdx22 (N, S)

  px = zeros(2 * S, 1);
  py = zeros(2 * S, 1);
  T = S / N;
  NS = 0;
  rm = repmat([T], N, 1);
  for i = 1: N
    if rm(i) > 0
      s = randperm(N - i, min(rm(i), N - i))' + i;
      u = repmat([i], length(s), 1);
      px(NS + 1: NS + length(s) * 2) = [u; s];
      py(NS + 1: NS + length(s) * 2) = [s; u];
      NS = NS + length(s) * 2;
    end
  end
  px = px(1: NS);
  py = py(1: NS);
  idx = unique(sub2ind([N, N], px, py));

end
