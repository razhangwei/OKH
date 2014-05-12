% Random projection method by "Moses Charikar" which preserves cosine similarity
% reference: Similarity estimation techniques from rounding algorithms, M. Charikar, STOC 2002
function [p0 r0] = eval_LSH (nbits, data);

  W = [randn(nbits, size(data.Xtraining, 1)) zeros(nbits, 1)];
  [p0 r0] = eval_linear_hash(W, data);

end
