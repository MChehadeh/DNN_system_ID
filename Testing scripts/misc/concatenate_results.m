addpath(genpath(pwd))

%%
a = load('test_results_fixed_with_pm');
b = load('test_results_final_fixed_with_pm');

%%
list_of_inner_loop_processes = [a.list_of_inner_loop_processes, b.list_of_inner_loop_processes];
list_of_outer_loop_processes = [a.list_of_outer_loop_processes, b.list_of_outer_loop_processes];

list_of_index_inner_loop = [a.list_of_index_inner_loop, b.list_of_index_inner_loop];
list_of_index_outer_loop = [a.list_of_index_outer_loop, b.list_of_index_outer_loop];

list_of_inner_loop_MRFT_response = [a.list_of_inner_loop_MRFT_response, b.list_of_inner_loop_MRFT_response];
list_of_outer_loop_MRFT_response = [a.list_of_outer_loop_MRFT_response, b.list_of_outer_loop_MRFT_response];

list_of_inner_loop_PD_approximated_gain = [a.list_of_inner_loop_PD_approximated_gain, b.list_of_inner_loop_PD_approximated_gain];
list_of_inner_loop_PD = [a.list_of_inner_loop_PD, b.list_of_inner_loop_PD];
list_of_outer_loop_PD_approximated_gain = [a.list_of_outer_loop_PD_approximated_gain, b.list_of_outer_loop_PD_approximated_gain];
list_of_outer_loop_PD = [a.list_of_inner_loop_processes, b.list_of_outer_loop_PD];

list_of_inner_loop_normalized_joint_cost = [a.list_of_inner_loop_normalized_joint_cost, b.list_of_inner_loop_normalized_joint_cost];
list_of_inner_loop_joint_cost_approximated_gain = [a.list_of_inner_loop_joint_cost_approximated_gain, b.list_of_inner_loop_joint_cost_approximated_gain];
list_of_inner_loop_joint_cost = [a.list_of_inner_loop_joint_cost, b.list_of_inner_loop_joint_cost];

list_of_outer_loop_normalized_joint_cost = [a.list_of_outer_loop_normalized_joint_cost, b.list_of_outer_loop_normalized_joint_cost];
list_of_outer_loop_double_normalized_joint_cost = [a.list_of_outer_loop_double_normalized_joint_cost, b.list_of_outer_loop_double_normalized_joint_cost];
list_of_outer_loop_joint_cost_approximated_gain = [a.list_of_outer_loop_joint_cost_approximated_gain, b.list_of_outer_loop_joint_cost_approximated_gain];
list_of_joint_cost_double_approximated_gain = [a.list_of_joint_cost_double_approximated_gain, b.list_of_joint_cost_double_approximated_gain];
list_of_outer_loop_joint_cost = [a.list_of_outer_loop_joint_cost, b.list_of_outer_loop_joint_cost];
list_of_full_joint_cost = [a.list_of_full_joint_cost, b.list_of_full_joint_cost];

list_of_phase_margins_inner_loop_normalized = [a.list_of_phase_margins_inner_loop_normalized, b.list_of_phase_margins_inner_loop_normalized];
list_of_phase_margins_inner_loop_approximated_gain = [a.list_of_phase_margins_inner_loop_approximated_gain, b.list_of_phase_margins_inner_loop_approximated_gain];
list_of_phase_margins_inner_loop_exact_gain = [a.list_of_phase_margins_inner_loop_exact_gain, b.list_of_phase_margins_inner_loop_exact_gain];
list_of_phase_margins_outer_loop_normalized = [a.list_of_phase_margins_outer_loop_normalized, b.list_of_phase_margins_outer_loop_normalized];
list_of_phase_margins_double_approximated_gain = [a.list_of_phase_margins_double_approximated_gain, b.list_of_phase_margins_double_approximated_gain];
list_of_phase_margins = [a.list_of_phase_margins, b.list_of_phase_margins];

%%
save('simulation_results_clean')