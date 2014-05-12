function defaultParam (a, b)

  if ~exist('a', 'var')
    a = 0;
  end

  if ~exist('b', 'var')
    b = 0;
  end

  fprintf('(%d, %d)\n', a, b);

end
