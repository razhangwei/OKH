% check if str ends with some pattern
function res = endsWith (str, pattern)

  idx = strfind(str, pattern);
  if isempty(idx)
    res = false;
  else
    res = max(idx) + length(pattern) - 1 == length(str);
  end

end
