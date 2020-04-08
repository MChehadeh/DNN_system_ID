%%
clear all
addpath(genpath(pwd))

%%
%load list of responses
load("system_response_FOIPTD", "list_of_responses") 

[Xtrain, Ytrain] = prepareDNNData(list_of_responses, 3000);

%% 
%DNN structure
%TODO: generate joint cost matrix and port modified softmax functions

options = trainingOptions('adam', 'Plots', 'training-progress','Shuffle','every-epoch','MaxEpochs', 200, 'LearnRateSchedule','piecewise', 'MiniBatchSize', 1000, 'InitialLearnRate', 0.01, 'LearnRateDropPeriod',50,'LearnRateDropFactor',0.7, 'ExecutionEnvironment', 'cpu');

DNN = [ 
    imageInputLayer([size(Xtrain,1), 1, 2])
%    convolution2dLayer([300, 1], 1000, 'Stride', [100, 1]) %convolution2dLayer([300, 1], 50, 'Stride', [50, 1])
%    reluLayer()
    fullyConnectedLayer(2000) %fullyConnectedLayer(1000)
    reluLayer()
    batchNormalizationLayer
    dropoutLayer(0.4)
    fullyConnectedLayer(500) %fullyConnectedLayer(500)
    reluLayer() 
    batchNormalizationLayer
    dropoutLayer(0.4)
    fullyConnectedLayer(16, 'name', 'finalLayer')
    softmaxLayer() %needs to be the dummy softmax
    classificationLayer];


trained_DNN = trainNetwork(Xtrain, categorical(Ytrain), DNN, options)

%%
%testing
load("system_response_FOIPTD_testing", "list_of_responses") 

[Xtest, Ytest] = prepareDNNData(list_of_responses, 3000);

Ytest_classes = classify(trained_DNN, Xtest); 

correct=0;
wrong=0;
for i=1:length(Ytest)
    if (double(Ytest_classes(i)) == Ytest(i))
        correct = correct+1;
    else
        wrong = wrong+1;
    end
end
accuracy = 100 * correct / (correct+wrong)

%%
%joint cost
load('discrete_processes_FOIPTD.mat', 'joint_cost')
cost = zeros(length(Ytest_classes),1);
for i=1:length(Ytest_classes)
    cost(i) = joint_cost(Ytest_classes(i), Ytest(i));
end

avg_cost = sum(cost) / length(cost);
max_cost = max(cost);

