function model_out = train_rbm( model , data )
  %
  % model_out = train_rbm ( model , data )
  % 
  % Function to perform unsupervised training of RBM model  
  %  
  % Inputs: 
  %     1. model - structure holding all the parameters and
  %     initializations of the RBM variables.
  %     2. data - block of training data (nImages x nDims double)
  %
  % Outputs: 
  %     1. model_out - structure holding trained RBM
  %
  
  % %%%%%%%%%%%%%%%%%%%%%%%% 
  % Setup for first loop
  % %%%%%%%%%%%%%%%%%%%%%%%%
  data_in = data.train;  
    
  % %%%%%%%%%%%%%%%%%%%%%%%% 
  % Main RBM training loop
  % %%%%%%%%%%%%%%%%%%%%%%%%
  
  for i = 1:model.numlayers  
    
    % has this layer already been trained?
    if (~isfield(model.layer(i),'vishid') | isempty(model.layer(i).vishid))
        
      % what type of rbm is this layer?
      
      if model.arch.useconv(i)
        % convolutional layer
        if (data.usecolor)
          [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbm_conv4(model.layer(i),data_in,model.arch.numhid(i),model.arch.convfiltersize(i));
        else
          [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbm_conv3(model.layer(i),data_in,model.arch.numhid(i),model.arch.convfiltersize(i));
        end
      else
        % fully connected layer
        
        if ((i==1) & (model.arch.vislinear))
          % Gaussian visible units
          fprintf(1,'\nPretraining Layer %d with RBM having Gaussian visible units: %d-%d, %d epochs\n',i,size(data_in,2),model.arch.numhid(i),model.layer(i).maxepoch);
          [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbmvislinear3(model.layer(i),data_in,model.arch.numhid(i),model.arch.hidbias_offset);
          
        elseif ((i==model.numlayers) & (model.arch.hidlinear))
          % Gaussian hidden units
          % standard binary rbm
          fprintf(1,'\nPretraining Layer %d with RBM having linear hidden layer: %d-%d, %d epochs\n',i,size(data_in,2),model.arch.numhid(i),model.layer(i).maxepoch);
          [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbmhidlinear(model.layer(i),data_in,model.arch.numhid(i));

        else
          % standard binary rbm
          if isstr(data_in)
            fprintf(1,'\nPretraining Layer %d with standard RBM with disk data access: %d-%d, %d epochs\n',i,size(data_in,2),model.arch.numhid(i),model.layer(i).maxepoch);
            [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbm3(model.layer(i),data_in,model.arch.numhid(i)); else
            fprintf(1,'\nPretraining Layer %d with standard RBM: %d-%d, %d epochs\n',i,size(data_in,2),model.arch.numhid(i),model.layer(i).maxepoch);
            [model.layer(i).batchposhidprobs,model.layer(i).vishid,model.layer(i).visbiases,model.layer(i).hidbiases] = rbm2(model.layer(i),data_in,model.arch.numhid(i));
          end
        end
      
      end
     
      % save out model
      save(['/tmp/model_',num2str(round(model.layer(1).randseed(1)*1000)),'_',num2str(i)],'model');
      
      
    end
    
    if ~isstr(data.train)  
      % make hidden layer probabs. the visible data for next layer up in RBM  
      data_in = model.layer(i).batchposhidprobs;
    end
    
  end

  % output
  model_out = model;
