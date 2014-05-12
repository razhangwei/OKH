% evaluate methods through Hamming ranking and draw precision-recall curves for each code length
function HammingRanking (task)

  for dataset = task.datasetList
    dataset = dataset{1};
    method = task.method;

    try
      fprintf('Evaluating effect of different parameters of %s on %s\n', method.name, dataset.name);
      dataset = loadDataset(task, dataset);

      for paramIdx =1 : length(task.selectParam)
        try 
          paramName = task.selectParam{paramIdx};
          if ~isfield(task, [paramName, 'Set'])
            error('the candidate values for parameter %s are missing.', paramName);
          else
            paramValue = getfield(task, [paramName, 'Set']);
          end          

          for valueIdx = 1 : length(paramValue)           
            
            taskV = task;
            methodV = method;
            if strcmp(paramName, 'codeLength')            
              taskV.codeLength = paramValue(valueIdx);
            else
              methodV = setfield(methodV, paramName, paramValue(valueIdx));
            end
            
            % reset the random generator so that each initial random
            % projecttion matrix will keep the same
            rng('default');

            % train the model and evaluate on certain steps
            fprintf('Train the model on dataset %s with %s=%g\n', dataset.name, paramName, paramValue(valueIdx) );
            cacheFile = sprintf('%s/%s_%s_%g.mat', task.cacheDir, dataset.name, paramName, paramValue(valueIdx) );
            if loadCache(cacheFile, task.forceFresh)
              addpath(method.path);
              [~, ~, timeTrain, timeTest, extra] = method.hash(task, dataset, methodV, taskV.codeLength);
              rmpath(method.path);
              save(cacheFile, 'version', 'timeTrain', 'timeTest', 'extra', '-v7.3');
            end
            fprintf('  Training time: %.4gs\n', timeTrain);
            fprintf('  Testing time: %.4gs\n', timeTest);

          end
          
          fprintf('\n\n');
        catch err
          reportError(err, sprintf('Error when evaluating effect of %s on dataset %s\n', paramName, dataset.name));
        end  
      end

    catch err
      reportError(err, sprintf('Error when performing Hamming ranking evaluation task on %s\n', dataset.name));
    end

  end

end
