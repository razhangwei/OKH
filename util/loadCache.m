function flag = loadCache (cacheFile, forceFresh, verTarget, updater)

  if ~exist('forceFresh', 'var')
    forceFresh = false;
  end
  if ~exist('verTarget', 'var')
    verTarget = 0;
  end
  if ~exist('updater', 'var')
    updater = [];
  end

  assignin('caller', 'version', verTarget);

  if forceFresh
    flag = 1;
    return;
  end

  if ~exist(cacheFile, 'file')
    flag = 2;
    return;
  end

  try
    cache = load(cacheFile);
  catch err
    disp(getReport(err));
    flag = 3;
    return;
  end

  if isfield(cache, 'version')
    verCur = cache.version;
  else
    verCur = 0;
  end
  if verCur < verTarget
    [pathstr, name, ext] = fileparts(cacheFile);
    fprintf('Updating cache %s from version %d to version %d: ', sprintf('%s%s', name, ext), verCur, verTarget);
    if ~isempty(updater)
      cache = updater(cache, verCur, verTarget);
    else
      cache = [];
    end
    if isempty(cache)
      fprintf('Failed\n');
      flag = 4;
      return;
    end
    fprintf('Successful\n');
    save(cacheFile, '-struct', 'cache', '-v7.3');
  end

  flag = 0;
  for fn = fieldnames(cache)'
    fn = fn{1};
    assignin('caller', fn, getfield(cache, fn));
  end

end
