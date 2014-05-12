% end a timer started by timerStart and report the measured elapsed time and CPU time
function time = timerStop (profile)
  time.etime = toc(profile.tid);
  time.ctime = cputime - profile.cputime;
end
