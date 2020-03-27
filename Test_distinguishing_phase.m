clear all
close all
clc
addpath('helper_functions')
%% Testing TOPTD_process, PIDcontroller and TuningRule
opt_tuning_rule_ise=TuningRule;
opt_tuning_rule_ise.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_ise.beta=-0.9;
opt_tuning_rule_ise.pm=20;
opt_tuning_rule_ise.c1=0.4058;
opt_tuning_rule_ise.c3=0.3585;
opt_tuning_rule_ise.pm_min=20;
opt_tuning_rule_ise.pm_max=90;
opt_tuning_rule_ise.beta_min=-0.9;
opt_tuning_rule_ise.beta_max=-0.1;

opt_tuning_rule_iae=TuningRule;
opt_tuning_rule_iae.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_iae.beta=-0.85;%-0.6475;
opt_tuning_rule_iae.pm=24;%22;
opt_tuning_rule_iae.c1=0.4249;
opt_tuning_rule_iae.c3=0.3391;
opt_tuning_rule_iae.pm_min=20;
opt_tuning_rule_iae.pm_max=90;
opt_tuning_rule_iae.beta_min=-0.9;
opt_tuning_rule_iae.beta_max=-0.1;

quad_att=SOIPTD_process;
quad_att.K=5;
quad_att.tau=0.0121;
quad_att.list_of_T=[0.02, 0.5];

quad_att.findOptTuningRule(opt_tuning_rule_ise)
quad_att.applyOptTuningRule(quad_att.optTuningRule)
quad_att.applyTuningRule(quad_att.optTuningRule)

quad_pos = FOIPTD_outer_process(quad_att);
quad_pos.K=20;
quad_pos.tau=0.05;
quad_pos.list_of_T=[1];

quad_pos.findOptTuningRule(opt_tuning_rule_iae)
quad_pos.applyOptTuningRule(quad_pos.optTuningRule)
quad_pos.applyTuningRule(quad_pos.optTuningRule)

%% Testing generateProcessObjects SOIPTD
list_of_processes=generateProcessObjects('SOIPTD', 1, linspace(0.015,0.3,4),linspace(0.2, 2, 4),linspace(0.0005, 0.1, 4), opt_tuning_rule_ise, []);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
%% Testing generateProcessObjects FOIPTD_outer
list_of_processes=generateProcessObjects('FOIPTD_outer', 1, linspace(0.2,2,3),[1],linspace(0.0005, 0.1, 3), opt_tuning_rule_ise, quad_att);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);