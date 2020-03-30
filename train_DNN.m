%%
clear all
addpath(genpath(pwd))

%%
%load list of responses
load("FOIPTD_system_responses", "list_of_responses") 

[Xtrain, Ytrain] = prepareDNNData(list_of_responses, 1000);

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
    fullyConnectedLayer(10, 'name', 'finalLayer')
    softmaxLayer() %needs to be the dummy softmax
    classificationLayer];


trained_DNN = trainNetwork(Xtrain, categorical(Ytrain), DNN, options)

%%
Y_resuts = classify(trained_DNN, Xtrain);