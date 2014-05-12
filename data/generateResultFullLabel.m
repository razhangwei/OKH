% generate bar result from cached results
function generateResultFullLabel (task)

  % create sub-directories if necessary
  mkdir2(sprintf('../figure/%s', task.name));

  for dataset = task.datasetList
    dataset = dataset{1};

    NR = length(task.runTimes);
    NC = length(task.codeLengths);
    NM = length(task.methodList);

    fprintf('Collecting data from dataset %s\n', dataset.name);
    MAPRes = NaN(NR, NC, NM);
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

          cacheFile = sprintf('../cached/%s/%d/code_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_CODE')) == 0
            TimeRes(ridx, cidx, midx) = log10(timeTrain);
          else
            fprintf('  Time cache result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
          end

        end
      end
    end

    % plot MAP bar
    fprintf('Plotting MAP bar for dataset %s\n', dataset.name);
    plotBarResult(MAPRes, task.codeLengths, task.methodList, 'MAP', sprintf('MAP bar (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/MAPBar_%s', task.name, dataset.name));

    % plot training time bar
    fprintf('Plotting training time bar for dataset %s\n', dataset.name);
    plotBarResult(TimeRes, task.codeLengths, task.methodList, 'Log Training Time', sprintf('Training time bar (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/TimeBar_%s', task.name, dataset.name));

  end

end
