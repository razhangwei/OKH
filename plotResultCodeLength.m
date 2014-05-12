% plot result along code length
function handle = plotResultCodeLength (result, codeLengths, nameList, showErrorbar, ylabelText, titleText, visible, showLegend)

  if ~exist('showErrorbar', 'var')
    showErrorbar = false;
  end
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

  % for legacy use of this function, where nameList is methodList
  if ~iscellstr(nameList)
    nameList = cellfun(@(S) S.name, nameList, 'UniformOutput', false);
  end

  if visible
    handle = figure;
  else
    handle = figure('Visible', 'off');
  end
  hold on;
  color = getConst('PLOT_COLOR');
  marker = getConst('PLOT_MARKER_SYMBOL');
  [NR, NC, NM] = size(result);
  for midx = 1: NM
    colorIdx = mod(midx - 1, length(color)) + 1;
    markerIdx = mod(midx - 1, length(marker)) + 1;
    mx = zeros(1, NC);
    vx = zeros(1, NC);
    for cidx = 1: NC
      rt = find(~isnan(result(:, cidx, midx)));
      res = result(rt, cidx, midx);
      mx(cidx) = mean(res, 1);
      vx(cidx) = std(res, 1, 1);
    end
    if showErrorbar
      errorbar(codeLengths, mx, vx, 'LineStyle', '-', 'LineWidth', 2, 'Marker', marker{markerIdx}, 'Color', color{colorIdx});
    else
      plot(codeLengths, mx, 'LineStyle', '-', 'LineWidth', 2, 'Marker', marker{markerIdx}, 'Color', color{colorIdx});
    end
  end
  hold off;

  if showLegend
    legend(nameList, 'Location', 'NorthOutside', 'Orientation', 'horizontal');
  end

  grid;
  set(gca, 'XTick', codeLengths);

  xlabel('Code Length');
  ylabel(ylabelText);
  title(titleText);

end
