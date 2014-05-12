function saveFigure (handle, filename)
  saveas(handle, filename, 'fig');
  if ~onServer()
    saveas(handle, filename, 'png');
  end
end
