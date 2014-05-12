% combine data of SIFT-1M and store in MAT-file

datapath = '../data/SIFT-1M/raw/';
dataname = {'sift_base.fvecs', 'sift_learn.fvecs', 'sift_query.fvecs'};

X = [];
for i = 1: length(dataname)
  X = [X; fvecs_read([datapath dataname{i}])'];
end

save('../data/SIFT-1M/data', 'X');
