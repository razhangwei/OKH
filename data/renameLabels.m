% batch rename labels to label of MAT files

dataFile = ...
{
  '../data/KSH-Demo/data',
  '../data/CIFAR-10/data',
  '../data/MNIST/data'
};

for i = 1: length(dataFile)
  load(dataFile{i});
  label = labels;
  save(dataFile{i}, 'X', 'label');
end

dataFile = '../data/CIFAR-100/data';
load(dataFile);
label = labels;
coarse_label = coarse_labels;
save(dataFile, 'X', 'label', 'coarse_label');
