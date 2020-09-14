%%
%clear all
addpath(genpath('C:\Users\aaa_b\OneDrive\KU_research\research\AI for parameter tuning\Simulations\'))
%load('MRFT_Commander_19-May-pos_x.mat')
MRFT_command = commander_data(49,:);
% start_index = 17500;
% end_index = 21000;
start_index = min(find(MRFT_command==1));
end_index = start_index + min(find(MRFT_command(start_index:end)==0));
sample_times = commander_data(38, start_index:end_index);
MRFT_command = commander_data(49, start_index:end_index);
MRFT_u = commander_data(50,start_index:end_index);
MRFT_error = -commander_data(51, start_index:end_index);

inner_loop_idx = 37;

optTuningRule_pos = load("output_files/"+string(inner_loop_idx)+"/distinguishing_phase", "optTuningRule");
optTuningRule_pos = optTuningRule_pos.optTuningRule;
%%
%detect rise edges
rise_edge_times = [];
h_mrft = 0.2;
    
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
    [normalized_control_timeseries, normalized_error_timeseries, scaled_gain, relay_bias] = MRFT_NN_preprocess_pos(ready, control_timeseries, error_timeseries, 1, inner_loop_idx);
    [P, D, I, T_1, time_delay, class] = PD_classify_pos(ready, normalized_control_timeseries, normalized_error_timeseries, scaled_gain, optTuningRule_pos, inner_loop_idx);       
    predictions(i) = class;
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



