%Discritization parameters
clear all
addpath(genpath(pwd))

%%
tuning_rule_ise=TuningRule;
tuning_rule_ise.rule_type=TuningRuleType.pm_based;
tuning_rule_ise.beta=-0.7357;
tuning_rule_ise.pm=20;
tuning_rule_ise.c1=0.3849;
tuning_rule_ise.c3=0.3817;
tuning_rule_ise.pm_min=20;
tuning_rule_ise.pm_max=90;
tuning_rule_ise.beta_min=-0.9;
tuning_rule_ise.beta_max=-0.1;

target_joint_cost = 1.10;
target_joint_cost_tol = 0.03;

%%
%inner loop process
quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.0181;
quad_att.list_of_T=[0.0273, 0.1979];

quad_att.findOptTuningRule(tuning_rule_ise);

%%
%corner processes
pivot_processes = generateProcessObjects('FOIPTD_outer', 1, [0.2, 6],[1],[0.0005, 0.1], tuning_rule_ise, quad_att);

%%
%discritize in T1 directions
[discrete_T1_values, list_of_T1_processes] = discritize_process_space(pivot_processes, "T1", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%discritize in tau directions
[discrete_tau_values, list_of_tau_processes] = discritize_process_space(pivot_processes, "tau", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%populate parameter space based on discrete values from discrete angular values of spherical coordinate system
list_of_discrete_processes = generateProcessObjects('FOIPTD_outer', 1, discrete_T1_values,[1],discrete_tau_values, tuning_rule_ise, quad_att);

%%
%Generate joint cost matrix
joint_cost = generate_joint_cost_matrix(list_of_discrete_processes, tuning_rule_PD);