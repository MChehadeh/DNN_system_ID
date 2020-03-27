%Discritization parameters
clear all
addpath('helper_functions')

%%
opt_tuning_rule_ise=TuningRule;
opt_tuning_rule_ise.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_ise.beta=-0.5502;
opt_tuning_rule_ise.pm=50.3448;
opt_tuning_rule_ise.c1=0.4058;
opt_tuning_rule_ise.c3=0.3585;
opt_tuning_rule_ise.pm_min=20;
opt_tuning_rule_ise.pm_max=90;
opt_tuning_rule_ise.beta_min=-0.9;
opt_tuning_rule_ise.beta_max=-0.1;

target_joint_cost = 1.10;
target_joint_cost_tolerance = 0.03;

%%
%inner loop process
quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.0121;
quad_att.list_of_T=[0.02, 0.5];

quad_att.findOptTuningRule(opt_tuning_rule_ise);

%%
%corner processes
pivot_processes = generateProcessObjects('FOIPTD_outer', 1, [0.2, 2],[1],[0.0005, 0.1], opt_tuning_rule_ise, quad_att);

%%
%discritize in theta directions
[discrete_theta_values, list_of_processes] = discritize_process_space(pivot_processes, "phi", 1.10, 0.03, opt_tuning_rule_ise);

%%
%