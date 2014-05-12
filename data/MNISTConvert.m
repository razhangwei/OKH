dataPath = '../data-raw/MNIST/';
imageName = {'train-images.idx3-ubyte', 't10k-images.idx3-ubyte'};
labelName = {'train-labels.idx1-ubyte', 't10k-labels.idx1-ubyte'};

X = [];
label = [];
for i = 1: length(imageName)
  Xs = readIDX([dataPath imageName{i}]);
  Xs = permute(Xs, [3 1 2]);
  Xs = reshape(Xs, size(Xs, 1), []);
  X = [X; Xs];
  label = [label; readIDX([dataPath labelName{i}])];
end

save('../data/MNIST', 'X', 'label');
