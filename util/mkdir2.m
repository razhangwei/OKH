% create dir if not exist
function mkdir2 (dir)

  if ~exist(dir, 'dir')
    mkdir(dir);
  end

end
