function [list_of_responses] = generateResponses(list_of_discrete_processes, h_relay, optTuningRule, N_response_per_process, time_step, t_final, max_bias_mag, max_noise_mag)
%GENERATERESPONSES Generates MRFT responses for a set of processes
%   Detailed explanation goes here

mrft_controller = MRFTController(optTuningRule.beta, h_relay);
list_of_responses = [];

for i=1:length(list_of_discrete_processes)
    for j=1:N_response_per_process
        temp_mrft_response = MRFTResponse(list_of_discrete_processes(i), mrft_controller, t_final, time_step);
        temp_mrft_response.input_bias = max_bias_mag * (2*rand()-1) * mrft_controller.h_relay;
        temp_mrft_response.simulateResponse();        
        temp_mrft_response.add_noise(max_noise_mag * rand());
              
        list_of_responses = [list_of_responses; temp_mrft_response.returnCopy()];
    end
end

end

