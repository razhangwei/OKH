% generate result along code length from cached results
function generateResultHammingRanking (task)

  % create sub-directories if necessary
  mkdir2(sprintf('../figure/%s', task.name));

  for dataset = task.datasetList
    dataset = dataset{1};

    NR = length(task.runTimes);
    NC = length(task.codeLengths);
    NM = length(task.methodList);

    fprintf('Collecting data from dataset %s\n', dataset.name);
    MAPRes = NaN(NR, NC, NM);
    RecallRes = NaN(NR, NC, NM);
    TimeRes = NaN(NR, NC, NM);

    for midx = 1: NM
      method = task.methodList{midx};
      for cidx = 1: NC
        codeLength = task.codeLengths(cidx);
        for ridx = 1: NR
          rt = task.runTimes(ridx);

          cacheFile = sprintf('../cached/%s/%d/MAP_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_MAP'), @updaterMAP) == 0
            MAPRes(ridx, cidx, midx) = MAP;
          else
            fprintf('  MAP result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
          end

          cacheFile = sprintf('../cached/%s/%d/PrecisionRecall_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_PRECISION_RECALL'), @updaterPrecisionRecall) == 0
            RecallRes(ridx, cidx, midx) = recall(min(3, length(recall)));
          else
            fprintf('  Recall result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
          end

          cacheFile = sprintf('../cached/%s/%d/code_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_CODE')) == 0
            TimeRes(ridx, cidx, midx) = log10(timeTrain);
          else
            fprintf('  Time cache result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
          end

        end
      end
    end

    % plot MAP along code length
    fprintf('Plotting MAP along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(MAPRes, task.codeLengths, task.methodList, true, 'MAP', sprintf('MAP along code length (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/MAPCodeLength_%s', task.name, dataset.name));

    % plot recall along code length
    fprintf('Plotting recall along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(RecallRes, task.codeLengths, task.methodList, true, 'Recall within Hamming Radius 2', sprintf('Recall along code length (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/RecallCodeLength_%s', task.name, dataset.name));

    % plot training time along code length
    fprintf('Plotting training time along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(TimeRes, task.codeLengths, task.methodList, false, 'Log Training Time', sprintf('Training time along code length (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/TrainTimeCodeLength_%s', task.name, dataset.name));

  end

end
