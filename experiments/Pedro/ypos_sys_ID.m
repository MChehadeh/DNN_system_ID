addpath(genpath(strcat(pwd,'..\..\')))
addpath(genpath('C:\Users\aaa_b\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath(genpath('C:\Users\user\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath('roll_pitch')
load('outter_only_with_bias.mat');
%%
%upsampling
times_u = controller_output_1_t * 1e6;
times_y = y_t * 1e6;
times_upsampled = min(y_t)*1e6:0.001:max(y_t)*1e6;
MRFT_u = interp1(times_u, controller_output_1, times_upsampled, 'nearest');
MRFT_error = interp1(times_y, y, times_upsampled, 'cubic');

%%
%take MRFt region
start_index = 45550; 
end_index = 54030;
MRFT_u = MRFT_u(start_index:end_index);
MRFT_error = MRFT_error(start_index:end_index);
MRFT_command = ones(size(MRFT_u));

%%
inner_loop_idx = 12;

optTuningRule_pos = load("output_files/12/distinguishing_phase", "optTuningRule");
optTuningRule_pos = optTuningRule_pos.optTuningRule;
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

for i=1:(length(rise_edge_times)-1)
    control_timeseries = MRFT_u((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    error_timeseries = MRFT_error((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    ready = true;
    [normalized_control_timeseries, normalized_error_timeseries, scaled_gain, relay_bias] = MRFT_NN_preprocess(ready, control_timeseries, error_timeseries, 1);
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



