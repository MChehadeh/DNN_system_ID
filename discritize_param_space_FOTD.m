%Discritization parameters
clear all
addpath(genpath(pwd))

%%
tuning_rule_PI=TuningRule;
tuning_rule_PI.rule_type=TuningRuleType.pm_based;
tuning_rule_PI.beta=0.9538;
tuning_rule_PI.pm=54.0838;
tuning_rule_PI.c1=0.3849;
tuning_rule_PI.c3=0.3817;
tuning_rule_PI.pm_min=20;
tuning_rule_PI.pm_max=90;
tuning_rule_PI.beta_min=-1;
tuning_rule_PI.beta_max=1;
tuning_rule_PI.controller_type = controllerType.PI;

tuning_rule_PD=TuningRule;
tuning_rule_PD.rule_type=TuningRuleType.pm_based;
tuning_rule_PD.beta=-0.7;
tuning_rule_PD.pm=54.0838;
tuning_rule_PD.c1=0.3849;
tuning_rule_PD.c3=0.3817;
tuning_rule_PD.pm_min=20;
tuning_rule_PD.pm_max=90;
tuning_rule_PD.beta_min=-1;
tuning_rule_PD.beta_max=0;
tuning_rule_PD.controller_type = controllerType.PD;

target_joint_cost = 1.10;
target_joint_cost_tol = 0.03;

%%
%inner loop process
quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.0181;
quad_att.list_of_T=[0.0273, 0.1979];

quad_att.findOptTuningRule(tuning_rule_PD);

%%
%corner processes
pivot_processes = generateProcessObjects('FOPTD_outer', 1, [0.2, 6],[1],[0.0005, 0.1], tuning_rule_PI, quad_att);

%%
%discritize in T1 directions
[discrete_T1_values, list_of_T1_processes] = discritize_process_space(pivot_processes, "T1", target_joint_cost, target_joint_cost_tol, tuning_rule_PI);

%%
%discritize in tau directions
[discrete_tau_values, list_of_tau_processes] = discritize_process_space(pivot_processes, "tau", target_joint_cost, target_joint_cost_tol, tuning_rule_PI);

%%
%populate parameter space based on discrete values from discrete angular values of spherical coordinate system
list_of_discrete_processes = generateProcessObjects('FOPTD_outer', 1, discrete_T1_values,[1],discrete_tau_values, tuning_rule_PI, quad_att);

%%
%Generate joint cost matrix
joint_cost = generate_joint_cost_matrix(list_of_discrete_processes, tuning_rule_PI);