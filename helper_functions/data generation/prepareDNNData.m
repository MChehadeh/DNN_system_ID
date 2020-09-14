function [X, Y] = prepareDNNData(list_of_mrft_responses, min_response_length, varargin)
%PREPAREDNNDATA Summary of this function goes here
%   Detailed explanation goes here
if(length(varargin)>0)
    bias_limit = varargin{1};
else
    bias_limit = 1;
end

%find response with longest period
for i=1:length(list_of_mrft_responses)
    if (min_response_length < (list_of_mrft_responses(i).response_period /  list_of_mrft_responses(i).step_time))
        min_response_length = (list_of_mrft_responses(i).response_period /  list_of_mrft_responses(i).step_time);
    end
end

X = zeros(min_response_length, 1, 2, length(list_of_mrft_responses));
Y = zeros(length(list_of_mrft_responses), 1);

valid_counter = 0;
for i=1:length(list_of_mrft_responses)
    if i==length(list_of_mrft_responses)
        g=1;
    end
    if list_of_mrft_responses(i).input_bias <= bias_limit
        valid_counter = valid_counter + 1;
        N_steps = length(list_of_mrft_responses(i).single_cycle_response_pv);
        X(end - N_steps + 1:end, 1, 1, valid_counter) = list_of_mrft_responses(i).noisy_response_pv;
        X(end - N_steps + 1:end, 1, 2, valid_counter) = list_of_mrft_responses(i).single_cycle_response_u;

        Y(valid_counter) = list_of_mrft_responses(i).process.id;  
    end
end
X = X(:,:,:,1:valid_counter);
Y = Y(1:valid_counter);       
end

