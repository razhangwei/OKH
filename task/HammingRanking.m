% evaluate methods through Hamming ranking and draw precision-recall curves for each code length
function HammingRanking (task)

  for dataset = task.datasetList
    dataset = dataset{1};

    try
      fprintf('Performing Hamming ranking evaluation task on %s\n', dataset.name);
      dataset = loadDataset(task, dataset);

      for cidx = 1: length(task.codeLengths)
        codeLength = task.codeLengths(cidx);

        nMethod = length(task.methodList);
        precH = cell(1, nMethod);
        recH = cell(1, nMethod);

        for midx = 1: nMethod
          method = task.methodList{midx};

          try

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

            % perform ranking using Hamming distance
            c1 = sprintf('%s/PrecisionRecall_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            c2 = sprintf('%s/MAP_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            f1 = loadCache(c1, task.forceFresh, getConst('CACHE_VER_PRECISION_RECALL'), @updaterPrecisionRecall);
            f2 = loadCache(c2, task.forceFresh, getConst('CACHE_VER_MAP'), @updaterMAP);
            if f1 || f2
              fprintf('Hamming ranking on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
              cacheFile = sprintf('%s/HammingRanking_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
              if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_HAMMING_RANKING'), @updaterHammingRanking)
                tp = timerStart();
                [distH, orderH] = calcHammingRank(B1, B2);
                timeCost = timerStop(tp);
                if getConst('HAMMING_RANKING_CACHE_RANKING')
                  save(cacheFile, 'version', 'distH', 'orderH', 'timeCost', '-v7.3');
                end
              end
              fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
              if (isfield(timeCost, 'ctime'))
                fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
              end
            end

            % % compute precision recall for each Hamming radius
            % fprintf('Computing precision recall curve on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
            % cacheFile = sprintf('%s/PrecisionRecall_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            % if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_PRECISION_RECALL'), @updaterPrecisionRecall)
            %   tp = timerStart();
            %   [precision, recall] = calcHammingPrecisionRecall(orderH, distH, dataset.neighborTest);
            %   timeCost = timerStop(tp);
            %   save(cacheFile, 'version', 'precision', 'recall', 'timeCost', '-v7.3');
            % end
            % precH{midx} = precision;
            % recH{midx} = recall;
            % fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
            % if (isfield(timeCost, 'ctime'))
            %   fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
            % end

            % compute mean average precision (MAP)
            fprintf('Computing mean average precision (MAP) on dataset %s using %s (%d bits)\n', dataset.name, method.name, codeLength);
            cacheFile = sprintf('%s/MAP_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
            if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_MAP'), @updaterMAP)
              tp = timerStart();
              if strcmp(method.name, 'OKH')
                cacheMAPIter = sprintf('%s/MAPIter_%s_%s_%d.mat', task.cacheDir, dataset.name, method.name, codeLength);
                load(cacheMAPIter);                
                MAP = mean(MAPIter(NoIter > method.MAPThres)); 
              else
                [MAP, succRate] = calcMAP(orderH, dataset.neighborTest);
              end
              timeCost = timerStop(tp);
              save(cacheFile, 'version', 'MAP', 'succRate', 'timeCost', '-v7.3');
            end
            fprintf('  MAP: %.4f\n', MAP);
            fprintf('  Success rate: %.4g\n', succRate);
            fprintf('  Time cost (elapsed): %.4gs\n', timeCost.etime);
            if (isfield(timeCost, 'ctime'))
              fprintf('  Time cost (CPU): %.4gs\n', timeCost.ctime);
            end

          catch err
            reportError(err, sprintf('Error when performing evaluation task %s on dataset %s using %s (%d bits)\n', task.name, dataset.name, method.name, codeLength));
          end

        end

        % % plot precision recall for each Hamming radius
        % fprintf('Plotting precision recall curve for dataset %s (%d bits)\n', dataset.name, codeLength);
        % plotPrecisionRecall(precH, recH, task.methodList, sprintf('Precision Recall Curve (%s) (%d bits)', dataset.name, codeLength), true);
        % saveFigure(gcf, sprintf('%s/PrecisionRecall_%s_%d', task.figureDir, dataset.name, codeLength));

      end

      fprintf('\n\n');

    catch err
      reportError(err, sprintf('Error when performing Hamming ranking evaluation task on %s\n', dataset.name));
    end

  end

end
