%%
clear all
addpath(genpath(pwd))

%%
%load list of responses
load("output_files/24_vel/training_data", "MRFT_responses_training") 

[Xtrain, Ytrain] = prepareDNNData(MRFT_responses_training, 2500); %3000

%% 
%DNN structure
%TODO: generate joint cost matrix and port modified softmax functions

options = trainingOptions('adam', 'Plots', 'training-progress','Shuffle','every-epoch','MaxEpochs', 300, 'LearnRateSchedule','piecewise', 'MiniBatchSize', 1000, 'InitialLearnRate', 0.01, 'LearnRateDropPeriod',50,'LearnRateDropFactor',0.7, 'ExecutionEnvironment', 'gpu');

load("output_files/24_vel/joint_cost", "joint_cost_matrix") 

joint_cost_matrix(joint_cost_matrix < 1) = 1;
joint_cost_matrix(joint_cost_matrix > 2) = 2;

DNN = [ 
    imageInputLayer([size(Xtrain,1), 1, 2])
    fullyConnectedLayer(3000) %fullyConnectedLayer(2000)
    reluLayer()
    batchNormalizationLayer
    dropoutLayer(0.4)
    fullyConnectedLayer(1000) %fullyConnectedLayer(500)
    reluLayer() 
    batchNormalizationLayer
    dropoutLayer(0.4)
    fullyConnectedLayer(18, 'name', 'finalLayer')
    softmaxLayer() %needs to be the dummy softmax
    classificationLayer];
    %modifiedSoftEntropy('crossentropy', joint_cost_matrix, [])];


trained_DNN = trainNetwork(Xtrain, categorical(Ytrain), DNN, options)

%%
%testing
load("output_files/24_vel/testing_data", "MRFT_responses_testing") 

[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, 2500); %3000

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
load("output_files/24_vel/joint_cost", "joint_cost_matrix") 
cost = zeros(length(Ytest_classes),1);
for i=1:length(Ytest_classes)
    cost(i) = joint_cost_matrix(Ytest_classes(i), Ytest(i));
end

avg_cost = sum(cost) / length(cost)
max_cost = max(cost)

