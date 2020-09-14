function [joint_cost,min_joint_cost,b1_b2,b2_b1] = get_joint_cost_outer(process_1,process_2,tuning_rule, tuning_rule_inner)
%GET_JOINT_COST V2 Returns Joint Cost
%   model_parameters= [sys1;sys2]; sys1=[K T1 T2 tau]
%   optim_parameters= [sys1;sys2]; sys1=[P D]
%   Gain is matched before application of controller
b2_b1=0;
b1_b2=0;

process_1_copy = process_1.returnCopy();
process_2_copy = process_2.returnCopy();


%normalize inner loop
[~, inner_loop_optController_1_normalized] = process_1_copy.inner_loop_process.get_normalized_optController(tuning_rule_inner);
[~, inner_loop_optController_2_normalized] = process_2_copy.inner_loop_process.get_normalized_optController(tuning_rule_inner);
[~, inner_loop_1_K_normalized] = process_1_copy.inner_loop_process.normalize_gain_at_phase(tuning_rule_inner);
[~, inner_loop_2_K_normalized] = process_2_copy.inner_loop_process.normalize_gain_at_phase(tuning_rule_inner);


[~, optController_1_normalized] = process_1_copy.get_normalized_optController(tuning_rule);
[~, optController_2_normalized] = process_2_copy.get_normalized_optController(tuning_rule);
[~, process_1_K_normalized] = process_1_copy.normalize_gain_at_phase(tuning_rule);
[~, process_2_K_normalized] = process_2_copy.normalize_gain_at_phase(tuning_rule);


%switch inner loop controllers
process_1_copy.inner_loop_process.K = inner_loop_1_K_normalized;
process_2_copy.inner_loop_process.K = inner_loop_2_K_normalized;
process_1_copy.inner_loop_process.optController = inner_loop_optController_2_normalized.returnCopy();
process_2_copy.inner_loop_process.optController = inner_loop_optController_1_normalized.returnCopy();
process_1_copy.K = process_1_K_normalized;
process_2_copy.K = process_2_K_normalized;

[~, step_b2_b1] =  process_1_copy.getStep(optController_2_normalized);
[~, step_b1_b2] =  process_2_copy.getStep(optController_2_normalized);

b2_b1 = step_b2_b1 / process_1_copy.optCost;
b1_b2 = step_b1_b2 / process_2_copy.optCost;

joint_cost=max([b2_b1;b1_b2]);
min_joint_cost=min([b2_b1;b1_b2]);

end

