function [joint_cost,min_joint_cost,b1_b2,b2_b1] = get_joint_cost(process_1,process_2,tuning_rule)
%GET_JOINT_COST V2 Returns Joint Cost
%   model_parameters= [sys1;sys2]; sys1=[K T1 T2 tau]
%   optim_parameters= [sys1;sys2]; sys1=[P D]
%   Gain is matched before application of controller
b2_b1=0;
b1_b2=0;

[~, optController_1_normalized] = process_1.get_normalized_optController(tuning_rule);
[~, optController_2_normalized] = process_2.get_normalized_optController(tuning_rule);

[~, step_b2_b1] =  process_1.getStep_normalized_at_phase(optController_2_normalized, tuning_rule);
[~, step_b1_b2] =  process_2.getStep_normalized_at_phase(optController_1_normalized, tuning_rule);

b2_b1 = step_b2_b1 / process_1.optCost;
b1_b2 = step_b1_b2 / process_2.optCost;

joint_cost=max([b2_b1;b1_b2]);
min_joint_cost=min([b2_b1;b1_b2]);

end

