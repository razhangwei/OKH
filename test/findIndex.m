function findIndex (N, Q)

  v = randi(N, N * Q, 1);
  idx = cell(length(v), 1);

  % 17.13s
  % tic;
  % for i = 1: N
  %   idx{i} = find(v == i);
  % end
  % toc;

  % 3.88s
  % tic;
  % for i = 1: length(v)
  %   idx{v(i)} = [idx{v(i)} i];
  % end
  % toc;

  % 0.45s
  % tic;
  % for i = 1: N
  %   idx{i} = zeros(1, floor(Q * 1.2));
  % end
  % num = zeros(1, N);
  % for i = 1: length(v)
  %   num(v(i)) = num(v(i)) + 1;
  %   idx{v(i)}(num(v(i))) = i;
  % end
  % for i = 1: N
  %   idx{i}(num(i) + 1: end) = [];
  % end
  % toc;

  % 0.12s
  tic;
  [sv, is] = sort(v);
  [cv, ia, ic] = unique(sv, 'first');
  k = 1;
  for i = 1: N
    while k <= length(cv) && cv(k) < i
      k = k + 1;
    end
    if k <= length(cv) && cv(k) == i
      a = ia(k);
      if k < length(cv)
        b = ia(k + 1) - 1;
      else
        b = length(sv);
      end
      idx{i} = is(a: b);
    end
  end
  toc;

  % 0.01s
  % tic;
  % for i = 1: N
  %   idx{i} = zeros(Q, 1);
  % end
  % toc;

  % succ = true;
  % cnt = 0;
  % for i = 1: N
  %   if sum(v(idx{i}) ~= i) > 0
  %     succ = false;
  %     break;
  %   end
  %   cnt = cnt + length(unique(idx{i}));
  % end
  % if cnt ~= length(v)
  %   succ = false;
  % end
  % if succ
  %   fprintf('Correct!\n');
  % else
  %   fprintf('Incorrect!\n');
  % end

end
