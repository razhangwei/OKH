% generate result for classification from cached results
function generateResultClassification (task)

  % create sub-directories if necessary
  mkdir2(sprintf('../figure/%s', task.name));

  for dataset = task.datasetList
    dataset = dataset{1};
    for classifier = task.classifierList
      classifier = classifier{1};

      NR = length(task.runTimes);
      NC = length(task.codeLengths);
      NM = length(task.methodList);

      fprintf('Collecting data from dataset %s with classifier %s\n', dataset.name, classifier.name);
      AccuracyRes = NaN(NR, NC, NM);
      SuccRateRes = NaN(NR, NC, NM);

      for midx = 1: NM
        method = task.methodList{midx};
        for cidx = 1: NC
          codeLength = task.codeLengths(cidx);
          for ridx = 1: NR
            rt = task.runTimes(ridx);

            cacheFile = sprintf('../cached/%s/%d/hashClassification_%s_%s_%s_%d.mat', task.name, rt, dataset.name, method.name, classifier.name, codeLength);
            if loadCache(cacheFile, false, getConst('CACHE_VER_HASH_CLASSIFICATION')) == 0
              AccuracyRes(ridx, cidx, midx) = correctRate;
              SuccRateRes(ridx, cidx, midx) = succRate;
            else
              fprintf('  Hash classificatioin result missing for %s (%d bit) (%d-th)\n', method.name, codeLength, rt);
            end

          end
        end
      end

      % plot prediction accuracy along code length
      fprintf('Plotting prediction accuracy along code length for dataset %s with classifier %s\n', dataset.name, classifier.name);
      plotResultCodeLength(AccuracyRes, task.codeLengths, task.methodList, true, 'Prediction Accuracy', sprintf('Prediction accuracy along code length (%s, %s)', dataset.name, classifier.name));
      saveFigure(gcf, sprintf('../figure/%s/PredictCodeLength_%s_%s', task.name, dataset.name, classifier.name));

      % plot success rate along code length
      fprintf('Plotting success rate along code length for dataset %s with classifier %s\n', dataset.name, classifier.name);
      plotResultCodeLength(SuccRateRes, task.codeLengths, task.methodList, true, 'Success Rate', sprintf('Success rate along code length (%s, %s)', dataset.name, classifier.name));
      saveFigure(gcf, sprintf('../figure/%s/SuccCodeLength_%s_%s', task.name, dataset.name, classifier.name));

    end
  end

end
