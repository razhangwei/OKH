function [neighbors_out,t] = hashing3(train,test,dist)
%
% neighbors = hasing(train,test,dist)
%
% Function that uses binary hashing with hamming distances  
% to return NN in constant time
%
% Inputs:
%   1. train - nBytes x nTrain uint8 array
%   2. test  - nBytes x nTest uint8 array
%   3. dist  - 1 x 1 double
%  
% Output:
%   1. neighbors - MAX_RETURN x nTest uint32 array, holding indices of
%   neighbors in train for each test query.
%      (MAX_RETURN is #define at top of hash_ham3.cpp, it 
%      is the total number of neighbors returned).  
%   2. Time in sec to do lookup.
  
%     
% Compile command for MEX file:
%   mex hash_ham7.cpp
%
    
%%%% 
% Three stages of operation:
%  1. Build hash table
%  2. Lookup queries
%  3. Clear hash table from memory 

DEBUG = 1; % time lookup or not.  
  
% 1. Build hash table
flag = hash_ham6(train,dist);  


% 2. Lookup queries
if flag
  
  fprintf(1,'Querying hash table\n');
  
  tic; neighbors_out = hash_ham6(test); t=toc;
  
  if DEBUG
    fprintf(1,'Mean time per query: %3.1f usec\n\n',t/size(test,2)*1e6);
  end
  

  
  end
  
% 3. Clear hash table and linked-list nodes 
% from memory. Don't forget to do this, otherwise
% we will have an epic memory leak.
clear functions

