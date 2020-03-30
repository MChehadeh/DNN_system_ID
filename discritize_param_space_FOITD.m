%Discritization parameters
clear all
addpath(genpath(pwd))

%%
tuning_rule_ise=TuningRule;
tuning_rule_ise.rule_type=TuningRuleType.pm_based;
tuning_rule_ise.beta=-0.5502;
tuning_rule_ise.pm=50.3448;
tuning_rule_ise.c1=0.4058;
tuning_rule_ise.c3=0.3585;
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
%discritize in theta directions
[discrete_phi_values, list_of_processes] = discritize_process_space(pivot_processes, "phi", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%%
%populate parameter space based on discrete values from discrete angular values of spherical coordinate system
list_of_discrete_processes = populate_parameter_space(pivot_processes, [0], discrete_phi_values, target_joint_cost, target_joint_cost_tol, tuning_rule_ise);
