% start a timer identified by a profile that will keep track of both the elapsed time and the CPU time
function profile = timerStart ()
  profile.tid = tic;
  profile.cputime = cputime;
end
