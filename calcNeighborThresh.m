% calculate the threshold for defining the neighbors using Euclidean distance or affinity matrix.
function threshold = calcNeighborThresh (dataset)

  switch dataset.neighborType

    case 'dist'
      X = dataset.X;
      N = size(X, 1);
      N1 = length(dataset.indexTrain);
      if N <= getConst('NEIGHBOR_THRESH_CAP_N')
        D = calcEuDist(X);
        vecD = sort(D(:));
        G = dataset.aveNeighbor / N1 * (N - 1) + 1;
        threshold = vecD(round(G * N));
      else
        T = getConst('NEIGHBOR_THRESH_T');
        Ns = getConst('NEIGHBOR_THRESH_NS');
        threshold = 0;
        for i = 1: T
          Xs = X(randperm(N, Ns), :);
          D = calcEuDist(Xs);
          vecD = sort(D(:));
          G = dataset.aveNeighbor / N1 * (Ns - 1) + 1;
          threshold = threshold + vecD(round(G * Ns));
        end
        threshold = threshold / T;
      end

    case 'affinity'
      A = dataset.affinity;
      N = size(A, 1);
      N1 = length(dataset.indexTrain);
      vecA = sort(A(:), 'descend');
      G = dataset.aveNeighbor / N1 * (N - 1) + 1;
      threshold = full(vecA(round(G * N)));

    case 'value'
      N = size(dataset.X, 1);
      V = dataset.value;
      A = -abs(repmat(V, 1, N) - repmat(V', N, 1));
      N1 = length(dataset.indexTrain);
      vecA = sort(A(:), 'descend');
      G = dataset.aveNeighbor / N1 * (N - 1) + 1;
      threshold = full(vecA(round(G * N)));

  end

end
