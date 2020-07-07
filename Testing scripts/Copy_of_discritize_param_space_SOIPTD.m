%Discritization parameters
clear all
addpath(genpath(pwd))

%%
tuning_rule_ise=TuningRule;
tuning_rule_ise.rule_type=TuningRuleType.pm_based;
tuning_rule_ise.beta=-0.73;
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
%corner processes
pivot_processes = generateProcessObjects('SOIPTD', 1, [0.015, 0.3],[0.2, 2],[0.0005, 0.025], tuning_rule_ise, []);

%%
%discritize in theta direction
[discrete_theta_values, list_of_theta_processes] = discritize_process_space_spherical_cor(pivot_processes, "theta", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%discritize in theta direction
[discrete_phi_values, list_of_phi_processes] = discritize_process_space_spherical_cor(pivot_processes, "phi", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%populate parameter space based on discrete values from discrete angular values of spherical coordinate system
list_of_discrete_processes = populate_parameter_space(pivot_processes, discrete_theta_values, discrete_phi_values, target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%Generate joint cost matrix
joint_cost = generate_joint_cost_matrix(list_of_discrete_processes, tuning_rule_ise);