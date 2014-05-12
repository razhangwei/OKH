% Copyright (c) 2011, Mohammad Norouzi and David Fleet
% The main file for learning hash functions. It performs stochastic gradient descent to learn the hash parameters.
%
% Input:
%    data: data structure for training the model already split into training and validation sets.
%    param: a parameter structure which should include the required parameters.
%    initW: initial weight matrix
%
% Output:
%    mean_ap: mean average precision over nval_after validation stages after training
%    final_W: final weight matrix
%    final_params: parameters with some additional components
function [mean_ap final_W final_params] = learnMLH (data, param, initW)

  nb = param.nb; % number of bits i.e, binary code length
  initeta = param.eta; % initial learning rate
  shrink_eta = param.shrink_eta; % whether shrink learning rate, as training proceeds
  size_batches = param.size_batches; % mini-batch size
  maxiter = param.maxiter; % number of gradient update iterations (each iteration consists of 10^5 pairs)
  zerobias = param.zerobias; % whether offset terms are learned for hashing hyper-planes or they all go through the origin
  momentum = param.momentum; % momentum term (between 0 and 1) for gradient update
  shrink_w = param.shrink_w; % weight decay parameter

  Ntraining = data.Ntraining;
  NtrainingSqr = Ntraining ^ 2;
  Xtraining = data.Xtraining;
  rho = param.rho;
  lambda = param.lambda;

  indPos = find(data.Straining == 1);
  nPos = numel(indPos);

  input_dim = size(Xtraining, 1);
  W = initW;

  % initialization
  ntraining = param.epochSize; % total number of pairs to be considered in each iteration
  ncases = size_batches;
  maxb = floor(ntraining / ncases); % number of mini-batches
  maxt = maxiter + param.nval_after - 1; % number of epochs

  mean_ap = 0;
  Winc = zeros(size(W));
  cases = zeros(ncases, 1);

  % fprintf('  Learning (rho = %.4g, lambda = %.4g, shrink_w = %.4g)\n', rho, lambda, shrink_w);
  prg = 0;
  tid = tic;
  for t = 1: maxt

    % learning rate update
    if (shrink_eta)
      eta = initeta * (maxt - t) / maxt;
    else
      eta = initeta;
    end

    for b = 1: maxb
      % make the fraction of positive pairs to be at least lambda
      ncases2 = min(round(ncases * max(lambda - (nPos / NtrainingSqr), 0)), ncases);
      ncases1 = ncases - ncases2;
      % random selection of pairs
      cases(1: ncases1) = ceil(rand(ncases1, 1) * NtrainingSqr);
      % selection of positive pairs
      cases(ncases1 + 1: end) = indPos(ceil(rand(ncases2, 1) * nPos));

      % cases = ceil(rand(ncases, 1) * NtrainingSqr);
      [x1nd x2nd] = ind2sub([Ntraining Ntraining], cases);

      x1 = Xtraining(:, x1nd(:));
      x2 = Xtraining(:, x2nd(:));

      l = full(data.Straining(cases)');

      x1 = [x1; ones(1, ncases)];
      Wx1 = W * x1;
      y1 = sign(Wx1);

      x2 = [x2; ones(1, ncases)];
      Wx2 = W * x2;
      y2 = sign(Wx2); % we use -1/+1 instead of 0/1 values for the binary vectors

      y1plus = Wx1; % y1 bits all on
      y1minus = -Wx1; % y1 bits all off
      y2plus = Wx2; % y2 bits all on
      y2minus = -Wx2; % y2 bits all off

      % best score for bits in y1 and y2 being the same
      [valeq indeq] = max([cat(3, y1plus + y2plus, y1minus + y2minus)], [], 3);
      % best score for bits in y1 and y2 being different
      [valneq indneq] = max([cat(3, y1plus + y2minus, y1minus + y2plus)], [], 3);
      % valeq and valneq are matrices of size nb * ncases.
      [val indval] = sort(valneq - valeq, 'descend');

      loss = [kron(l == 1, ([zeros(1, rho) 1: (nb - rho + 1)] / (nb - rho + 1))')] + [kron(l == 0, ([(rho + 1): -1: 1 zeros(1, nb - rho)] / (rho + 1))')];

      % loss-adjusted inference (using a mex file)
      [y1p y2p nflip] = loss_adj_inf_mex(Wx1, Wx2, loss);

      nonzero_grad_1 = sum(abs(y1 - y1p)) ~= 0;
      nonzero_grad_2 = sum(abs(y2 - y2p)) ~= 0;

      % gradient
      grad = [x1(:, nonzero_grad_1) * (y1(:, nonzero_grad_1) - y1p(:, nonzero_grad_1))' + x2(:, nonzero_grad_2) * (y2(:, nonzero_grad_2) - y2p(:, nonzero_grad_2))']';

      % update rule of W
      if (zerobias)
        Winc = momentum * Winc + eta * (grad ./ ncases - shrink_w * W);
        Winc(:, end) = 0;
      else
        Winc = momentum * Winc + eta * (grad ./ ncases - shrink_w * [W(:, 1: end - 1) zeros(nb, 1)]);
      end

      % we don't re-normalize rows of W as mentioned in the paper anymore, instead we use weight decay, i.e., L2 norm regularizer.
      W = W + Winc;
    end

    if (param.nval_after && t >= maxiter && strcmp(param.trainset, 'train'))
      mean_ap = mean_ap + eval_MLH(data, W);
    end

    nprg = floor(t / maxt * 100);
    if nprg > prg
      % fprintf('  %d%%: %.4gs\n', nprg, toc(tid));
      prg = nprg;
    end

  end
  % fprintf('  Average time per iteration: %.4gs\n', toc(tid) / maxt);

  if (param.nval_after)
    mean_ap = mean_ap / param.nval_after;
  end

  param.ap = mean_ap;
  final_W = W;
  final_params = param;

end
