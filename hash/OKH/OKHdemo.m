% load LM_data
% % set parameter and initial W
% r = 48;
% para.c = 0.1;
% para.alpha = 0.2;
% para.anchor = anchor;
% d = size(anchor,1);
% %W = rand(d+1,r)-0.5;
% W = mvnrnd(zeros(r, d + 1), eye(d + 1) )';
W = eye(d + 1, r);
% 
% % preliminary for testing
% % kernel mapping the whole set
% KX  = sqdist(X',anchor');
% KX = exp(-KX/(2*0.9^2));
% KX = KX';
% n = size(KX,2);
% KX = [KX; ones(1,n)];

clear X;

rX = KX(:,idxTrain); %set being search in testing 
tX = KX(:,idxTest); %query set in testing

tic;
numPair = floor(length(dataIdx)/2);
T = [];
MAP = [];
for i = 1: numPair;
    idx_i = idxTrain(dataIdx(2*i-1));
    idx_j = idxTrain(dataIdx(2*i));
    s = label(idx_i,idx_j);
    
%    xi = X(idx_i,:);
%    xj = X(idx_j,:);
    
%     xi = sqdist(xi',anchor');
%     xi = exp(-xi/2);
%     xi = [xi;1];
%     xj = sqdist(xj',anchor');
%     xj = exp(-xj/2);
%     xj = [xj;1];
  
    xi = KX(:,idx_i);
    xj = KX(:,idx_j);

    W = OKHlearn(xi,xj,s,W,para);
    
   
    if mod(i, 100) == 0
       OKHtest;
       T = [T i];
       MAP = [MAP ham_pre];
       %precision(i) = ham_pre;       
       fprintf('%d training pairs are done. MAP = %.4f ', i, MAP(end));
       toc;
    end
end
plot(T, MAP);
save('result.mat', 'T', 'MAP'); 
