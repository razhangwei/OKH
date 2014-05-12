function plotDiff (directoryList, namePattern, overwrite)

  if ~exist('overwrite', 'var')
    overwrite = false;
  end

  for directory = directoryList
    directory = directory{1};
    figureList = ls2(sprintf('../figure/%s/%s.fig', directory, namePattern));
    for i = 1: length(figureList)
      figName = sprintf('../figure/%s/%s', directory, figureList{i});
      [pathstr, name, ext] = fileparts(figName);
      if ~endsWith(name, '_diff')
        dstName = sprintf('%s/%s_diff', pathstr, name);
        if ~exist([dstName '.png'], 'file') || overwrite
          fprintf('Plotting diff for file %s\n', name);
          openfig(figName, 'reuse', 'invisible');
          v = get(findobj(gca, 'Type', 'line'), 'YData');
          close gcf;
          figure('Visible', 'off');
          plot(calcDiff2(v), '-or');
          ylim([0 5e-2]);
          grid;
          saveFigure(gcf, dstName);
          close gcf;
        end
      end
    end
  end

end

function d = calcDiff (v)

  WS = 5;
  n = length(v);
  for i = WS: n
    d(i) = var(v(i - WS + 1: i));
  end

end

function d = calcDiff2 (v)

  WS = 5;
  n = length(v);
  for i = WS: n
    vt = v(i - WS + 1: i);
    d(i) = max(vt) - min(vt);
  end

end
