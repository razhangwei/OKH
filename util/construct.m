% a tool to build a struct using a single command
function s = construct (varargin)
  s = struct;
  i = 1;
  while i <= length(varargin)
    s = setfield(s, varargin{i}, varargin{i + 1});
    i = i + 2;
  end
end
