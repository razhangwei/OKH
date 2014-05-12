function plotBarResultFML (result, codeLengths, ylabelText, titleText)

  figure;
  color = getConst('PLOT_COLOR');
  h = bar(result', 'FaceColor', color{1});
  set(gca, 'XTickLabel', [codeLengths, 6140]);
  xlabel('Code Length');
  ylabel(ylabelText);
  title(titleText);
  grid;
  saveFigure(gcf, sprintf('../figure/FML/%s', titleText));

end
