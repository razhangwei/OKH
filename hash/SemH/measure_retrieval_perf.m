

% assumes that you have fully trained model which has evaluated both
% train and test data (thus has label_test_code and label_train_code
% fields present). 

%%% we only use LabelMe data for evaluation
%%% so load in true distance matrix and train/test indices
load LabelMe_gist DistLM seg ndxtrain ndxtest 

%%% 
[npoint,ndim,nbat] = size(data.label_train);  
ndxtrain = ndxtrain(1:npoint*nbat);
code(:,ndxtrain) = data.label_train_code;
code(:,ndxtest)  = data.label_test_code;

clear P_code h_code h_code_score
for n = 1:length(ndxtest)
    ndx = ndxtest(n);

    % compute your distance
    D_code = hammD2(code(:,ndx),code(:,ndxtrain));
    [foo, j_code] = sort(D_code, 'ascend'); % I assume that small distance means closer
    j_code = ndxtrain(j_code);
    
    % get groundtruth sorting
    D_truth = DistLM(ndx,:);
    [foo, j_truth] = sort(-D_truth(ndxtrain)); j_truth = ndxtrain(j_truth);

    % evaluation
    [h, P_code(:,n)] = neighborsRecall(j_truth, j_code, 'r');
    [h_code(n), h_code_score(n)]  = recognitionPerf(seg, seg(:,:,ndx), j_code);
    
    drawnow

end


% Visualize evaluation summary

figure

subplot(121)
plot(mean(P_code,2), 'r')
axis('square');
grid on
ylabel('percentage of 50 true neighbors within M retrieved images')
xlabel('M')
title('Retrieval test')

subplot(122)
perf = evalRecognitionPerf(h_code_score, h_code);
plot(perf/32/32*100, 'r')
axis('square');
grid on
ylabel('percentage of pixels with correct label')
xlabel('test set binned by confindence')
title('Recognition test')


