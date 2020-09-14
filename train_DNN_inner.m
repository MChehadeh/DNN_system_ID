%
clear all
addpath(genpath(pwd))
class = 'inner_loop';

%%
%load list of responses
g = load(strcat('output_files/',class,'/system_response_SOIPTD'), "list_of_responses"); %testing
MRFT_responses_training = g.list_of_responses;
g = load(strcat('output_files/',class,'/system_response_SOIPTD_testing'), "list_of_responses") ;
MRFT_responses_testing = g.list_of_responses;
load(strcat('output_files/',class,'/discrete_processes_SOIPTD'), "list_of_discrete_processes");

periods = [];
for i=1:length(MRFT_responses_training)
    periods = [periods, MRFT_responses_training(i).response_period];
end

input_layer_length = 1000 * ceil(max(periods));
[Xtrain, Ytrain] = prepareDNNData(MRFT_responses_training, input_layer_length); %3000
[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, input_layer_length); %3000

%% 
%DNN structure
%TODO: generate joint cost matrix and port modified softmax functions

options = trainingOptions('adam', 'Plots', 'training-progress','Shuffle','every-epoch','MaxEpochs', 100, 'LearnRateSchedule','piecewise', 'MiniBatchSize', 100, 'InitialLearnRate', 0.01, 'LearnRateDropPeriod',20,'LearnRateDropFactor',0.7, 'ExecutionEnvironment', 'gpu', 'ValidationData', {Xtest,categorical(Ytest)}, 'ValidationFrequency', 5);

g = load(strcat('output_files/',class,'/discrete_processes_SOIPTD'), "joint_cost");
joint_cost_matrix = g.joint_cost;

joint_cost_matrix(joint_cost_matrix < 1) = 1;
joint_cost_matrix(joint_cost_matrix > 1e3) = 1e3;

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
    fullyConnectedLayer(length(list_of_discrete_processes), 'name', 'finalLayer')
    softmaxLayer() %needs to be the dummy softmax
    %classificationLayer];
    modifiedSoftEntropy('crossentropy', joint_cost_matrix, [])];


trained_DNN = trainNetwork(Xtrain, categorical(Ytrain), DNN, options)

%%
%testing
g = load(strcat('output_files/',class,'/system_response_SOIPTD_testing'), "list_of_responses");
MRFT_responses_testing = g.list_of_responses;

[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, input_layer_length); %3000

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
g = load(strcat('output_files/',class,'/discrete_processes_SOIPTD'), "joint_cost");
joint_cost_matrix = g.joint_cost;
cost = zeros(length(Ytest_classes),1);
for i=1:length(Ytest_classes)
    cost(i) = joint_cost_matrix(Ytest_classes(i), Ytest(i));
end

avg_cost = sum(cost) / length(cost)
max_cost = max(cost)

%%
save(strcat('output_files/',class,'/identification_DNN'), 'trained_DNN')

