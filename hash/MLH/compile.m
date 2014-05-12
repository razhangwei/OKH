% if you don't have -fopenmp option, just remove it, and you will lose multicore functionality, but that should be fine.
mex loss_adj_inf_mex.cpp CXXFLAGS="\$CXXFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp";
mex hammDist_mex.cpp;
mex accumarray_reverse.cpp;
