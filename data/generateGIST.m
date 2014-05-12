% generate 512-D GIST descriptors for CIFAR-10 dataset
function X = generateGIST (data)

  % parameter for LMgist
  param.imageSize = [32 32];
  param.orientationsPerScale = [8 8 8 8];
  param.numberBlocks = 4;
  param.fc_prefilt = 4;

  % compute GIST for each data point
  n = size(data, 1);
  X = zeros(n, 512);
  lp = 0;
  for i = 1: n
    % fprintf('computing %d\n', i);
    img = reshape(data(i, :), 32, 32, 3);
    X(i, :) = LMgist(img, '', param);

    cp = floor(i * 100 / n);
    if cp > lp
      lp = cp;
      fprintf('%d%% done\n', cp);
    end
  end

end
