clc;
close all;
clear all;

% initialize search path
dirs = {'conf', 'task', 'util', 'updater', 'data'};
addpath(dirs{:}, '-end');

% create directories
dirs = {'../figure', '../cached', '../log'};
for i = 1: length(dirs)
  if ~exist(dirs{i}, 'dir')
    mkdir(dirs{i});
  end
end
clear dirs i;

% construct tasks
initDataset;
initMethod;
initTask;
clear dataset* method*;

% initialize random generator
rng(floor(rem(now, 1) * 1e9));

% MATLAB pool initialization
if matlabpool('size') ~= getConst('MATLAB_POOL_NUM')
  if matlabpool('size') > 0
    matlabpool close;
  end
  if getConst('MATLAB_POOL_NUM') > 0
    matlabpool(getConst('MATLAB_POOL_NUM'));
  end
end
