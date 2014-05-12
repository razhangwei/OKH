% load dataset data into memory, and perform some data preprocessing
function dataset = loadDataset (task, dataset)

  % load dataset
  fprintf('Loading dataset %s\n', dataset.name);
  temp = load([dataset.path dataset.filename]);
  dataset = copyField(dataset, temp);

  % rename label variable
  if isfield(dataset, 'labelName')
    dataset = renameField(dataset, dataset.labelName, 'label');
  end

  % rename value variable
  if isfield(dataset, 'valueName')
    dataset = renameField(dataset, dataset.valueName, 'value');
  end

  % subsample
  if ~isfield(dataset, 'subsample')
    dataset.subsample = size(dataset.X, 1);
  end
  dataset = subsample(task, dataset);

  % partition into training, testing, and validation set
  fprintf('Partitioning dataset %s into training, testing, and validation set\n', dataset.name);
  if ~isfield(dataset, 'numValidation')
    dataset.numValidation = dataset.numTest;
  end
  N = size(dataset.X, 1);
  N2 = dataset.numTest;
  N3 = dataset.numValidation;
  N1 = N - N2 - N3;
  dataset.indexTrain = [1: N1]';
  dataset.indexTest = [N1 + 1: N1 + N2]';
  dataset.indexValidation = [N1 + N2 + 1: N]';
  fprintf('  # of training data: %d\n', N1);
  fprintf('  # of testing data: %d\n', N2);
  fprintf('  # of validation data: %d\n', N3);

  % feature scaling
  if isfield(dataset, 'normFilter')
    fprintf('Feature scaling on dataset %s\n', dataset.name);
    dataset = featureScaling(dataset);
  end
  
  % compute neighbor threshold
  if ismember(dataset.neighborType, {'dist', 'affinity', 'value'})
    fprintf('Computing neighbor threshold for dataset %s with target of average %d neighbors for each query\n', dataset.name, dataset.aveNeighbor);
    cacheFile = sprintf('%s/neighborThresh_%s.mat', task.dataDir, dataset.name);
    if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_NEIGHBOR_THRESH'), @updaterNeighborThresh)
      tp = timerStart();
      threshold = calcNeighborThresh(dataset);
      timeCost = timerStop(tp);
      save(cacheFile, 'version', 'threshold', 'timeCost', '-v7.3');
    end
    dataset.neighborThreshold = threshold;
    fprintf('  Threshold: %.6g\n', threshold);
    fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
    if (isfield(timeCost, 'ctime'))
      fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
    end
  end

  % computing ground-truth neighbor
  fprintf('Computing ground-truth neighbor for dataset %s\n', dataset.name);
  cacheFile = sprintf('%s/neighbor_%s.mat', task.dataDir, dataset.name);
  if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_NEIGHBOR'), @updaterNeighbor)
    tp = timerStart();
    neighborTest = calcNeighbor(dataset, dataset.indexTest, dataset.indexTrain);
    neighborValidation = calcNeighbor(dataset, dataset.indexValidation, dataset.indexTrain);
    timeCost = timerStop(tp);
    save(cacheFile, 'version', 'neighborTest', 'neighborValidation', 'timeCost', '-v7.3');
  end
  dataset.neighborTest = neighborTest;
  dataset.neighborValidation = neighborValidation;
  aveNeighborTest = mean(sum(neighborTest, 2));
  aveNeighborValidation = mean(sum(neighborValidation, 2));
  fprintf('  Average neighbor (testing): %.2f (%.2f%%)\n', aveNeighborTest, aveNeighborTest / N1 * 100);
  fprintf('  Average neighbor (validation): %.2f (%.2f%%)\n', aveNeighborValidation, aveNeighborValidation / N1 * 100);
  fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
  if (isfield(timeCost, 'ctime'))
    fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
  end

  % sample training pair and compute similarity label
  temp = floor(N1 / 2);
  train_pair = [1 : temp; temp + 1 : temp *2]';
  fprintf('Computing similarity labels of sampled pairs for dataset %s\n', dataset.name);  
  cacheFile = sprintf('%s/TrainLabel_%s.mat', task.dataDir, dataset.name);
  if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_PAIR_LABEL'))
    tp = timerStart();
    train_label = calcNeighborSparse(dataset, train_pair(:, 1), train_pair(:, 2));
    timeCost = timerStop(tp);
    save(cacheFile, 'version', 'train_pair', 'train_label', 'timeCost', '-v7.3');
  end
  dataset.train_pair = train_pair;
  dataset.train_label = train_label;
  fprintf('  # of sample pairs(training): %d\n', size(dataset.train_pair, 1));
  fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
  if (isfield(timeCost, 'ctime'))
    fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
  end
end
