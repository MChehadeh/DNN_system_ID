addpath(genpath(strcat(pwd,'../../')))
addpath('z_identification')
load('z_data_with_input_layer.mat');

%%
%upsampling
times_u = controller_output_t * 1e6;
times_z = camera_pv_t * 1e6;
times_upsampled = min(camera_pv_t)*1e6:0.001:max(camera_pv_t)*1e6;
MRFT_u = interp1(times_u, controller_output, times_upsampled, 'nearest');
MRFT_error = interp1(times_z, camera_pv, times_upsampled, 'spline');

%%
%take MRFt region
start_index = 15100; 
end_index = 32540;
MRFT_u = MRFT_u(start_index:end_index);
MRFT_error = MRFT_error(start_index:end_index);
MRFT_command = ones(size(MRFT_u));

%%
%detect rise edges
rise_edge_times = [];
h_mrft = 0.1;
   
g = [];
for j=1:length(MRFT_u)-100
    accept = true;     
    
    if ((MRFT_u(j+1) - MRFT_u(j)) < 1.95 * h_mrft)
            accept = false;
    end
    if accept
        rise_edge_times = [rise_edge_times, j+1];
    end
end

%%
predictions = zeros(length(rise_edge_times)-1, 1);
scaling_gains = zeros(length(rise_edge_times)-1, 1);

for i=1:(length(rise_edge_times)-1)
    control_timeseries = MRFT_u((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    error_timeseries = MRFT_error((rise_edge_times(i)-15):(rise_edge_times(i+1)+15));
    ready = true;
    [normalized_control_timeseries, normalized_error_timeseries, scaled_gain, relay_bias] = MRFT_NN_preprocess_z(ready, control_timeseries, error_timeseries, 0.1);
    [P, D, I, T_1, T_2, time_delay, class] = PD_classify_z(ready, normalized_control_timeseries, normalized_error_timeseries, scaled_gain);       
    predictions(i) = class;
    scaling_gains(i) = scaled_gain;
    P
    D
end