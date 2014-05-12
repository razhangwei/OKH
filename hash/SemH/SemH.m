% A Semantic Hashing wrapper for preparing appropriate data for the core implementation
% Input:
%   dataset: a structure containing dataset info
%   method: a structure containing method info
%   codeLength: length of the binary codes
% Output:
%   B1: binary encoding of the trainning data
%   B2: binary encoding of the testing data
%   t1: training time
%   t2: testing time
function [B1, B2, t1, t2] = SemH (task, dataset, method, codeLength)

    %traindata = dataset.X(dataset.indexTrain, :);
    %testdata = dataset.X(dataset.indexTest, :);

    %N1 = size(traindata, 1);
    %method.numKernel = min(method.numKernel, N1);
    %method.numSample = min(method.numSample, N1);
    %indexKernel = randperm(N1, method.numKernel);
    %indexSample = randperm(N1, method.numSample);

    %R = codeLength;
    %Re = calcNeighbor(dataset, dataset.indexTrain(indexSample));
    %S = -ones(method.numSample);
    %S(Re) = 1;
    %S = S * R;

    %[B1, B2, t1, t2] = KSHCore(traindata, testdata, R, indexSample, indexKernel, S);
    
    
    
    t1 = tic;
    %%%pre-trainning
    [data1, model] = rbm_script_gist(task, dataset, method, codeLength);
    model = train_rbm(model, data1);
    %%%back-propagate
    data2 = add_label_data2(task, dataset, method, data1);
    model = backprop5(model, data2, 10); 
    t1 = toc(t1);
    
    t2 = tic;    

    code = evaluate_rbm(model, dataset.X, 1, 1);    
    %code = ndx2bit(uint8(code'),ones(size(code,2),1),8); %% covert from binary to uint8
    B1 = code(dataset.indexTrain, :);
    B2 = code(dataset.indexTest, :);
    t2 = toc(t2);    
end