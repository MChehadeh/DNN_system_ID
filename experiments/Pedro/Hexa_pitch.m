addpath(genpath(strcat(pwd,'..\..\')))
addpath(genpath('C:\Users\aaa_b\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath(genpath('C:\Users\user\OneDrive\KU_research\research\AI for parameter tuning\Simulations\refactored_code'))
addpath('roll_pitch')
load('small_hexa_inner.mat');

%%
%upsampling
times_u = controller_output_4_t * 1e6;
times_pitch = pitch_t * 1e6;
times_upsampled = min(pitch_t)*1e6:0.001:max(pitch_t)*1e6;
MRFT_u = interp1(times_u, controller_output_4, times_upsampled, 'nearest');
MRFT_error = interp1(times_pitch, pitch, times_upsampled, 'cubic');


%%
%take MRFt region
start_index = 8500; 
end_index = 15200;
MRFT_u = MRFT_u(start_index:end_index);
MRFT_error = MRFT_error(start_index:end_index);
MRFT_command = ones(size(MRFT_u));

%%
%detect rise edges
rise_edge_times = [];
h_mrft = 0.04;
   
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
%get predictions for all the cycles
predictions = zeros(length(rise_edge_times)-1, 1);

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