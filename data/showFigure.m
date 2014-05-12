% make .fig files visible so that it can be opened by double-clicking
function showFigure (directory)

  figureList = ls2(sprintf('%s/*.fig', directory));
  for i = 1: length(figureList)
    figName = sprintf('%s/%s', directory, figureList{i});
    [~, name, ~] = fileparts(figName);
    fprintf('Showing file %s\n', name);
    openfig(figName, 'reuse', 'visible');
    saveas(gcf, figName);
    close(gcf);
  end

end
