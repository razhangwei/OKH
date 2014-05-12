% rename a field of a struct
% Input:
%   s: struct
%   f1: original field name
%   f2: new field name
function s = renameField (s, f1, f2)
  s = setfield(s, f2, getfield(s, f1));
  s = rmfield(s, f1);
end
