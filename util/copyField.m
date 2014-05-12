% copy all fields in struct and into another struct
% Input:
%   s1: destination struct
%   s2: source struct
function s1 = copyField (s1, s2, overwrite)

  if ~exist('overwrite', 'var')
    overwrite = false;
  end

  fn = fieldnames(s2);
  for i = 1: length(fn)
    if ~isfield(s1, fn{i}) || overwrite
      s1 = setfield(s1, fn{i}, getfield(s2, fn{i}));
    end
  end

end
