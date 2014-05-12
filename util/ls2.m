% an ls wrapper that returns file names as a cell array independent of the operating system
function list2 = ls2 (name)

  list2 = {};

  try
    list = ls(name);
  catch err
    disp(getReport(err));
    return;
  end

  if size(list, 1) > 1 % on Windows
    for i = 1: size(list, 1)
      list2 = [list2 strtrim(list(i, :))];
    end
  else % on UNIX
    while true
      [token, list] = strtok(list);
      if isempty(token)
        break;
      end
      [pathstr, name, ext] = fileparts(token);
      token = [name ext];
      list2 = [list2 token];
    end
  end

end
