function g = calcOptCode(x, h, s, W, alpha)
  dist = sum(h(:, 1) ~= h(:, 2));  
  R = size(h, 1);
  g = h;
  flag = false;
  if s == -1 && dist < alpha * R
    p0 = ceil(alpha * R - dist);
    idx = find(h(:, 1) == h(:, 2));       
    flag = true;
  elseif s == 1 && dist > (1 - alpha) * R
    p0 = ceil(dist - (1 - alpha) * R);
    idx = find(h(:, 1) ~= h(:, 2));    
    flag = true;
  end
  
  if flag
    delta = max(h(idx, 1) .* (W(:, idx)' * x(:, 1)), h(idx, 2) .* (W(:, idx)' * x(:, 2)) );  
    %delta = abs(h(idx, 1) .* (W(:, idx)' * x(:, 1)) - h(idx, 2) .* (W(:, idx)' * x(:, 2)) );  
    [~, temp_idx1] = sort(delta, 'descend');
    temp_idx1 = idx(temp_idx1(1 : p0));
    %temp_idx2 = randi([1, 2], p0, 1);
    temp_idx2 = h(temp_idx1, 1) .* (W(:, temp_idx1)' * x(:, 1)) <  h(temp_idx1, 2) .* (W(:, temp_idx1)' * x(:, 2));
    temp_idx2 = 2 - temp_idx2;
    temp_idx = sub2ind(size(g), temp_idx1, temp_idx2);
    g(temp_idx) = -h(temp_idx);
  end    
end
