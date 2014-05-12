% generate precision recall curves from cached results
function generateResultPrecisionRecall (task)

  % create sub-directories if necessary
  subdir = sprintf('../figure/%s', task.name);
  if ~exist(subdir, 'dir')
    mkdir(subdir);
  end

  for dataset = task.datasetList
    dataset = dataset{1};

    for ridx = 1: length(task.runTimes)
      rt = task.runTimes(ridx);
      for cidx = 1: length(task.codeLengths)
        codeLength = task.codeLengths(cidx);

        fprintf('Plotting precision recall curve for dataset %s (%d bits) (%d-th)\n', dataset.name, codeLength, rt);
        for midx = 1: length(task.methodList)
          method = task.methodList{midx};

          % load precision recall curve from cache
          cacheFile = sprintf('../cached/%s/%d/PrecisionRecall_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, task.forceFresh, getConst('CACHE_VER_PRECISION_RECALL'), @updaterPrecisionRecall)
            fprintf('  cache result missing for %s\n', method.name);
            precision = [];
            recall = [];
          end
          precH{midx} = precision;
          recH{midx} = recall;
        end

      % plot precision recall for each Hamming radius
      plotPrecisionRecall(precH, recH, task.methodList, sprintf('Precision Recall Curve (%s) (%d bits) (%d-th)', dataset.name, codeLength, rt), true);
      saveFigure(gcf, sprintf('../figure/%s/%d/PrecisionRecall_%s_%d', task.name, rt, dataset.name, codeLength));
      close gcf;

    end
  end

end
