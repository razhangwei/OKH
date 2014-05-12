% perform feature scaling on dataset
function dataset = datasetfeatureScaling (dataset)

  X = dataset.X;

  for normF = dataset.normFilter
    normF = normF{1};
    X = normF(X);
  end

  dataset.X = X;

end
