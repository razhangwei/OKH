function W = MLHCore (data, nb, val_iter, train_iter, epochSize)

  % hidden parameters initialization
  val_zerobias = 1;
  train_zerobias = 1;
  size_batches = 100;
  eta = 0.1;
  momentum = 0.9;

  % setting of parameters
  best_params.size_batches = size_batches;
  best_params.eta = eta;
  best_params.momentum = momentum;

  % A heuristic for initial selection of rho
  [p0 r0] = eval_LSH(nb, data);
  rho = sum(r0 < 0.3); % rho with 30% recall (nothing deep; just a heuristic)

  % validation on rho and lambda
  step = round(nb / 32);
  step(step < 1) = 1;
  rho_set = rho + [-2 -1 0 +1 +2] * step;
  rho_set(rho_set < 1) = [];
  lambda_set = [0 0.2 0.5];
  Wtmp = MLHVal(data, rho_set, lambda_set, nb, best_params.eta, best_params.momentum, epochSize, best_params.size_batches, 'train', val_iter, val_zerobias, 5, 1e-4, false);
  [tmp, idx] = max([Wtmp.ap]);
  best_params.rho = Wtmp(idx).params.rho;
  best_params.lambda = Wtmp(idx).params.lambda;

  % validation for weight decay parameter
  shrink_w_set = [1e-2 1e-3 1e-4 1e-5 1e-6];
  Wtmp = MLHVal(data, best_params.rho, best_params.lambda, nb, best_params.eta, best_params.momentum, epochSize, best_params.size_batches, 'train', val_iter, val_zerobias, 5, shrink_w_set, false);
  [tmp, idx] = max([Wtmp.ap]);
  best_params.shrink_w = Wtmp(idx).params.shrink_w;

  % training on the train + val set
  Wmlh = MLHVal(data, best_params.rho, best_params.lambda, nb, best_params.eta, best_params.momentum, epochSize, best_params.size_batches, 'trainval', train_iter, train_zerobias, 1, best_params.shrink_w, true);

  W = Wmlh.W;

end
