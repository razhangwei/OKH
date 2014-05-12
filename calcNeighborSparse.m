% calculate a logic matrix indicating whether a pair of items are neighbors.
function vR = calcNeighborSparse (dataset, Si, Sj)

  switch dataset.neighborType

    case 'dist'
      N = length(Si);
      D = size(dataset.X, 2);
      vR = false(N, 1);
      T = getConst('MEMORY_CAP');
      m = floor(T / (8 * D));
      p = 1;
      while p <= N
        t = min(p + m - 1, N);
        Sip = Si(p: t);
        Sjp = Sj(p: t);
        Pip = dataset.X(Sip, :);
        Pjp = dataset.X(Sjp, :);
        vDp = sqrt(sum((Pip - Pjp) .^ 2, 2));
        vR(p: t) = vDp <= dataset.neighborThreshold;
        p = p + m;
      end

    case 'affinity'
      N = size(dataset.X, 1);
      Ss = sub2ind([N, N], Si, Sj);
      vAf = dataset.affinity(Ss);
      vR = vAf >= dataset.neighborThreshold;

    case 'label'
      Li = dataset.label(Si);
      Lj = dataset.label(Sj);
      vR = Li == Lj;

    case 'tag'
      Ti = dataset.tag(Si, :);
      Tj = dataset.tag(Sj, :);
      vT = sum(Ti .* Tj, 2);
      vR = vT > 0;

  end

end
