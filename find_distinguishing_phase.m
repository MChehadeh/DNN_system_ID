clear all
close all
clc
addpath(genpath(pwd))
%% Testing TOPTD_process, PIDcontroller and TuningRule
opt_tuning_rule_PI=TuningRule;
opt_tuning_rule_PI.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_PI.beta=0.15;
opt_tuning_rule_PI.pm=30;
opt_tuning_rule_PI.c1=0.4058;
opt_tuning_rule_PI.c3=0.3585;
opt_tuning_rule_PI.pm_min=20;
opt_tuning_rule_PI.pm_max=90;
opt_tuning_rule_PI.beta_min=-0.9;
opt_tuning_rule_PI.beta_max=0.9;
opt_tuning_rule_PI.controller_type = controllerType.PI;

opt_tuning_rule_PD=TuningRule;
opt_tuning_rule_PD.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_PD.beta=-0.7;%-0.6475;
opt_tuning_rule_PD.pm=20;%22;
opt_tuning_rule_PD.c1=0.4249;
opt_tuning_rule_PD.c3=0.3391;
opt_tuning_rule_PD.pm_min=20;%
opt_tuning_rule_PD.pm_max=90;
opt_tuning_rule_PD.beta_min=-0.9;
opt_tuning_rule_PD.beta_max=-0.1;

quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.0181;
quad_att.list_of_T=[0.0273, 0.1979];

quad_att.findOptTuningRule(opt_tuning_rule_PD)
quad_att.applyOptTuningRule(quad_att.optTuningRule)
quad_att.applyTuningRule(quad_att.optTuningRule)

quad_pos = FOIPTD_outer_process(quad_att);
quad_pos.K=20;
quad_pos.tau=0.05;
quad_pos.list_of_T=[1];

quad_pos.findOptTuningRule(opt_tuning_rule_PD)
quad_pos.applyOptTuningRule(quad_pos.optTuningRule)
quad_pos.applyTuningRule(quad_pos.optTuningRule)

quad_vel = FOPTD_outer_process(quad_att);
quad_vel.K=20;
quad_vel.tau=0.05;
quad_vel.list_of_T=[1];

quad_vel.findOptTuningRule(opt_tuning_rule_PI)
quad_vel.applyOptTuningRule(quad_vel.optTuningRule)
quad_vel.applyTuningRule(quad_vel.optTuningRule)

%% Testing generateProcessObjects SOIPTD
list_of_processes=generateProcessObjects('SOIPTD', 1, linspace(0.015,0.3,4),linspace(0.2, 2, 4),linspace(0.0005, 0.1, 4), opt_tuning_rule_PD, []);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
%% Testing generateProcessObjects FOIPTD_outer
list_of_processes=generateProcessObjects('FOIPTD_outer', 1, linspace(0.2,6,3),[1],linspace(0.0005, 0.1, 3), opt_tuning_rule_PD, quad_att);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
%% Testing generateProcessObjects FOPTD_outer
list_of_processes=generateProcessObjects('FOPTD_outer', 1, linspace(0.2,6,3),[1],linspace(0.0005, 0.1, 3), opt_tuning_rule_PI, quad_att);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);