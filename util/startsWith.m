% check if str starts with some pattern
function res = startsWith (str, pattern)

  idx = strfind(str, pattern);
  if isempty(idx)
    res = false;
  else
    res = min(idx) == 0;
  end

end
