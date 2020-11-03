%%
clear all
addpath(genpath(pwd))
class = '9_filtered';

%%
%load simulated MRFT data
%Data can be downloaded from sharepoint folder
load(strcat('output_files/',class,'/training_data'), "MRFT_responses_training") %testing
load(strcat('output_files/',class,'/testing_data'), "MRFT_responses_testing") 
load(strcat('output_files/',class,'/discrete_processes'), "list_of_outer_loop_processes") 

%%
%find largest period of MRFT osscillations
% The largest period dictates the size of the input vector of the DNN
periods = [];
for i=1:length(MRFT_responses_training)
    periods = [periods, MRFT_responses_training(i).response_period];
end
input_layer_length = 1000 * ceil(max(periods));

%Take the last mrft oscillation of each MRFT response and pads it to the
%required size
[Xtrain, Ytrain] = prepareDNNData(MRFT_responses_training, input_layer_length); %3000
[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, input_layer_length); %3000

%% 
%DNN structure
%TODO: generate joint cost matrix and port modified softmax functions

options = trainingOptions('adam', 'Plots', 'training-progress','Shuffle','every-epoch','MaxEpochs', 200, 'LearnRateSchedule','piecewise', 'MiniBatchSize', 100, 'InitialLearnRate', 0.01, 'LearnRateDropPeriod',20,'LearnRateDropFactor',0.7, 'ExecutionEnvironment', 'gpu', 'ValidationData', {Xtest,categorical(Ytest)}, 'ValidationFrequency', 5, 'ValidationPatience',120);

load(strcat('output_files/',class,'/joint_cost'), "joint_cost_matrix") 

joint_cost_matrix(joint_cost_matrix < 1) = 1;
joint_cost_matrix(joint_cost_matrix > 1) = 1;

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
    fullyConnectedLayer(length(list_of_outer_loop_processes), 'name', 'finalLayer')
    softmaxLayer() %needs to be the dummy softmax
    %classificationLayer];
    modifiedSoftEntropy('crossentropy', joint_cost_matrix, [])];


trained_DNN = trainNetwork(Xtrain, categorical(Ytrain), DNN, options)

%%
%testing
high_bias = 0.5;
low_bias = 0.3;
load(strcat('output_files/',class,'/testing_data'), "MRFT_responses_testing") 
load(strcat('output_files/',class,'/joint_cost'), "joint_cost_matrix") 

[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, input_layer_length, high_bias); %3000

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

cost_high_bias = zeros(length(Ytest_classes),1);
for i=1:length(Ytest_classes)
    cost_high_bias(i) = joint_cost_matrix(Ytest_classes(i), Ytest(i));
end

avg_cost_high_bias = sum(cost_high_bias) / length(cost_high_bias)
max_cost_high_bias = max(cost_high_bias)  

%%
%testing low bias
[Xtest, Ytest] = prepareDNNData(MRFT_responses_testing, input_layer_length, low_bias); %3000

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

cost_low_bias = zeros(length(Ytest_classes),1);
for i=1:length(Ytest_classes)
    cost_low_bias(i) = joint_cost_matrix(Ytest_classes(i), Ytest(i));
end

avg_cost_low_bias = sum(cost_low_bias) / length(cost_low_bias)
max_cost_low_bias = max(cost_low_bias) 

%%
save(strcat('output_files/',class,'/identification_DNN'), 'trained_DNN', 'cost_low_bias', 'avg_cost_low_bias', 'max_cost_low_bias', 'cost_high_bias', 'avg_cost_high_bias', 'max_cost_high_bias')

