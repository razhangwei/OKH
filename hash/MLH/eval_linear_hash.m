function [p1 r1] = eval_linear_hash (W, data)

  B1 = W * [data.Xtraining; ones(1, data.Ntraining)] > 0;
  B2 = W * [data.Xtest; ones(1, data.Ntest)] > 0;
  B1 = compactbit(B1);
  B2 = compactbit(B2);

  Dhamm = hammDist_mex(B2, B1);

  [p1 r1] = evaluation3(data.StestTraining, Dhamm, size(W, 1));
  p1 = p1';

  p1 = full(p1);
  r1 = full(r1);

end
