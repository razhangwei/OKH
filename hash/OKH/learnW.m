function WW = learnW(xi, xj, s, W, alpha, C)

    x = [xi, xj];
    h = sign(W' * x);
    R = size(W, 2);
    if s == 0, s = -1; end;
    
    % compute loss    
    switch s
      case 1
        loss = max(0, sum(h(:, 1) ~= h(:, 2)) - (1 - alpha) * R);
      case -1
        loss = max(0, alpha * R - sum(h(:, 1) ~= h(:, 2)) );  
    end

    WW = W;
    if loss ~= 0 
      % get optimal hash code g
      g = calcOptCode(x, h, s, W, alpha);
      % compute prediction-based loss lpb
      lpb = (h(:, 1) - g(:, 1))' * W' * x(:, 1) + (h(:, 2) - g(:, 2))' * W' * x(:, 2) + sqrt(loss);
      % update W
      tau = min(C, lpb / trace((g - h) * (x' * x) * (g - h)') );	   %%%%% could be optimized
      WW = W + tau * x * (g - h)';               %%%%% could be optimized
    end
end