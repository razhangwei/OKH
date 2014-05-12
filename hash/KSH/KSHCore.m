% Kernel-based supervised hashing
% Input:
%   traindata: training data
%   testdata: testing data
%   r: number of hash bits
%   label_index: indexes of labeled samples
%   sample: indexes of anchors
%   S: pairwise label matrix
% Output:
%   Y: binary encoding of the training data
%   tY: binary encoding of the testing data
function [Y, tY, timeTrain, timeTest] = KSHCore (traindata, testdata, r, label_index, sample, S)

  [n, d] = size(traindata);
  tn = size(testdata, 1);
  m = length(sample); % number of anchors
  trn = length(label_index); % number of labeled training samples

  tidTrain = tic;

  % kernel computing (k_bar)
  anchor = traindata(sample', :);
  KTrain = sqdist(traindata', anchor');
  sigma = mean(mean(KTrain, 2));
  KTrain = exp(-KTrain / (2 * sigma));
  mvec = mean(KTrain);
  KTrain = KTrain - repmat(mvec, n, 1);

  % projection optimization
  KK = KTrain(label_index', :);
  RM = KK' * KK;
  A1 = zeros(m, r);
  flag = zeros(1, r);
  for rr = 1: r

    if rr > 1
      S = S - y * y';
    end

    LM = KK' * S * KK;
    [U, V] = eig(LM, RM);
    eigenvalue = diag(V)';
    [eigenvalue, order] = sort(eigenvalue, 'descend');
    A1(:, rr) = U(:, order(1));
    tep = A1(:, rr)' * RM * A1(:, rr);
    A1(:, rr) = sqrt(trn / tep) * A1(:, rr);
    clear U;
    clear V;
    clear eigenvalue;
    clear order;
    clear tep;

    [get_vec, cost] = OptProjectionFast(KK, S, A1(:, rr), 500);
    y = double(KK * A1(:, rr) > 0);
    ind = find(y <= 0);
    y(ind) = -1;
    clear ind;
    y1 = double(KK * get_vec > 0);
    ind = find(y1 <= 0);
    y1(ind) = -1;
    clear ind;
    if y1' * S * y1 > y' * S * y
      flag(rr) = 1;
      A1(:, rr) = get_vec;
      y = y1;
    end

  end

  % encoding
  Y = KTrain * A1 > 0;

  timeTrain = toc(tidTrain);
  tidTest = tic;

  % test encoding
  KTest = sqdist(testdata', anchor');
  KTest = exp(-KTest / (2 * sigma));
  KTest = KTest - repmat(mvec, tn, 1);
  tY = KTest * A1 > 0;

  timeTest = toc(tidTest) / tn;

end
