%%
%clear all
addpath(genpath('C:\Users\aaa_b\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
%load('MRFT_Stabilizer_18-May_pitch.mat')
MRFT_command = stabilizer_data(47,:);
start_index = min(find(MRFT_command==1));
start_index = 3880;
end_index = start_index + min(find(MRFT_command(start_index:end)==0));
sample_times = stabilizer_data(43, start_index:end_index);
MRFT_command = stabilizer_data(47, start_index:end_index);
MRFT_u = stabilizer_data(48,start_index:end_index);
MRFT_error = -stabilizer_data(49, start_index:end_index);

%inner loop opt tuning rule
optTuningRule_att=TuningRule;
optTuningRule_att.rule_type=TuningRuleType.pm_based;
optTuningRule_att.beta=-0.73;
optTuningRule_att.pm=20;
optTuningRule_att.c1=0.3849;
optTuningRule_att.c3=0.3817;
optTuningRule_att.pm_min=20;
optTuningRule_att.pm_max=90;
optTuningRule_att.beta_min=-0.9;
optTuningRule_att.beta_max=-0.1;
%%
%detect rise edges
rise_edge_times = [];
h_mrft = 0.1;
    
for j=1:length(MRFT_u)-100
    accept = true;     

    if (MRFT_u(j+1) - MRFT_u(j) < 1.95 * h_mrft)
            accept = false;
    end
    if accept
        rise_edge_times = [rise_edge_times, j+1];
    end
end
%%
%get predictions for all the cycles
predictions = zeros(length(rise_edge_times)-1, 1);
clear MRFT_NN_preprocess_pos
clear PD_classify_pos

for i=1:(length(rise_edge_times)-1)
    control_timeseries = MRFT_u((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    error_timeseries = MRFT_error((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    ready = true;
    [normalized_control_timeseries, normalized_error_timeseries, scaled_gain, relay_bias] = MRFT_NN_preprocess(ready, control_timeseries, error_timeseries, 1);
    [P, D, I, T_1, T_2, time_delay, class] = PD_classify(ready, normalized_control_timeseries, normalized_error_timeseries, scaled_gain, optTuningRule_att);       
    predictions(i) = class;
    scaled_gain
    P
    D
end

%%
%joint cost matrix across cycles
load('joint_costs_fullspace.mat')
sub_joint_cost_matrix = zeros(length(predictions));

for i=1:length(predictions)
    for j=1:length(predictions)
        sub_joint_cost_matrix(i, j) = joint_cost_matrix(predictions(i), predictions(j));
    end
end



