datapath = '../data/NUS-WIDE/raw/NUS-WIDE/';

% load low-level features
fprintf('loading low-level features\n');
featureFile = {'Normalized_CH', 'Normalized_CORR', 'Normalized_EDH', 'Normalized_WT', 'Normalized_CM55', 'BoW_int'};
X = [];
for i = 1: length(featureFile)
  fprintf('  %s\n', featureFile{i});
  X = [X dlmread([datapath sprintf('Features/%s.dat', featureFile{i})])];
end

% load concept list
fprintf('loading concept list\n');
fid = fopen([datapath 'ConceptList.txt']);
C = textscan(fid, '%s');
C = C{1};
fclose(fid);

% load concepts
fprintf('loading concepts\n');
tag = [];
for i = 1: length(C)
  fprintf('  %s\n', C{i});
  tag = [tag dlmread([datapath sprintf('Concepts/Labels_%s.txt', C{i})])];
end

% save the data
fprintf('saving data\n');
save('../data/NUS-WIDE/data', 'X', 'tag', '-v7.3');
