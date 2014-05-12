function codes = evaluate_rbm(model,data_in,CODE,BACKPROP,NLAYERS)

  if (nargin==2)
    CODE = 0; %%% do reconstruction
    BACKPROP = 1; %%% do backprop if we can
    NLAYERS = model.numlayers; % only applies if NOT doing backprop
  end
  
  if (nargin==3)
    BACKPROP = 1; %%% do backprop if we can
    NLAYERS = model.numlayers; % only applies if NOT doing backprop
  end

  if (nargin==4)
    NLAYERS = model.numlayers; % only applies if NOT doing backprop
  end
  
  NUMBATCHES = size(data_in,3);
  
  %fprintf('Using %d layers\n',NLAYERS);
  
  if BACKPROP & isfield(model,'backprop')
    %%%% do backprop code/reconstruction
    %fprintf('Using backprop weights\n');
    batchsize = size(data_in,1);

    if CODE
      % stop halfway
      numlayers = model.numlayers;
      data_out = zeros(batchsize,model.arch.numhid(end),NUMBATCHES);
    else
      numlayers = model.numlayers*2;
      data_out = zeros(size(data_in));
    end

         
    for j=1:NUMBATCHES
    
      data_tmp = data_in(:,:,j);

      for i = 1:numlayers
        if  ((i==1) & (model.arch.vislinear)) % Hiddens on Gaussian visible have bias term
          new_data_in = 1./(1 + exp(-data_tmp*model.backprop.weights{i} - ones(batchsize,1)*model.backprop.bias{i} + model.arch.hidbias_offset));
        elseif  ((i==model.numlayers*2) & (model.arch.vislinear)) %% Gaussian visible
          new_data_in = data_tmp*model.backprop.weights{i} + ones(batchsize,1)*model.backprop.bias{i};
        elseif ((i==model.numlayers) & (model.arch.hidlinear)) % Gaussian top level
          new_data_in = data_tmp*model.backprop.weights{i}+ones(batchsize,1)*model.backprop.bias{i};
        else
          new_data_in = 1./(1 + exp(-data_tmp*model.backprop.weights{i} - ones(batchsize,1)*model.backprop.bias{i}));
        end
        data_tmp = new_data_in;
      end
      
      data_out(:,:,j) = data_tmp;
      
    end
    
    data_in = data_out;
    
  else
    %%%% do pretraining code/reconstruction
    %fprintf('Using pre-training weights\n');

     
    % run up   
    for i = 1:NLAYERS
      hidbiases_all =  ones(size(data_in,1),1)*model.layer(i).hidbiases;
      
      new_data_in = zeros([size(data_in(:,:,1)*model.layer(i).vishid),NUMBATCHES]);
      
      if  ((i==1) & (model.arch.vislinear))
        
        for j = 1:NUMBATCHES
          new_data_in(:,:,j) = 1./(1 + exp(-data_in(:,:,j)*model.layer(i).vishid - hidbiases_all + model.arch.hidbias_offset));
        end
        
      elseif ((i==model.numlayers) & (model.arch.hidlinear))
        
        for j = 1:NUMBATCHES
          new_data_in(:,:,j) = data_in(:,:,j)*model.layer(i).vishid + hidbiases_all;
        end
        
      else
        for j = 1:NUMBATCHES
          new_data_in(:,:,j) = 1./(1 + exp(-data_in(:,:,j)*model.layer(i).vishid - hidbiases_all));
        end
      end
      
      
      data_in = new_data_in;
      
      
    end
  
    if (CODE==0) % i.e. do reconstruction
      
      for i = NLAYERS:-1:1
        visbiases_all =  ones(size(data_in,1),1)*model.layer(i).visbiases;
        new_data_in = zeros([size(data_in(:,:,1)*model.layer(i).vishid'),NUMBATCHES]);
        
        if  ((i==1) & (model.arch.vislinear))
          for j = 1:NUMBATCHES
            new_data_in(:,:,j) = data_in(:,:,j)*model.layer(i).vishid' + visbiases_all;
          end
        elseif ((i==model.numlayers) & (model.arch.hidlinear))
          for j = 1:NUMBATCHES
            new_data_in(:,:,j) = 1./(1 + exp(-data_in(:,:,j)*model.layer(i).vishid' - visbiases_all));
          end
        else
          for j = 1:NUMBATCHES
            new_data_in(:,:,j) = 1./(1 + exp(-data_in(:,:,j)*model.layer(i).vishid' - visbiases_all));
          end
        end
        data_in = new_data_in;
      
      end
    
      
    end
    
    
  end
  
   if (CODE)
    % now binarize
    
    %% fixed threshold for all bits
    %   codes = data_in < median(data_in(:));

   if isfield(model.backprop,'bit_thresholds')
      % pre-computed threshold
      codes = data_in < (ones(size(data_in,1),1) * model.backprop.bit_thresholds);
    else
      fprintf('Using on the fly bit threshold\n');
      % on-the-fly threshold
      codes = data_in < repmat(median(data_in,1),[size(data_in,1) 1]);
    end
    
  else
    codes = data_in;
  
  end
