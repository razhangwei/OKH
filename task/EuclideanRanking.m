% evaluate the potential precision gain on a dataset by computing MAP of Euclidean ranking using the original feature vectors
function EuclideanRanking (task)

  for dataset = task.datasetList
    dataset = dataset{1};

    try
      fprintf('Performing Euclidean ranking evaluation task on %s\n', dataset.name);
      dataset = loadDataset(task, dataset);

      for codeLength = task.codeLengths

        nMethod = length(task.methodList);

        for midx = 1: nMethod
          method = task.methodList{midx};

          try

            % compute feature vectors
            fprintf('Computing feature vectors on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
            cacheFile = sprintf('%s/feature_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_FEATURE'))
              addpath(method.path);
              [X1, X2, timeTrain, timeTest] = method.feature(task, dataset, method, codeLength);
              rmpath(method.path);
              save(cacheFile, 'version', 'X1', 'X2', 'timeTrain', 'timeTest', '-v7.3');
            end
            fprintf('  Training time: %.4gs\n', timeTrain);
            fprintf('  Testing time: %.4gs\n', timeTest);

            % perform ranking using Euclidean distance of original feature vectors
            c1 = sprintf('%s/MAP_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            c2 = sprintf('%s/classifyPrec_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            f1 = loadCache(c1, task.forceFresh, getConst('CACHE_VER_MAP'), @updaterMAP);
            f2 = loadCache(c2, task.forceFresh, getConst('CACHE_VER_CLASSIFY_PREC'));
            if f1 || f2
              fprintf('Euclidean ranking on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
              cacheFile = sprintf('%s/EuclideanRanking_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
              if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_EUCLIDEAN_RANKING'))
                tp = timerStart();
                [distH, orderH] = calcEuclideanRank(X1, X2);
                timeCost = timerStop(tp);
                if getConst('EUCLIDEAN_RANKING_CACHE_RANKING')
                  save(cacheFile, 'version', 'distH', 'orderH', 'timeCost', '-v7.3');
                end
              end
              fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
              fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
            end

            % compute mean average precision (MAP)
            fprintf('Computing mean average precision (MAP) on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
            cacheFile = sprintf('%s/MAP_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_MAP'), @updaterMAP)
              tp = timerStart();
              [MAP, succRate] = calcMAP(orderH, dataset.neighborTest);
              timeCost = timerStop(tp);
              save(cacheFile, 'version', 'MAP', 'succRate', 'timeCost', '-v7.3');
            end
            fprintf('  MAP: %.4f\n', MAP);
            fprintf('  Success rate: %.4g\n', succRate);
            fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
            fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);

            % compute classification precision
            fprintf('Computing classification precision on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
            cacheFile = sprintf('%s/classifyPrec_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_CLASSIFY_PREC'))
              tp = timerStart();
              classifyPrec = calcClassifyPrec(orderH, dataset.neighborTest, task.classifyNumGuess);
              timeCost = timerStop(tp);
              save(cacheFile, 'version', 'classifyPrec', 'timeCost', '-v7.3');
            end
            fprintf('  Classification precision: %.4f\n', classifyPrec);
            fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
            fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);

          catch err
            reportError(err, sprintf('Error when performing evaluation task %s on dataset %s using %s (%d bits)\n', task.name, dataset.name, method.name, codeLength));
          end

        end

      end

      fprintf('\n\n');
    catch err
      reportError(err, sprintf('Error when performing Euclidean ranking evaluation task on %s\n', dataset.name));
    end

  end

end
