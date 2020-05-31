function [list_of_amplitude_scales] = FindMRFTScaling(list_of_discrete_processes, h_relay, optTuningRule, time_step, t_final)
%FindMRFTScaling Finds the exact amplitude scaling factor for a set of
%processes
%Detailed explanation goes here

mrft_controller = MRFTController(optTuningRule.beta, h_relay);
list_of_amplitude_scales = [];

for i=1:length(list_of_discrete_processes)
    temp_mrft_response = MRFTResponse(list_of_discrete_processes(i), mrft_controller, t_final, time_step);
    temp_mrft_response.input_bias = 0;
    temp_mrft_response.simulateResponse();  
    
    [~, process_normalized_K] = list_of_discrete_processes(i).normalize_gain_at_phase(optTuningRule);
    expected_amplitude = (list_of_discrete_processes(i).K * h_relay) / process_normalized_K;
    amplitude_scale = expected_amplitude / temp_mrft_response.response_amplitude;
    
    list_of_amplitude_scales = [list_of_amplitude_scales; amplitude_scale];
end

end

