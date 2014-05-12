% prepare caches for dataset
function dataPrepare (task)

  for dataset = task.datasetList
    dataset = dataset{1};

    try
      fprintf('Preparing data for dataset %s\n', dataset.name);
      dataset = loadDataset(task, dataset);
      fprintf('\n\n');
    catch err
      reportError(err, sprintf('Error when preparing data for dataset %s\n', dataset.name));
    end

  end

end
