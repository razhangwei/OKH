% generate result along code length from cached results for Hash regression
function generateResultRegression (task)

  % create sub-directories if necessary
  mkdir2(sprintf('../figure/%s', task.name));

  for dataset = task.datasetList
    dataset = dataset{1};

    NR = length(task.runTimes);
    NC = length(task.codeLengths);
    NG = length(task.regresserList);
    NM = length(task.methodList);

    fprintf('Collecting data from dataset %s\n', dataset.name);
    nameMethodRegresser = cell(NG, NM);
    RMSERes = NaN(NR, NC, NG, NM);
    succRateRes = NaN(NR, NC, NG, NM);
    TimeRes = NaN(NR, NC, NM);

    for midx = 1: NM
      method = task.methodList{midx};

      for gidx = 1: NG
        regresser = task.regresserList{gidx};
        nameMethodRegresser{gidx, midx} = [method.name '@' regresser.name];
        for cidx = 1: NC
          codeLength = task.codeLengths(cidx);
          for ridx = 1: NR
            rt = task.runTimes(ridx);
            cacheFile = sprintf('../cached/%s/%d/hashRegression_%s_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, regresser.name, codeLength);
            if loadCache(cacheFile, false, getConst('CACHE_VER_HASH_REGRESSION')) == 0
              RMSERes(ridx, cidx, gidx, midx) = RMSE;
              succRateRes(ridx, cidx, gidx, midx) = succRate;
            else
              fprintf('  Regression result missing for (%s-%s) (%d bit) (%d-th)\n', method.name, regresser.name, codeLength, rt);
            end
          end
        end
      end

      for cidx = 1: NC
        codeLength = task.codeLengths(cidx);
        for ridx = 1: NR
          rt = task.runTimes(ridx);
          cacheFile = sprintf('../cached/%s/%d/code_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, codeLength);
          if loadCache(cacheFile, false, getConst('CACHE_VER_CODE')) == 0
            TimeRes(ridx, cidx, midx) = log10(timeTrain);
          else
            fprintf('  Training time result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
          end
        end
      end

    end

    nameMethodRegresser = reshape(nameMethodRegresser, [NG * NM, 1]);
    RMSERes = reshape(RMSERes, [NR, NC, NG * NM]);
    succRateRes = reshape(succRateRes, [NR, NC, NG * NM]);

    % plot RMSE along code length
    fprintf('Plotting RMSE along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(RMSERes, task.codeLengths, nameMethodRegresser, false, 'Root Mean Squared Error', sprintf('RMSE along code length (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/RMSECodeLength_%s', task.name, dataset.name));

    % plot succRate along code length
    fprintf('Plotting succRate along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(succRateRes, task.codeLengths, nameMethodRegresser, false, 'Success Rate', sprintf('Success Rate along code length (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/succRateCodeLength_%s', task.name, dataset.name));

    % plot training time along code length
    fprintf('Plotting training time along code length for dataset %s\n', dataset.name);
    plotResultCodeLength(TimeRes, task.codeLengths, task.methodList, false, 'Log Training Time', sprintf('Training time (%s)', dataset.name));
    saveFigure(gcf, sprintf('../figure/%s/TrainTimeCodeLength_%s', task.name, dataset.name));

  end

end
