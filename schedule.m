% schedule tasks to run
function schedule (task)

  if task.profile
    profile('-memory', 'on');
  end

  for rt = task.runTimes

    try

      % create necessary directories
      task.cacheDir = sprintf('../cached/%s/%d', task.name, rt);
      task.dataDir = sprintf('../cached/DataPrepare/%d', rt);
      task.figureDir = sprintf('../figure/%s/%d', task.name, rt);
      mkdir2(task.cacheDir);
      mkdir2(task.dataDir);
      mkdir2(task.figureDir);

      % run evaluation
      fprintf('Running task %s (%d-th)\n', task.name, rt);
      task.run(task);

      % send notification
      sendEmail(sprintf('Finished task %s (%d-th)!', task.name, rt));

    catch err
      reportError(err, sprintf('Error when performing evaluation task %s (%d-th)\n', task.name, rt));
    end

  end

  if task.profile
    profile('off');
    if ~onServer()
      profreport;
    end
    fprintf('Generating profile report ...\n');
    profDir = sprintf('../prof/%s/%s', task.name, datestr(now, 'yyyymmddHHMMSSFFF'));
    mkdir2(profDir);
    profsave(profile('info'), profDir);
  end

end
