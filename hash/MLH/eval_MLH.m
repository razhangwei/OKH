function ap = eval_MLH (data, W)

  % a lousy approximation to MAP
  [p1 r1] = eval_linear_hash(W, data);
  p1(isnan(p1)) = 1;
  ap = sum([(p1(1: end - 1) + p1(2: end)) / 2] .* [(r1(2: end) - r1(1: end - 1))]);

end
