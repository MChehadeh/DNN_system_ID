clear all
close all
clc
addpath(genpath(pwd))
%% Testing TOPTD_process
opt_tuning_rule_PI=TuningRule;
opt_tuning_rule_PI.rule_type=TuningRuleType.gm_based;
opt_tuning_rule_PI.beta=0.7;
opt_tuning_rule_PI.pm=30;
opt_tuning_rule_PI.c1=0.4058;
opt_tuning_rule_PI.c3=0.3585;
opt_tuning_rule_PI.pm_min=20;
opt_tuning_rule_PI.pm_max=90;
opt_tuning_rule_PI.beta_min=-0.9;
opt_tuning_rule_PI.beta_max=0.9;
opt_tuning_rule_PI.gm=5;
opt_tuning_rule_PI.gm_min=1.5;
opt_tuning_rule_PI.gm_max=inf;
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
opt_tuning_rule_PD.beta_max=0.9;

quad_acc=FOPTD_process;
quad_acc.K=1;
quad_acc.tau=0.005;
quad_acc.list_of_T=[0.0273];

quad_acc.findOptTuningRule(opt_tuning_rule_PI)
quad_acc.applyOptTuningRule(quad_acc.optTuningRule)
quad_acc.applyTuningRule(quad_acc.optTuningRule)


%% Testing generateProcessObjects FOPTD
list_of_processes=generateProcessObjects("FOPTD", 1, linspace(0.015,0.3,2), [], linspace(0.005, 0.030, 2), opt_tuning_rule_PI, []);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
