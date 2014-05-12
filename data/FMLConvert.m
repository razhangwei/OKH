data = dlmread(['../data-raw/FML/post_feature.txt']);

X = data(:, 4: end);
value_agree = data(:, 1);
value_deserve = data(:, 2);
value_comment = data(:, 3);

N = size(X, 1);

[~, idx] = sort(value_agree);
label_agree = zeros(N, 1);
label_agree(idx(floor(N / 2) + 1: end)) = 1;

[~, idx] = sort(value_deserve);
label_deserve = zeros(N, 1);
label_deserve(idx(floor(N / 2) + 1: end)) = 1;

[~, idx] = sort(value_comment);
label_comment = zeros(N, 1);
label_comment(idx(floor(N / 2) + 1: end)) = 1;

save('../data/FML', 'X', 'value_agree', 'value_deserve', 'value_comment', 'label_agree', 'label_deserve', 'label_comment', '-v7.3');
