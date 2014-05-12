% plot precision recall figure
function plotPrecisionRecall (precision, recall, methodList, titleText, visible, handle)

  if ~exist('titleText', 'var')
    titleText = 'Precision Recall Curve';
  end

  if ~exist('visible', 'var')
    visible = true;
  end

  if ~exist('handle', 'var')
    handle = [];
  end

  if isempty(handle)
    if visible
      figure;
    else
      figure('Visible', 'off');
    end
  else
    axes(handle);
  end

  hold on;
  color = getConst('PLOT_COLOR');
  marker = getConst('PLOT_MARKER_SYMBOL');
  for midx = 1: length(methodList)
    plot(recall{midx}, precision{midx}, 'LineStyle', '-', 'LineWidth', 2, 'Marker', marker{midx}, 'Color', color{midx});
  end
  hold off;

  % nameList = {};
  % for midx = 1: length(methodList)
  %   nameList = [nameList methodList{midx}.name];
  % end
  % legend(nameList, 'Location', 'NorthEast');

  xlim([0 1]);
  ylim([0 1]);
  grid;

  title(titleText);
  xlabel('Recall');
  ylabel('Precision');

end
