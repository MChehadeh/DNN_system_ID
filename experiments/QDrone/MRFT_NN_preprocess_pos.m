function [normalized_control_timeseries_output, normalized_error_timeseries_output, scaled_gain_output, relay_bias_output] = MRFT_NN_preprocess_pos(enable, control_timeseries, error_timeseries, target_relay_output, inner_loop_idx)
%MRFT_NN_PREPROCESS Summary of this function goes here
%   Detailed explanation goes here
persistent relay_bias;
persistent scaled_gain;
persistent NN_model;

if isempty(NN_model)
    if isfile(strcat(pwd,'/../../../../output_files/' + string(inner_loop_idx) + '/identification_DNN.mat'))
        g = load('output_files/' + string(inner_loop_idx) + '/identification_DNN');
    else
        g = load('output_files/' + string(inner_loop_idx) + '/identification_DNN_auto');
    end
%     g = load('output_files/' + string(inner_loop_idx) + '/identification_DNN');
    NN_model = g.trained_DNN;
end

sample_size = NN_model.Layers(1).InputSize(1);

normalized_control_timeseries = zeros(1, sample_size);
normalized_error_timeseries = zeros(1, sample_size);

if isempty(relay_bias)
    relay_bias = 0;
end
if isempty(scaled_gain)
    scaled_gain = 0;
end

if (enable)
    iterator = 0;
    first_edge_detected = 0;
    t_cycle_end = 0; t_cycle_start = 0;
    h_mrft = (max(control_timeseries(:))-min(control_timeseries(:))) / 2;
    
    for j=1:length(control_timeseries)-10
        accept = true;     

        if (control_timeseries(end-j+1) - control_timeseries(end-j) < 1.95 * h_mrft)
            accept = false;
        end
        if accept
            iterator = iterator + 1;
        end

        if (iterator == 1 && first_edge_detected == 0) 
            t_cycle_end = length(control_timeseries) - j;
            first_edge_detected = 1;
        elseif (iterator >= 2)
            t_cycle_start = length(control_timeseries) - j;            
            break
        end
    end
    normalized_control_timeseries(end-(t_cycle_end-t_cycle_start)+1:end) = control_timeseries(t_cycle_start+1:t_cycle_end);
    normalized_error_timeseries(end-(t_cycle_end-t_cycle_start)+1:end) = error_timeseries(t_cycle_start+1:t_cycle_end);

    normalized_control_timeseries =  normalized_control_timeseries * target_relay_output / h_mrft;

    %scale
    length_t = t_cycle_end - t_cycle_start;
    amplitude = (max(normalized_error_timeseries(end-length_t+1:end)) - min(normalized_error_timeseries(end-length_t+1:end))) / 2;
    normalized_error_timeseries = normalized_error_timeseries / amplitude;       

    scaled_gain = h_mrft / amplitude;

    %shift to center zero
    normalized_error_timeseries(end-length_t+1:end) = normalized_error_timeseries(end-length_t+1:end) - (max(normalized_error_timeseries(end-length_t+1:end)) + min(normalized_error_timeseries(end-length_t+1:end))) / 2;  
    normalized_control_timeseries(end-length_t+1:end) = normalized_control_timeseries(end-length_t+1:end) - (max(normalized_control_timeseries(end-length_t+1:end)) + min(normalized_control_timeseries(end-length_t+1:end))) / 2;  

    N_max = length(find(normalized_control_timeseries==max(normalized_control_timeseries(:))));
    N_min = length(find(normalized_control_timeseries==min(normalized_control_timeseries(:))));
    relay_bias =  h_mrft * (N_max - N_min) / (N_max + N_min);
end

normalized_control_timeseries_output = normalized_control_timeseries;
normalized_error_timeseries_output = normalized_error_timeseries;
scaled_gain_output = scaled_gain;
relay_bias_output = relay_bias;

end

