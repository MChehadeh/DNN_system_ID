function [J] = generate_joint_cost_matrix(list_of_processes, tuning_rule)
%GENERATE_JOINT_COST_FUNCTION Summary of this function goes here
%   Detailed explanation goes here

J = zeros(length(list_of_processes));

for i=1:length(list_of_processes)
    for j=i:length(list_of_processes)
        [~,~,b1_b2, b2_b1] = get_joint_cost(list_of_processes(i), list_of_processes(j), tuning_rule);
        J(i,j) = b1_b2;
        J(j,i) = b2_b1;
    end
end
end

