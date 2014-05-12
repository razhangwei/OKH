% generate a dataset by random sampling from a larger dataset
function generateSub (Ns, fin, fout)

  if isempty(strfind(fin, '.mat'))
    fin = [fin '.mat'];
  end
  if isempty(strfind(fout, '.mat'))
    fout = [fout '.mat'];
  end

  datapath = '../data/';

  s = load([datapath fin]);
  N = size(s.X, 1);
  Ns = min(Ns, N);

  s2 = struct();
  idx = randperm(N, Ns);
  for f = fieldnames(s)'
    f = f{1};
    v = getfield(s, f);
    v = v(idx, :);
    s2 = setfield(s2, f, v);
  end

  save([datapath fout], '-struct', 's2');
  fprintf('subsampled %d data from %s to %s\n', Ns, fin, fout);

end
