% generate dataset of NP SIFT descriptors of the largest NC clusters from all the possible synsets of ImageNet
% save result to outname
function imageNetSIFT (NP, NC, outname)

  datapath = '../data-raw/ImageNet/';

  fid = fopen([datapath 'synset_list.txt']);
  synsetList = textscan(fid, '%s');
  synsetList = synsetList{1};
  fclose(fid);

  fprintf('checking available synsets...\n');
  NS = length(synsetList);
  available = false(NS, 1);
  for ti = 1: NS
    try
      load([datapath sprintf('sift/%s.vldsift.mat', synsetList{ti})]);
      available(ti) = true;
    catch err
    end
  end
  synsetList = synsetList(available);
  NS = length(synsetList); % number of currently downloaded synsets
  fprintf('number of available synsets: %d of 1000\n', NS);

  DT = zeros(NS, 1000); % number of descriptors in each synset
  for ti = 1: NS
    fprintf('calculating SIFT distribution of %s...\n', synsetList{ti});
    load([datapath sprintf('bow/%s.sbow.mat', synsetList{ti})]);
    for i = 1: length(image_sbow)
      DT(ti, :) = DT(ti, :) + hist(double(image_sbow(i).sbow.word), [0: 999]);
    end
  end
  D = sum(DT);
  [D, SC] = sort(D, 'descend');

  SC = SC(1: NC); % top-most distributed cluster indices
  D = D(1: NC);
  M = min(D(NC), floor(NP / NC)); % number of descriptors in each cluster
  DT = DT(:, SC);
  fprintf('number of descriptors in each cluster: %d\n', M);

  ST = floor(bsxfun(@rdivide, DT, D) * M); % number of descriptors to sample in each synset
  SR = M - sum(ST);
  RT = DT - ST;
  [~, SS] = sort(RT, 'descend');
  for ci = 1: NC
    Ri = SS(1: SR(ci), ci);
    ST(Ri, ci) = ST(Ri, ci) + 1;
  end

  X = zeros(M * NC, 128);
  label = zeros(NC * M, 1, 'uint16');
  NX = 0;
  for ti = 1: NS
    fprintf('sampling from %s...\n', synsetList{ti});
    load([datapath sprintf('bow/%s.sbow.mat', synsetList{ti})]);
    load([datapath sprintf('sift/%s.vldsift.mat', synsetList{ti})]);
    XT = [];
    LT = [];
    for i = 1: length(image_sbow)
      word = image_sbow(i).sbow.word + 1;
      desc = image_vldsift(i).vldsift.desc';
      [isTop, topIndex] = ismember(word, SC);
      XT = [XT; desc(isTop, :)];
      LT = [LT; topIndex(isTop)'];
    end
    [LT, SL] = sort(LT);
    XT = XT(SL, :);
    [LTC, PL, ~] = unique(LT, 'first');
    for i = 1: length(LTC)
      ci = LTC(i);
      p1 = PL(i);
      si = randperm(DT(ti, ci), ST(ti, ci)) - 1 + p1;
      X(NX + 1: NX + length(si), :) = XT(si, :);
      label(NX + 1: NX + length(si)) = LT(si);
      NX = NX + length(si);
    end
  end

  save(sprintf('../data/%s', outname), 'X', 'label', '-v7.3');

end
