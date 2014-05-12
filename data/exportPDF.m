% export fig file to pdf format ready for importing into latex
function exportPDF (directory, filename, overwrite, PAGE_WIDTH, PAGE_HEIGHT)

  if ~exist('filename', 'var')
    filename = '*.fig';
  end
  if ~exist('overwrite', 'var')
    overwrite = false;
  end
  if ~exist('PAGE_WIDTH', 'var')
    PAGE_WIDTH = 5;
  end
  if ~exist('PAGE_HEIGHT', 'var')
    PAGE_HEIGHT = 4;
  end

  figureList = ls2(sprintf('%s/%s', directory, filename));
  for i = 1: length(figureList)
    figName = sprintf('%s/%s', directory, figureList{i});
    [pathstr, name, ext] = fileparts(figName);
    dstName = sprintf('%s/%s.pdf', pathstr, name);
    if ~exist(dstName, 'file') || overwrite
      fprintf('Converting file %s\n', name);

        % open fig file
        openfig(figName, 'reuse', 'invisible');
        gca;

        % remove title
        title([]);

        % make it tight
        % set(gca, 'Units', 'normalized');
        % ti = get(gca, 'TightInset');
        % set(gca, 'Position', [ti(1), ti(2), 1 - ti(1) - ti(3), 1 - ti(2) - ti(4)]);

        % adjust the papersize
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0, 0, PAGE_WIDTH, PAGE_HEIGHT]);
        set(gcf, 'PaperSize', [PAGE_WIDTH, PAGE_HEIGHT]);

        % save as pdf file
        saveas(gcf, dstName);
        close(gcf);

    end
  end

end
