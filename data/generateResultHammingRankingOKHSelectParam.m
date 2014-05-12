% generate result along code length from cached results
function generateResultHammingRankingOKHSelectParam (task)

  % create sub-directories if necessary
  mkdir2(sprintf('../figure/%s', task.name));

  for dataset = task.datasetList
    dataset = dataset{1};

    fprintf('Collecting data from dataset %s\n', dataset.name);
    
    for paramName = task.selectParam

      MAPRes = [];   
      paramName = paramName{1};
      paramValue = getfield(task, [paramName,'Set']);
      LegendName = cell(1, length(paramValue));
      for vidx = 1 : length(paramValue)

        LegendName{vidx} = sprintf('%s=%g', paramName, paramValue(vidx));
        for ridx = 1 : length(task.runTimes)

          cacheDir = sprintf('../cached/%s/%d', task.name, task.runTimes(ridx));
          cacheFile = sprintf('%s/%s_%s_%g.mat', cacheDir, dataset.name, paramName, paramValue(vidx) );

          if loadCache(cacheFile, false) == 0            
            if length(MAPRes) == 0 
              MAPRes = NaN(length(task.selectParam), length(extra.MAPIter),  length(paramValue) );
            end
            MAPRes(ridx, :, vidx) = extra.MAPIter;
          end      
        end        
      end
      
      % plot MAP along each iteration
      fprintf('Plotting MAP along iterations for dataset %s and paramter %s \n', dataset.name, paramName);
      plotResultCodeLength(MAPRes, extra.NoIter, LegendName, true, 'MAP', sprintf('Effect of %s on dataset %s', paramName, dataset.name));
      saveFigure(gcf, sprintf('../figure/%s/%s_%s', task.name, dataset.name, paramName));
    end

  end

end
