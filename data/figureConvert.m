% batch-convert figures to png format
function figureConvert (directoryList, namePattern, overwrite)

  if ~exist('namePattern', 'var')
    namePattern = '*';
  end
  if ~exist('overwrite', 'var')
    overwrite = false;
  end

  for directory = directoryList
    directory = directory{1};
    figureList = ls2(sprintf('../figure/%s/%s.fig', directory, namePattern));
    for i = 1: length(figureList)
      figName = sprintf('../figure/%s/%s', directory, figureList{i});
      [pathstr, name, ext] = fileparts(figName);
      pngName = sprintf('%s/%s.png', pathstr, name);
      if ~exist(pngName, 'file') || overwrite
        fprintf('Converting file %s\n', name);
        handle = openfig(figName, 'reuse', 'invisible');
        saveas(handle, pngName);
        close(handle);
      end
    end
  end

end
