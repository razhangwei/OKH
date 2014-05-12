% function to determine if on server side
function res = onServer (serverID)

  if ~exist('serverID', 'var')
    serverID = false;
  end

  if ~exist('../server', 'file')
    res = 0;
  else
    if ~serverID
      res = 1;
    else
      fid = fopen('../server');
      res = fscanf(fid, '%d');
      fclose(fid);
    end
  end

end
