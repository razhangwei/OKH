function [AveRMSE, AveTime] = generateResultFML (task)

  NR = length(task.runTimes);
  NC = length(task.codeLengths);
  RMSERes = NaN(NR, NC);
  TimeRes = NaN(NR, NC);

  dataset = task.datasetList{1};
  method = task.methodList{1};
  regresser = task.regresserList{1};
  for cidx = 1: NC
    codeLength = task.codeLengths(cidx);
    for ridx = 1: NR
      rt = task.runTimes(ridx);
      cacheFile = sprintf('../cached/%s/%d/hashRegression_%s_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, regresser.name, codeLength);
      if loadCache(cacheFile, false, getConst('CACHE_VER_HASH_REGRESSION')) == 0
        RMSERes(ridx, cidx) = RMSE;
        TimeRes(ridx, cidx) = timeCost.etime;
      else
        fprintf('  Result missing for (%s-%s) (%d bit) (%d-th)\n', method.name, regresser.name, codeLength, rt);
      end
    end
  end

  AveRMSE = mean(RMSERes);
  AveTime = mean(TimeRes);

end
