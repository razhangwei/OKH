function [batchposhidprobs,vishid,visbiases,hidbiases] = rbmvislinear3(layer , batchdata , numhid, hidbias_offset )

% RBM version that implements the visible units being linear as opposed
% to the hidden ones as per the text below. 

% Version 1.000
%
% Code provided by Ruslan Salakhutdinov and Geoff Hinton
%
% Permission is granted for anyone to copy, use, modify, or distribute this
% program and accompanying programs and documents for any purpose, provided
% this copyright notice is retained and prominently displayed, along with
% a note saying that the original programs are available from our
% web page.
% The programs and documents are distributed without any warranty, express or
% implied.  As the programs were written for research purposes only, they have
% not been tested to the degree that would be advisable in any important
% application.  All use of these programs is entirely at the user's own risk.

% This program trains Restricted Boltzmann Machine in which
% visible, binary, stochastic pixels are connected to
% hidden, tochastic real-valued feature detectors drawn from a unit
% variance Gaussian whose mean is determined by the input from 
% the logistic visible units. Learning is done with 1-step Contrastive Divergence.

% Version modified by Rob Fergus. 11/14/07  

% Inputs:
% layer - hold initialization info. for parameters  
% batchdata -- the data that is divided into batches (numcases numdims numbatches)
% train - parameters of training (# epochs, learning rate etc.)
% numhid    -- number of hidden units 
% hidbias_offset -- sparsity term on hidden biases

% Outputs:
% batchposhidprobs - hidden layer activation probabilities (numcasesxnumdims x numbatches)
% vishid    -- weights (#visible x # hidden)
% visbiases -- (1 x # visible)
% hidbiases -- (1 x # hidden)  

  % Rob's comments to self:
    % 1. Learning rate needs to be a lot lower than binary units due to
    % lack of inbuilt regularization
    % 2. Leave sigma set to 1, a lower value binarizes weights. A higher
    % value smoothes them.
    % 3. Initilization of vishid seems to affect how many features are
    % learnt. 0.1 gives around 50% random, lower value picks up more
    % features, but having lower magnitude. This is due to random filters having zero mean
    % and the fact that the weights * hidden must be btw. 0 and 1 (since
    % image pixels are in that range). 
    % 4. Turned stocastic Gaussian sampling off. 
  
[numcases numdims numbatches]=size(batchdata);

%%%% 
epoch=1;

% Initializing symmetric weights and biases. 
% reset random number generator
rand('state',layer.randseed);

vishid     = single(layer.vishid_init*randn(numdims, numhid));
hidbiases  = single(layer.hidbiases_init*randn(1,numhid));
visbiases  = single(layer.visbiases_init*randn(1,numdims));

poshidprobs = zeros(numcases,numhid,'single');
neghidprobs = zeros(numcases,numhid,'single');
posprods    = zeros(numdims,numhid,'single');
negprods    = zeros(numdims,numhid,'single');
vishidinc  = zeros(numdims,numhid,'single');
hidbiasinc = zeros(1,numhid,'single');
visbiasinc = zeros(1,numdims,'single');
batchposhidprobs=zeros(numcases,numhid,numbatches,'single');


for epoch = epoch:layer.maxepoch,
 fprintf(1,'epoch %d\r',epoch); 
 errsum=0;
 
 for batch = 1:numbatches,
 fprintf(1,'epoch %d batch %d\r',epoch,batch);

 data = batchdata(:,:,batch);
 % precompute bias matrices
 visbiases_all =  (ones(numcases,1) * visbiases);
 hidbiases_all =  (ones(numcases,1) * hidbiases);
 
%%%%%%%%% START POSITIVE PHASE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hidden given visible - binary rule
  poshidprobs = 1./(1 + exp(-data*vishid - hidbiases_all + hidbias_offset));
  batchposhidprobs(:,:,batch)=poshidprobs;
  posprods    = data' * poshidprobs;
  poshidact   = sum(poshidprobs);
  posvisact = sum(data-visbiases_all);

%%%%%%%%% END OF POSITIVE PHASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  poshidstates = poshidprobs > rand(numcases,numhid);

%%%%%%%%% START NEGATIVE PHASE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visible given hidden - Gaussian

for i = 1:layer.numsamples
  negdata =   visbiases_all + (poshidstates*vishid'); 
  
  % hidden given visible - binary   
  neghidprobs = 1./(1 + exp( - negdata*vishid - hidbiases_all + hidbias_offset));    
  poshidstates = neghidprobs > rand(numcases,numhid);
end

  
  negprods  = negdata'*neghidprobs;
  neghidact = sum(neghidprobs);
  negvisact = sum(negdata-visbiases_all); 


%%%%%%%%% END OF NEGATIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  err= sum(sum( (data-negdata).^2 )); 
  errsum = err + errsum;
   if epoch>5,
     momentum=layer.finalmomentum;
   else
     momentum=layer.initialmomentum;
   end;

%%%%%%%%% UPDATE WEIGHTS AND BIASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vishidinc = momentum*(vishidinc) + (layer.epsilonw/numcases)*(posprods-negprods) - (layer.weightcost.*vishid);
    visbiasinc = momentum*visbiasinc + (layer.epsilonvb/numcases)*(posvisact-negvisact);
    hidbiasinc = momentum*hidbiasinc + (layer.epsilonhb/numcases)*(poshidact-neghidact);
    vishid = single(vishid + vishidinc);
    visbiases = single(visbiases + visbiasinc);
    hidbiases = single(hidbiases + hidbiasinc);

%%%%%%%%%%%%%%%% END OF UPDATES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 end
fprintf(1, 'epoch %4i error %f \n', epoch, errsum);



end
