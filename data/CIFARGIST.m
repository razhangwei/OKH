load('../data/CIFAR-10/data0', 'data', 'label');
X = generateGIST(data);
save('../data/CIFAR-10/data', 'X', 'label');

load('../data/CIFAR-100/data0', 'data', 'fine_label', 'coarse_label');
X = generateGIST(data);
save('../data/CIFAR-100/data', 'X', 'fine_label', 'coarse_label');
