function data=add_label_data2(task, dataset, method, data)

% MODE = 0 --- LabelMe
% MODE = 1 --- Caltech 101
% MODE = 2 --- Peekaboom
% MODE = 3 --- Tiny images (12.9 million)



% imgsize = data.size;
% 
% if isfield(data,'colors')
%     numcols = data.colors;
% else
%     numcols = 1;
%     
% end

% if (MODE==0)
%     load('LabelMe_gist','ndxtrain','ndxtest','nmat','gist');
%     ims = gist;
%     
%     nbatches = size(nmat,3);
%     batch_size = size(nmat,1);
%     
% elseif  (MODE==2) %% peekaboom
%     load('PeekaBoom32x32','ndxtrain','ndxtest','nmat','gist');
%     
%     ims = gist;
%     clear gist
%     nbatches = size(nmat,3);
%     batch_size = size(nmat,1);
%     
% elseif  (MODE==3) %% tiny images
%     
%     nbatches = 100;
%     
%     load('tiny_big_nmat','ndxtrain','nmat');
%     
%     batch_size = size(nmat,1);
%     nmat = nmat(:,:,1:nbatches);
%     
%     ims =  read_tiny_gist_binary([1:nbatches*batch_size])';
%     
%     ndxtest = 1;
%     
% else% MODE == 1
%     
%     load('caltech256_32x32','ndxtrain','ndxtest','nmat','category','folders');
%     
%     if (imgsize==sqrt(512))
%         tmp = load('torralba/caltech256_256x256_gist','gist');
%         ims = tmp.gist;
%     elseif (imgsize==32)
%         tmp = load('torralba/caltech256_32x32','img');
%         numcols=3;
%         ims = tmp.img;
%     else
%         error('foo');
%     end
%     
%     nbatches = 1;
%     batch_size = 7680;
%     
% end


% % zero mean, unit variance
% if (ndims(ims)==4)
%     numims = size(ims,4);
%     ims = single(reshape(ims,[numcols*imgsize^2 numims])');
% else
%     numims = size(ims,1);
% end

% ims = ims
% ims = ims - ones(numims,1)*mean(ims,1);
% ims = ims * (1/(mean(std(ims,0,1))));
ims = dataset.X;
batch_size = method.batchsize_bp;
nbatches = floor(data.numimagestrain / batch_size);
data.label_train = ims(data.ndxtrain(1 : nbatches * batch_size),:)';
data.label_train = permute(reshape(data.label_train,[size(data.label_train,1)  batch_size nbatches]),[2 1 3]);
%data.neigh = nmat;

data.label_test = ims(data.ndxtest,:);

%%%calculate the neigh
data.neigh = ones(batch_size, batch_size, nbatches);
for i = 1 : nbatches
    idx = batch_size * (i-1) + (1 : batch_size);
    idx = data.ndxtrain(idx);
    data.neigh(:, :, i) = calcNeighbor(dataset, idx);    
end
