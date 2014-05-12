function s = inheritField (s)

  if ~isfield(s, 'super')
    return;
  end

  if ~iscell(s.super)
    s.super = {s.super};
  end

  for p = s.super
    p = p{1};
    p = inheritField(p);
    s = copyField(s, p);
  end
  s = rmfield(s, 'super');

end
