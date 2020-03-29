function [X, Y] = prepareDNNData(list_of_mrft_responses, min_response_length)
%PREPAREDNNDATA Summary of this function goes here
%   Detailed explanation goes here

%find response with longest period
for i=1:length(list_of_mrft_responses)
    if (min_response_length < (list_of_mrft_responses(i).response_period /  list_of_mrft_responses(i).step_time))
        min_response_length = (list_of_mrft_responses(i).response_period /  list_of_mrft_responses(i).step_time);
    end
end

X = zeros(min_response_length, 1, 2, length(list_of_mrft_responses));
Y = zeros(length(list_of_mrft_responses), 1);

for i=1:length(list_of_mrft_responses)
    N_steps = length(list_of_mrft_responses(i).single_cycle_response_pv);
    X(end - N_steps + 1:end, 1, 1, i) = list_of_mrft_responses(i).normalized_response_pv;
    X(end - N_steps + 1:end, 1, 2, i) = list_of_mrft_responses(i).single_cycle_response_u;
    
    Y(i) = list_of_mrft_responses(i).process.id;    
end
       
end

