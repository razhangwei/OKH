% evaluate methods through Hash lookup and report search precision within a specified Hamming radius and success rate
function hashLookup (task)

  for dataset = task.datasetList
    dataset = dataset{1};

    try
      fprintf('Performing hash lookup evaluation task on %s\n', dataset.name);
      dataset = loadDataset(task, dataset);

      for codeLength = task.codeLengths

        for midx = 1: length(task.methodList)

          method = task.methodList{midx};

          % compute binary codes
          fprintf('Computing binary codes on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
          cacheFile = sprintf('%s/code_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_CODE'))
            addpath(method.path);
            [B1, B2, timeTrain, timeTest] = method.hash(task, dataset, method, codeLength);
            rmpath(method.path);
            save(cacheFile, 'version', 'B1', 'B2', 'timeTrain', 'timeTest', '-v7.3');
          end
          fprintf('  Training time: %.4gs\n', timeTrain);
          fprintf('  Testing time: %.4gs\n', timeTest);

          fprintf('Computing mean precision and success rate for hash lookup within radius %d on dataset %s using %s (%d bits)\n', task.radius, dataset.name, method.name, codeLength);
          cacheFile = sprintf('%s/hashLookup%d_%s_%s_%d.mat', task.cacheDir, task.radius, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_HASH_LOOKUP'), @updaterHashLookup)
            tp = timerStart();
            [meanPrec, succRate] = evalHashLookup2(B1, B2, dataset.neighborTest, task.radius);
            timeCost = timerStop(tp);
            save(cacheFile, 'version', 'meanPrec', 'succRate', 'timeCost', '-v7.3');
          end
          fprintf('  Mean precision: %.4g\n', meanPrec);
          fprintf('  Success rate: %.4g\n', succRate);
          fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
          if (isfield(timeCost, 'ctime'))
            fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
          end

        end

      end

      fprintf('\n\n');
    catch err
      reportError(err, sprintf('Error when performing hash lookup evaluation task on %s\n', dataset.name));
    end

  end

end
