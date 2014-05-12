function model=backprop5(model,data,NUM_EPOCHS)
 
  DEBUG = 0;
  MAX_ITS = 3;
  
  if (nargin==2)
    NUM_EPOCHS = 3; % default # epochs
  end
    
  
  if DEBUG
  
    debug_limit = [384,10,10,10,10,384];
    
    % Init weights
    % stack the weights together
    for a=1:model.numlayers
      model.backprop.weights{a} = single([model.layer(a).vishid(1:debug_limit(a),1:debug_limit(a+1))]);
      model.backprop.bias{a} = single([model.layer(a).hidbiases(1:debug_limit(a+1))]);
      model.backprop.dimensions(a,:) = size(model.backprop.weights{a}) + [1 0];
    end
  
    for a=model.numlayers:-1:1
      model.backprop.weights{2*model.numlayers-a+1} = single([model.layer(a).vishid(1:debug_limit(a),1:debug_limit(a+1))']);
      model.backprop.bias{2*model.numlayers-a+1} = single([model.layer(a).visbiases(1:debug_limit(a))]);
      model.backprop.dimensions(2*model.numlayers-a+1,:) = size(model.backprop.weights{2*model.numlayers-a+1}) + [1 0];
    end
   
  else

    if ~isfield(model,'backprop')
      for a=1:model.numlayers
        model.backprop.weights{a} = single([model.layer(a).vishid]);
        model.backprop.bias{a} = single([model.layer(a).hidbiases]);
        model.backprop.dimensions(a,:) = size(model.backprop.weights{a}) + [1 0];
      end
      
      for a=model.numlayers:-1:1
        model.backprop.weights{2*model.numlayers-a+1} = single([model.layer(a).vishid']);
        model.backprop.bias{2*model.numlayers-a+1} = single([model.layer(a).visbiases]);
        model.backprop.dimensions(2*model.numlayers-a+1,:) = size(model.backprop.weights{2*model.numlayers-a+1}) + [1 0];
      end
    else
      fprintf('Using existing backprop');
    end
    
  end
  
%   reshape into larger batches
  data.train = permute(data.train,[3 2 1]);
  data.train = data.train(:,:,1:2);
  
  data.numbatches = size(data.label_train,3);
 
  
  
  for epoch = 1:NUM_EPOCHS

     for batch = 1:data.numbatches
      
      % vectorize weights in network
      weight_vec = [];
      for a=1:model.numlayers*2
        tmp = [model.backprop.weights{a} ; model.backprop.bias{a}];
        weight_vec = [ weight_vec ; tmp(:)];
      end
      
     ss = prod(model.backprop.dimensions,2);
  
     if DEBUG
      
       %%% Check gradient routine
       [q,a,n]=checkgrad('CG_NCA_new',double(weight_vec(1:sum(ss(1:model.numlayers)))),1e-4,model.backprop.dimensions(1:model.numlayers,:),double(data.label_train(1:5,1:debug_limit(1),batch)),data.neigh(1:5,1:5,batch),model.arch.hidbias_offset,model.arch.hidlinear,model.arch.vislinear);
       figure; plot(a,'r'); hold on; plot(n,'b'); legend('Analytic','Numerical');
       keyboard
       % q is difference, a is analytic, n is numerical
           
     else
       
      [weight_vec_out,fX] = minimize(double(weight_vec(1:sum(ss(1:model.numlayers)))),'CG_NCA_new',MAX_ITS, model.backprop.dimensions(1:model.numlayers,:),double(data.label_train(:,:,batch)),data.neigh(:,:,batch),model.arch.hidbias_offset,model.arch.hidlinear,model.arch.vislinear);
     end
     
      weight_vec_out = [ weight_vec_out ; weight_vec(length(weight_vec_out)+1:end)];
      score(batch) = -fX(end);
  
      %%% decant vector of weights into matrices
      for i=1:model.numlayers*2
        
        if (i==1)
          prev_dims=0; 
        else
          prev_dims = sum(prod( model.backprop.dimensions(1:i-1,:),2));
        end
        
        tmp = weight_vec_out(prev_dims+1:prev_dims+prod( model.backprop.dimensions(i,:)));
        tmp = reshape(tmp, model.backprop.dimensions(i,:));
        model.backprop.weights{i} = tmp(1:end-1,:);
        
      end
      
      
    end
   fprintf('Epoch: %d, score: %f\n',epoch,sum(score));
     
    model.backprop.numepochs = epoch; 
  
    %% save model
    save(['/tmp/backprop_nca_',num2str(model.arch.numhid(end)),'_',num2str(round(model.layer(1).randseed(1)*1000))],'model');

  
  end
  
