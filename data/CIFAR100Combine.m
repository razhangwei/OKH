dataname = {'train', 'test'};

data_c = [];
fine_labels_c = [];
coarse_labels_c = [];

for i = 1: length(dataname)
  load(['../data/CIFAR-100/raw/' dataname{i}], 'data', 'fine_labels', 'coarse_labels');
  data_c = [data_c; data];
  fine_labels_c = [fine_labels_c; fine_labels];
  coarse_labels_c = [coarse_labels_c; coarse_labels];
end

data = data_c;
fine_labels = fine_labels_c;
coarse_labels = coarse_labels_c;
save('../data/CIFAR-100/data0', 'data', 'fine_labels', 'coarse_labels');

clear;
