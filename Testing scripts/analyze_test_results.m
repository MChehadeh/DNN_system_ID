clear all
addpath(genpath(pwd))
load('simulation_results_clean.mat')

%%
%normalized gains results
N_avg_att_cost = sum(list_of_inner_loop_normalized_joint_cost) / length(list_of_inner_loop_normalized_joint_cost)
N_avg_pos_cost = sum(list_of_outer_loop_double_normalized_joint_cost) / length(list_of_outer_loop_double_normalized_joint_cost)
N_avg_att_pm = sum(list_of_phase_margins_inner_loop_normalized) / length(list_of_phase_margins_inner_loop_normalized)
N_avg_pos_pm = sum(list_of_phase_margins_outer_loop_normalized) / length(list_of_phase_margins_outer_loop_normalized)
N_max_att_cost = max(list_of_inner_loop_normalized_joint_cost)
N_max_pos_cost = max(list_of_outer_loop_double_normalized_joint_cost)
N_min_att_pm = min(list_of_phase_margins_inner_loop_normalized)
N_min_pos_pm = min(list_of_phase_margins_outer_loop_normalized)

%%
%DF gain results
D_avg_att_cost = sum(list_of_inner_loop_joint_cost_approximated_gain) / length(list_of_inner_loop_joint_cost_approximated_gain)
D_avg_pos_cost = sum(list_of_joint_cost_double_approximated_gain) / length(list_of_joint_cost_double_approximated_gain)
D_avg_att_pm = sum(list_of_phase_margins_inner_loop_approximated_gain) / length(list_of_phase_margins_inner_loop_approximated_gain)
D_avg_pos_pm = sum(list_of_phase_margins_double_approximated_gain) / length(list_of_phase_margins_double_approximated_gain)
D_max_att_cost = max(list_of_inner_loop_joint_cost_approximated_gain)
D_max_pos_cost = max(list_of_joint_cost_double_approximated_gain)
D_min_att_pm = min(list_of_phase_margins_inner_loop_approximated_gain)
D_min_pos_pm = min(list_of_phase_margins_double_approximated_gain)

%%
%DF corrected gain results
C_avg_att_cost = sum(list_of_inner_loop_joint_cost) / length(list_of_inner_loop_joint_cost)
C_avg_pos_cost = sum(list_of_full_joint_cost) / length(list_of_full_joint_cost)
C_avg_att_pm = sum(list_of_phase_margins_inner_loop_exact_gain) / length(list_of_phase_margins_inner_loop_exact_gain)
C_avg_pos_pm = sum(list_of_phase_margins) / length(list_of_phase_margins)
C_max_att_cost = max(list_of_inner_loop_joint_cost)
C_max_pos_cost = max(list_of_full_joint_cost)
C_min_att_pm = min(list_of_phase_margins_inner_loop_exact_gain)
C_min_pos_pm = min(list_of_phase_margins)


%%
%analyze phase margin

list_min_phase_margins = 100*ones(48, 1);
list_min_phase_margins_normalized = 100*ones(48, 1);
list_min_phase_margins_double_approximated = 100*ones(48, 1);

for i=1:length(list_of_phase_margins)
    inner_loop_process_idx = grp2idx(list_of_index_inner_loop(i));
    if list_of_phase_margins(i) < list_min_phase_margins(inner_loop_process_idx)
        list_min_phase_margins(inner_loop_process_idx) = list_of_phase_margins(i);
    end
    if list_of_phase_margins_double_approximated_gain(i) < list_min_phase_margins_double_approximated(inner_loop_process_idx)
        list_min_phase_margins_double_approximated(inner_loop_process_idx) = list_of_phase_margins_double_approximated_gain(i);
    end
    if list_of_phase_margins_outer_loop_normalized(i) < list_min_phase_margins_normalized(inner_loop_process_idx)
        list_min_phase_margins_normalized(inner_loop_process_idx) = list_of_phase_margins_outer_loop_normalized(i);
    end
end

%remove unfound processes
ignore_idx = find(list_min_phase_margins == 100);
list_min_phase_margins(ignore_idx) = [];
list_min_phase_margins_double_approximated(ignore_idx) = [];
list_min_phase_margins_normalized(ignore_idx) = [];

%average minimum
avg_normalized_pm = sum(list_min_phase_margins_normalized)/length(list_min_phase_margins_normalized)
avg_approximated_pm = sum(list_min_phase_margins_double_approximated)/length(list_min_phase_margins_double_approximated)
avg_pm = sum(list_min_phase_margins)/length(list_min_phase_margins)


