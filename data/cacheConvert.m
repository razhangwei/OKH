% batch-convert cached results
function cacheConvert (directoryList, namePattern, converter)

  if ~exist('namePattern', 'var')
    namePattern = '*';
  end

  for directory = directoryList
    directory = directory{1};
    figureList = ls2(sprintf('../cached/%s/%s.mat', directory, namePattern));
    for i = 1: length(figureList)
      fn = sprintf('../cached/%s/%s', directory, figureList{i});
      [pathstr, name, ext] = fileparts(fn);
      fprintf('Converting file %s\n', name);
      cache = load(fn);
      cache = converter(cache);
      save(fn, '-struct', 'cache');
    end
  end

end
