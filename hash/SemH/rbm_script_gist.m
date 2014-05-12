function [data, model] = rbm_script_gist(task, dataset, method, codeLength)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Unlabelled Data for pre-training
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %data.numimagestrain = 70000; % # training images 
    %data.batchsize = 100; % batch size
    %data.numbatches = data.numimagestrain/data.batchsize; % # batches
    %data.numimagestest = 2000; % # test images
    %data.usecolor = false;
    %data.size = sqrt(512); % use 512-dim. GIST vector. size of ONE SIDE of image (i.e # pixels/dims is data.size^2)
    
    data.batchsize = method.batchsize_pt;
    data.numbatches = floor(length(dataset.indexTrain) / data.batchsize);
    data.numimagestrain = data.batchsize * data.numbatches;
    data.numimagestest = length(dataset.indexTest);
    data.usecolor = false;
    if size(dataset.X, 2) ~= 512
        error('Not support feature type other than 512-D gist feature.');
    else
        data.size = sqrt(512);
    end

    %%%% Load in LabelMe data
    %load('LabelMe_gist','gist','ndxtrain','ndxtest');
    %gist_labelme = single(gist)'; 
    %ndxtrain_labelme = ndxtrain(1:20000);
    %ndxtest = ndxtest(1:data.numimagestest);

    %%%% Load in Peekaboom data
    %load('Peekaboom_gist','gist','ndxtrain');
    %ndxtrain_peekaboom = 20001 + ndxtrain(1:50000);
    %gist_peekaboom = single(gist)';

    %ndxtrain_all = [ndxtrain_labelme,ndxtrain_peekaboom];
    %ims = [gist_labelme, gist_peekaboom];

    %clear ndxtrain gist gist_peekaboom gist_labelme;

    ndxtrain_all = dataset.indexTrain(1 : data.numimagestrain);
    ndxtest = dataset.indexTest;
    ims = dataset.X';
    
     % randomly partition data into training and test
    % make batches
    for i=1:data.numbatches
      data.train(:,:,i) = ims(:, ndxtrain_all( (i-1) * data.batchsize + (1 : data.batchsize)))';
    end

    % make test set (one big batch)
    data.test = ims(:,ndxtest(1:data.numimagestest))';
    data.ndxtrain = ndxtrain_all;
    data.ndxtest = ndxtest;




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters & Architechture
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    model.arch = struct(...
        'numhid',[512 512 256 codeLength],... % number of hidden units in each layer
        'useconv', [false false false false],... % is each layer convolutional?...
        'convfiltersize', [5 0 0 0],... % if so, what is filter size...
        'vislinear', true ,... % does 1st visible layer use Gaussian outputs
        'hidlinear', false,...
        'hidbias_offset', 0,...
        'linearsigma', 1); % does final hidden layer use Gaussian outputs

    model.numlayers = size(model.arch.numhid,2);

    model.train = struct(...
        'maxepoch', [200 50 50 50],... % number of epochs to use
        'epsilonw', [0.001 0.1 0.1 0.1], ...% Learning rate for weights
        'epsilonvb', [0.001 0.1 0.1 0.1],... % Learning rate for biases of visible units
        'epsilonhb', [0.001 0.1 0.1 0.1], ... % Learning rate for biases of hidden units 
        'numsamples', [1 1 1 1], ... % # of CD samples
        'weightcost', 2e-5 * ones(1,model.numlayers),... % weight regularization
        'initialmomentum', 0.5 * ones(1,model.numlayers),... % momentum for first 5 epochs
        'finalmomentum', 0.9 * ones(1,model.numlayers)); % momentum after first 5 epochs



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialization (use essentially the same parameters as per Geoff's code)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:model.numlayers
      rand('state',sum(100*clock)); % store seed of random num generator  
      model.layer(i).randseed = rand('state');  
      model.layer(i).vishid_init = 0.1; % multipliers of zero mean, unit
                                        % variance Gaussian random initialization
      model.layer(i).visbiases_init = 0; % set to zero for zero initialization
      model.layer(i).hidbiases_init = 0;

      % copy in variables 
      model.layer(i).maxepoch = model.train.maxepoch(i);
      model.layer(i).epsilonw = model.train.epsilonw(i);
      model.layer(i).epsilonvb = model.train.epsilonvb(i);
      model.layer(i).epsilonhb = model.train.epsilonhb(i);
      model.layer(i).weightcost = model.train.weightcost(i);
      model.layer(i).initialmomentum = model.train.initialmomentum(i);
      model.layer(i).finalmomentum = model.train.finalmomentum(i);
      model.layer(i).numsamples = model.train.numsamples(i);

    end

end
