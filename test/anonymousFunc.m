function anonymousFunc (y)

  h = @(x) prod(x, y);
  for x = 1: 9
    fprintf('%d\n', h(x));
  end

end

function z = prod (x, y)

  z = x * y;

end
