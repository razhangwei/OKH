function parallelTest (maxWorker)

  matlabpool(maxWorker);

  timeEig = zeros(maxWorker + 1, 1);
  for M = 0: maxWorker
    timeEig(M + 1) = parallelEig(M);
  end

  figure;
  plot([0: maxWorker], timeEig, '-or');
  title('Performance of parallel workers');
  xlabel('# of workers used');
  ylabel('Total time');
  saveas(gcf, '../figure/parallelTest', 'fig');

  matlabpool close;

end
