% plot bar result
function handle = plotBarResult (result, codeLengths, methodList, ylabelText, titleText, visible, showLegend)

  if ~exist('ylabelText', 'var')
    ylabelText = '';
  end
  if ~exist('titleText', 'var')
    titleText = '';
  end
  if ~exist('visible', 'var')
    visible = true;
  end
  if ~exist('showLegend', 'var')
    showLegend = true;
  end

  if visible
    handle = figure;
  else
    handle = figure('Visible', 'off');
  end
  NM = length(methodList);
  NC = length(codeLengths);
  mx = zeros(NC, NM);
  for cidx = 1: NC
    for midx = 1: NM
      rt = find(~isnan(result(:, cidx, midx)));
      res = result(rt, cidx, midx);
      mx(cidx, midx) = mean(res, 1);
    end
  end
  h = bar(mx);

  color = getConst('PLOT_COLOR');
  for cidx = 1: NC
    set(h(cidx), 'FaceColor', color{cidx});
  end

  if showLegend
    nameList = {};
    for midx = 1: length(methodList)
      nameList = [nameList methodList{midx}.name];
    end
    legend(nameList, 'Location', 'NorthEast', 'Orientation', 'vertical');
  end

  set(gca, 'XTickLabel', codeLengths);

  xlabel('Code Length');
  ylabel(ylabelText);
  title(titleText);

end
