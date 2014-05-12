% generate ImageNet dataset using BOW information, each image is represented as the distribution of the kind of its SIFT descriptors
function imageNetBOW ()

  datapath = '../data-raw/ImageNet/';

  fid = fopen([datapath 'synset_list.txt']);
  synsetList = textscan(fid, '%s');
  synsetList = synsetList{1};
  fclose(fid);

  X = [];
  label = [];
  for ti = 1: length(synsetList)
    fprintf('converting %s...\n', synsetList{ti});
    load([datapath sprintf('bow/%s.sbow.mat', synsetList{ti})]);
    n = length(image_sbow);
    Xt = zeros(n, 1000, 'uint16');
    for i = 1: n
      Xt(i, :) = hist(double(image_sbow(i).sbow.word), [0: 999]);
    end
    X = [X; Xt];
    label = [label; uint16(repmat([ti], n, 1))];
  end

  save('../data/ImageNet-BOW', 'X', 'label', '-v7.3');

end
