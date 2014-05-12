function mergeResult (task)

  MAPRes = zeros(length(task.runTimes), length(task.codeLengths), length(task.methodList), length(task.datasetList));
  TimeRes = zeros(length(task.runTimes), length(task.codeLengths), length(task.methodList), length(task.datasetList));

  fprintf('Collecting data ...\n');
  for didx = 1: length(task.datasetList)
    dataset = task.datasetList{didx};
    for midx = 1: length(task.methodList)
      method = task.methodList{midx};
      for cidx = 1: length(task.codeLengths)
        codeLength = task.codeLengths(cidx);
        for ridx = 1: length(task.runTimes)
          rt = task.runTimes(ridx);

          cacheFile = sprintf('../cached/%s/%d/MAP_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_MAP'), @updaterMAP)
            fprintf('  MAP result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
            MAP = 0;
          end
          MAPRes(ridx, cidx, midx, didx) = MAP;

          cacheFile = sprintf('../cached/%s/%d/code_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_CODE'))
            fprintf('  Time cache result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
            timeTrain = 0;
          end
          TimeRes(ridx, cidx, midx, didx) = timeTrain;

        end
      end
    end
  end

  fprintf('Result for MAP:\n');
  for cidx = 1: length(task.codeLengths)
    codeLength = task.codeLengths(cidx);
    fprintf('Code length: %d\n', codeLength);
    fprintf('\t');
    for midx = 1: length(task.methodList)
      method = task.methodList{midx};
      fprintf('%s', method.name);
      if midx < length(task.methodList)
        fprintf('\t');
      else
        fprintf('\n');
      end
    end
    for didx = 1: length(task.datasetList)
      dataset = task.datasetList{didx};
      fprintf('%s\t', dataset.name);
      for midx = 1: length(task.methodList)
        method = task.methodList{midx};
        fprintf('%.4f', mean(MAPRes(:, cidx, midx, didx)));
        if midx < length(task.methodList)
          fprintf('\t');
        else
          fprintf('\n');
        end
      end
    end
    fprintf('\n');
  end

  fprintf('Result for Time:\n');
  for cidx = 1: length(task.codeLengths)
    codeLength = task.codeLengths(cidx);
    fprintf('Code length: %d\n', codeLength);
    fprintf('\t');
    for midx = 1: length(task.methodList)
      method = task.methodList{midx};
      fprintf('%s', method.name);
      if midx < length(task.methodList)
        fprintf('\t');
      else
        fprintf('\n');
      end
    end
    for didx = 1: length(task.datasetList)
      dataset = task.datasetList{didx};
      fprintf('%s\t', dataset.name);
      for midx = 1: length(task.methodList)
        method = task.methodList{midx};
        fprintf('%.4f', mean(TimeRes(:, cidx, midx, didx)));
        if midx < length(task.methodList)
          fprintf('\t');
        else
          fprintf('\n');
        end
      end
    end
    fprintf('\n');
  end

end
