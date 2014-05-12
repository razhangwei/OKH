function [f,df] =  CG_NCA_new(weights_vec,dimensions,data,neighbors,hidbias_offset,hidlinear,vislinear);

  SIGMA = 1;
  
  %%% symmetrizes the neighborhhod matrix.....
  neighbors = (neighbors + neighbors') >0;

  % get dims of data
  numdata = size(data,1);
  numlayers = size(dimensions,1);

  %%% decant vector of weights into matrices
  for i=1:numlayers
    
    if (i==1)
      prev_dims=0; 
    else
      prev_dims = sum(prod(dimensions(1:i-1,:),2));
    end
    
    w{i} = weights_vec(prev_dims+1:prev_dims+prod(dimensions(i,:)));
    w{i} = reshape(w{i},dimensions(i,:));
    b{i} = ones(numdata,1) * w{i}(end,:);
    w{i} = w{i}(1:end-1,:);
     
    dw{i} = zeros(size(w{i}));
     zeros(size(neighbors));
  end
  
  data_orig = data;
  
  %%%% FORWARD PASS
  % run up
  for i = 1:numlayers %%% only upto code layer 
    if  ((i==1) & (vislinear)) % Hiddens on Gaussian visible have bias term
      pp{i} = 1./(1 + exp(-data*w{i} - b{i} + hidbias_offset));
    elseif ((i==(numlayers)) & (hidlinear)) % Gaussian top level
      pp{i} = pp{i-1}*w{i}+b{i};
%%%%      pp{i} = data*w{i}+b{i};
    else
      pp{i} = 1./(1 + exp(-pp{i-1}*w{i} - b{i}));
    end
  end

  % probabilties of activation of top layer units
  probs = pp{i}';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%% Start of NCA
  
  % dimensions
  codelen = size(probs,1);
  numdata = size(probs,2);
  dt = zeros(codelen,numdata,numdata);
  
  
  %%%% compute distances btw. all pairs of probs
  for b=1:numdata
    dt(:,:,b) = (probs(:,b) * ones(1,numdata)) - probs;
  end
  dt = (reshape(reshape(dt,[codelen numdata^2])',[numdata numdata codelen]));
  % n is Gaussian distance
  n = exp(-sum(dt.^2,3)/SIGMA); n=n-eye(numdata);
  % p is NORMALIZED Gaussian distance
  p = n ./ ( sum(n,2) * ones(1,numdata) );
  
  % pl is norm. Gaussian distance for +ve neighbors
  pl = p .* logical(neighbors);
  
  clear n
  %%%% make up terms for gradient expressions
  nmat = repmat(logical(neighbors),[1 1 codelen]);
  d =  repmat(p,[1 1 codelen]) .* dt;
  dl = d .* nmat;
  
  %%% Compute each of the 4 terms in the gradient
  p1 =  squeeze( sum(dl,2) )';
  p2 =  (ones(codelen,1) * sum( pl,2 )') .* squeeze( sum(d,2)  )';
  p3 = squeeze( sum(dl,1) )';
  p4 = squeeze(sum(d .* repmat(sum(pl,2),[1 numdata   codelen]),1))';

  % Compute cost and gradient
  f = -sum(sum(pl,2),1);
  df_nca = -2*((p1-p2)-(p3-p4));
   
  
  % End of NCA
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  t = cell(1,numlayers);
   
  %%%%%%%%%%%%%%
  % Now backprop
  %%%% BACKWARD PASS
  for i = numlayers:-1:1

    if  ((i==1))% & (vislinear)) % Back at start. Gaussian output.
 %    t{i} =  pp{i} .* (1-pp{i}) .* df_nca';
%      t{i} =  df_nca';
%      t{i} =  (t{i+1}*w{i+1}'); 
      t{i} =   pp{i} .* (1-pp{i}) .* (t{i+1}*w{i+1}'); 

      dw{i} = [data_orig'*t{i};sum(t{i},1)];
  %  elseif ((i==numlayers) & (hidlinear)) % Gaussian top level
  %    t{i} = (t{i+1}*w{i+1}'); 
  %    dw{i} = [pp{i-1}'*t{i};sum(t{i},1)];
    else
      
      if ((i==numlayers) & hidlinear)
        t{i} = df_nca'; 
      elseif ((i==numlayers) & (hidlinear~=1))
        t{i} = pp{i} .* (1-pp{i}) .* df_nca'; 
      else
        t{i} = pp{i} .* (1-pp{i}) .* (t{i+1}*w{i+1}'); 
      end
      
      dw{i} = [pp{i-1}'*t{i};sum(t{i},1)];
        
    end
  end
  
  %%% Decant weights back into vector
  df = [];
  for i=1:numlayers
    df = [ df ; dw{i}(:) ];
  end
  
  df = [df];
  
  
  
