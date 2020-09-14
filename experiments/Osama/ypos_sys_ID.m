addpath(genpath(strcat(pwd,'..\..\')))
addpath(genpath('C:\Users\aaa_b\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath(genpath('C:\Users\user\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath('y_experiments')
load('quad-roll-pitch.mat');
%%
inner_loop_idx = 12;

optTuningRule_pos = load("output_files/24/distinguishing_phase", "optTuningRule");
optTuningRule_pos = optTuningRule_pos.optTuningRule;

%%
%upsampling
times_u = controller_output_1_t * 1e6;
times_y = y_t * 1e6;
times_upsampled = min(y_t)*1e6:0.001:max(y_t)*1e6;
MRFT_u = interp1(times_u, controller_output_4, times_upsampled, 'nearest');
MRFT_error = interp1(times_pitch, pitch, times_upsampled, 'linear');


%%
%take MRFt region
start_index = 45360; 
end_index = 52910;
MRFT_u = MRFT_u(start_index:end_index);
MRFT_error = MRFT_error(start_index:end_index);
MRFT_command = ones(size(MRFT_u));

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



