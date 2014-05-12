dataname = cell(1, 6);
for j = 1: 5
  dataname{j} = sprintf('data_batch_%d', j);
end
dataname{6} = 'test_batch';

data_c = [];
labels_c = [];

for i = 1: length(dataname)
  load(['../data/CIFAR-10/raw/' dataname{i}], 'data', 'labels');
  data_c = [data_c; data];
  labels_c = [labels_c; labels];
end

data = data_c;
labels = labels_c;
save('../data/CIFAR-10/data0', 'data', 'labels');

clear;
