% A LFH wrapper for preparing appropriate data for the core implementation
% Input:
%   dataset: a structure containing dataset info
%   method: a structure containing method info
%   codeLength: length of the binary codes
% Output:
%   B1: binary encoding of the trainning data
%   B2: binary encoding of the testing data
%   t1: training time
%   t2: testing time
function [B1, B2, t1, t2] = LFH (task, dataset, method, codeLength)

  % set default values for method properties
  if ~isfield(method, 'learnImpl')
    method.learnImpl = 'default';
  end
  if ~isfield(method, 'normalize')
    method.normalize = false;
  end
  if ~isfield(method, 'debug')
    method.debug = true;
  end
  if ~isfield(method, 'selectParam')
    method.selectParam = false;
  end
  if method.selectParam && ~isfield(method, 'selectParamMethod')
    method.selectParamMethod = 'linear';
  end
  if ~isfield(method, 'initMethod')
    method.initMethod = 'PCA';
  end
  if ~isfield(method, 'roundingMethod')
    method.roundingMethod = 'sign';
  end
  if ~isfield(method, 'kernelNum')
    method.kernelNum = 0;
  end
  if method.kernelNum > 0
    if ~isfield(method, 'kernelEqualVariance')
      method.kernelEqualVariance = false;
    end
    if ~isfield(method, 'kernelEqualLength')
      method.kernelEqualLength = false;
    end
  end

  % start training timer
  timerTrain = tic;
  timeDebug = 0;

  if method.kernelNum > 0
    N1 = length(dataset.indexTrain);
    dataset.indexKernel = dataset.indexTrain(randperm(N1, min(method.kernelNum, N1)));
  end

  % select parameters through validation
  if method.selectParam

    datasetV = dataset;
    datasetV.indexTest = dataset.indexValidation;
    datasetV.neighborTest = dataset.neighborValidation;

    switch method.selectParamMethod

      case 'linear'

        % generate parameter set
        paramSet = {method.betaSet, method.lambdaSet};
        paramName = {'beta', 'lambda'};
        if strcmp(method.learnImpl, 'sigma')
          paramSet = [paramSet method.lambdaSigmaSet];
          paramName = [paramName 'lambdaSigma'];
        end
        for i = 1: length(paramName)
          paramNameC{i} = [upper(paramName{i}(1)) paramName{i}(2: end)];
        end

        for t = 1: length(paramSet)

          % compute MAP for each parameter setting
          n = length(paramSet{t});
          fprintf('  Number of %s parameter choices: %d\n', paramName{t}, n);
          MAPSelect = zeros(n, 1);
          for i = 1: n
            methodV = method;
            methodV.selectParam = false;
            methodV.debug = false;
            methodV = setfield(methodV, paramName{t}, paramSet{t}(i));
            [B1V, B2V] = LFH(task, datasetV, methodV, codeLength);
            MAPSelect(i) = evalSol(B1V, B2V, datasetV.neighborTest);
          end

          % select best parameter
          [opt, idx] = max(MAPSelect);
          method = setfield(method, paramName{t}, paramSet{t}(idx));
          fprintf('  Best %s: %.4g, MAP = %.4g\n', paramName{t}, paramSet{t}(idx), opt);

          % plot MAP for different parameter setting
          timerDebug = tic;
          if method.debug
            figure;
            plot(log10(paramSet{t}), MAPSelect, '-or');
            grid;
            title(sprintf('MAP vs %s (%s, %s, %d)', paramNameC{t}, dataset.name, method.name, codeLength));
            xlabel(sprintf('log(%s)', paramNameC{t}));
            ylabel('MAP');
            saveFigure(gcf, sprintf('%s/MAPSelect%s_%s_%s_%d', task.figureDir, paramNameC{t}, dataset.name, method.name, codeLength));
          end
          timeDebug = timeDebug + toc(timerDebug);

        end

      case 'cross'

        % generate crossed parameter set
        paramSet = enumParamCross(method.betaSet', method.lambdaSet');
        if strcmp(method.learnImpl, 'sigma')
          paramSet = enumParamCross(paramSet, method.lambdaSigmaSet');
        end
        n = size(paramSet, 1);
        fprintf('  Number of crossed parameter choices: %d\n', n);

        % compute MAP for each parameter setting
        MAPSelect = zeros(n, 1);
        for i = 1: n
          methodV = method;
          methodV.selectParam = false;
          methodV.debug = false;
          methodV.beta = paramSet(i, 1);
          methodV.lambda = paramSet(i, 2);
          if strcmp(method.learnImpl, 'sigma')
            methodV.lambdaSigma = paramSet(i, 3);
          end
          [B1V, B2V] = LFH(task, datasetV, methodV, codeLength);
          MAPSelect(i) = evalSol(B1V, B2V, datasetV.neighborTest);
        end

        % select the best parameter
        [opt, idx] = max(MAPSelect);
        method.beta = paramSet(idx, 1);
        method.lambda = paramSet(idx, 2);
        if strcmp(method.learnImpl, 'sigma')
          method.lambdaSigma = paramSet(idx, 3);
        end
        fprintf('  Best parameter (MAP = %.4g):\n', opt);
        fprintf('    Beta: %.4g\n', method.beta);
        fprintf('    Lambda: %.4g\n', method.lambda);
        if strcmp(method.learnImpl, 'sigma')
          fprintf('    LambdaSigma: %.4g\n', method.lambdaSigma);
        end

        % plot MAP for different parameter setting
        timerDebug = tic;
        if method.debug && ~strcmp(method.learnImpl, 'sigma')
          figure;
          meshc(log10(method.betaSet), log10(method.lambdaSet), reshape(MAPSelect, length(method.lambdaSet), length(method.betaSet)));
          title(sprintf('MAP vs (Beta, Lambda) (%s, %s, %d)', dataset.name, method.name, codeLength));
          xlabel('log(Beta)');
          ylabel('log(Lambda)');
          zlabel('MAP');
          saveFigure(gcf, sprintf('%s/MAPSelectCross_%s_%s_%d', task.figureDir, dataset.name, method.name, codeLength));
        end
        timeDebug = timeDebug + toc(timerDebug);

    end

  end

  % define fundamental variables
  N1 = length(dataset.indexTrain);
  X1 = dataset.X(dataset.indexTrain, :);
  N2 = length(dataset.indexTest);
  X2 = dataset.X(dataset.indexTest, :);
  N3 = length(dataset.indexValidation);
  X3 = dataset.X(dataset.indexValidation, :);
  Q = codeLength;
  D = size(X1, 2);

  % re-define feature vectors using kernels
  if method.kernelNum > 0
    XK = dataset.X(dataset.indexKernel, :);
    X1 = calcKernel(X1, XK, method.kernelEqualVariance, method.kernelEqualLength);
    X2 = calcKernel(X2, XK, method.kernelEqualVariance, method.kernelEqualLength);
    X3 = calcKernel(X3, XK, method.kernelEqualVariance, method.kernelEqualLength);
    D = size(X1, 2);
  end

  % NT used for linear regression
  lambdaNorm = method.lambda * N1 / D;
  NT = learnNT(X1, lambdaNorm);

  % initialize U
  switch method.initMethod
    case 'PCA'
      if D > Q
        U0 = PCA(X1, Q);
      else
        idx = mod([0: Q - 1], D) + 1;
        U0 = X1(:, idx);
      end
    case 'random'
      U0 = randn(N1, Q);
  end

  % learn optimal U
  switch method.learnImpl

    case 'default'
      S = calcNeighbor(dataset, dataset.indexTrain); % time consuming for large dataset
      betaNorm = method.beta / (N1 - 1);
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter, LIter] = learnU(U0, S, betaNorm, method.maxIter, method.convergeThresh, calcMAP);

    case 'stochastic'
      betaNorm = method.beta / Q;
      batchSize = N1 * Q;
      calcS = @(Si, Sj) calcNeighborSparse(dataset, dataset.indexTrain(Si), dataset.indexTrain(Sj));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter, LIter] = learnUStochastic(U0, calcS, betaNorm, batchSize, method.maxIter, method.convergeThresh, calcMAP);

    case 'stochastic-2'
      betaNorm = method.beta / Q;
      calcS = @(Sc) calcNeighborSparse(dataset, dataset.indexTrain, dataset.indexTrain(Sc));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter] = learnUStochastic2(U0, calcS, betaNorm, Q, method.maxIter, method.convergeThresh, calcMAP);
      LIter = zeros(size(MAPIter));

    case 'stochastic-full'
      S = calcNeighbor(dataset, dataset.indexTrain); % time consuming for large dataset
      betaNorm = method.beta / Q;
      beta2 = method.beta / (N1 - 1);
      batchSize = N1 * Q;
      calcS = @(Si, Sj) calcNeighborSparse(dataset, dataset.indexTrain(Si), dataset.indexTrain(Sj));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter, LIter] = learnUStochasticFull(U0, S, calcS, betaNorm, beta2, batchSize, method.maxIter, method.convergeThresh, calcMAP);

    case 'stochastic-clean'
      betaNorm = method.beta / Q;
      batchSize = N1 * Q;
      calcS = @(Si, Sj) calcNeighborSparse(dataset, dataset.indexTrain(Si), dataset.indexTrain(Sj));
      U1 = learnUStochasticClean(U0, calcS, betaNorm, batchSize, method.maxIter);

    case 'stochastic-quick'
      betaNorm = method.beta / Q;
      batchSize = N1 * Q;
      calcS = @(Si, Sj) calcNeighborSparse(dataset, dataset.indexTrain(Si), dataset.indexTrain(Sj));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter, LIter] = learnUStochasticQuick(U0, calcS, betaNorm, batchSize, method.maxIter, method.convergeThresh, method.windowSize, calcMAP);

    case 'stochastic-quick-2'
      betaNorm = method.beta / Q;
      calcS = @(Sc) calcNeighbor(dataset, dataset.indexTrain, dataset.indexTrain(Sc));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter] = learnUStochasticQuick2(U0, calcS, betaNorm, Q, method.maxIter, method.convergeThresh, method.windowSize, calcMAP);
      LIter = zeros(size(MAPIter));

    case 'stochastic-quick-full'
      S = calcNeighbor(dataset, dataset.indexTrain); % time consuming for large dataset
      betaNorm = method.beta / Q;
      beta2 = method.beta / (N1 - 1);
      calcS = @(Sc) calcNeighbor(dataset, dataset.indexTrain, dataset.indexTrain(Sc));
      calcMAP = @(U) evalSol2(method, dataset, U, NT, X3);
      [U1, MAPIter, LIter] = learnUStochasticQuickFull(U0, S, calcS, betaNorm, beta2, Q, method.maxIter, method.convergeThresh, method.windowSize, calcMAP);

    case 'none'
      [U1, LIter] = deal(U0, 0);

  end

  % plot convergence curve of objective function
  timerDebug = tic;
  if method.debug
    figure;
    plot([0: length(LIter) - 1], LIter, '-or');
    grid;
    title('Convergence of objective function');
    xlabel('Iteration');
    ylabel('Objective function');
    saveFigure(gcf, sprintf('%s/ConvergenceCurve_%s_%s_%d', task.figureDir, dataset.name, method.name, Q));
  end
  timeDebug = timeDebug + toc(timerDebug);

  % plot MAP along the iterations
  timerDebug = tic;
  if method.debug
    figure;
    plot([0: length(MAPIter) - 1], MAPIter, '-or');
    grid;
    title('MAP along the iterations');
    xlabel('Iteration');
    ylabel('MAP');
    saveFigure(gcf, sprintf('%s/MAPIteration_%s_%s_%d', task.figureDir, dataset.name, method.name, Q));
  end
  timeDebug = timeDebug + toc(timerDebug);

  % normalize U1 to have unit length
  if method.normalize
    lenU = sqrt(sum(U1 .^ 2, 2));
    U1 = bsxfun(@rdivide, U1, lenU);
  end

  % plot distribution of dot product of U
  timerDebug = tic;
  if method.debug
    T = getConst('MEMORY_CAP');
    sN1 = min(floor(sqrt(T / 8)), N1);
    sidx = randperm(N1, sN1);
    sU1 = U1(sidx, :);
    sT = sU1 * sU1' / 2;
    iND = find(~eye(sN1));
    figure;
    hist(sT(iND), 50);
    title('Distribution of dot product of U');
    saveFigure(gcf, sprintf('%s/DistDotProduct_%s_%s_%d', task.figureDir, dataset.name, method.name, Q));
  end
  timeDebug = timeDebug + toc(timerDebug);

  % plot distribution of length of U
  timerDebug = tic;
  if method.debug
    lenU = sqrt(sum(U1 .^ 2, 2));
    figure;
    hist(lenU, 50);
    title('Distribution of length of U');
    saveFigure(gcf, sprintf('%s/DistLenU_%s_%s_%d', task.figureDir, dataset.name, method.name, Q));
  end
  timeDebug = timeDebug + toc(timerDebug);

  % obtain the binary codes of training data
  W = learnW(U1, NT);
  B1 = rounding(U1, method.roundingMethod);
  t1 = toc(timerTrain) - timeDebug;

  % out-of-sample extension
  timerTest = tic;
  U2 = X2 * W;
  B2 = rounding(U2, method.roundingMethod);
  t2 = toc(timerTest) / N2;

end

function MAP = evalSol (B1, B2, neighbor)

  [distH, orderH] = calcHammingRank(B1, B2);
  MAP = calcMAP(orderH, neighbor);

end

function MAP = evalSol2 (method, dataset, U1V, NT, X3)

  B1V = rounding(U1V, method.roundingMethod);
  WV = learnW(U1V, NT);
  U3V = X3 * WV;
  B3V = rounding(U3V, method.roundingMethod);
  MAP = evalSol(B1V, B3V, dataset.neighborValidation);

end

function NT = learnNT (X, lambda)

  NT = (X' * X + lambda * eye(size(X, 2))) \ X';

end

function W = learnW (U, NT)

  W = NT * U;

end
