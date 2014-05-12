% create a subset of a given dataset by randomly subsampling
function dataset = subsample (task, dataset)

  fprintf('Subsampling %d instances from dataset %s\n', dataset.subsample, dataset.name);
  cacheFile = sprintf('%s/subsample_%s.mat', task.dataDir, dataset.name);
  if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_SUBSAMPLE'))
    N = size(dataset.X, 1);
    Ns = min(dataset.subsample, N);
    idx = randperm(N, Ns);
    save(cacheFile, 'version', 'idx', '-v7.3');
  end

  dataset.X = double(dataset.X(idx, :));
  switch dataset.neighborType
    case 'affinity'
      dataset.affinity = double(dataset.affinity(idx, idx));
    case 'value'
      dataset.value = double(dataset.value(idx));
    case 'label'
      dataset.label = double(dataset.label(idx));
    case 'tag'
      dataset.tag = double(dataset.tag(idx, :));
  end

end
