clear all
close all
clc
addpath('helper_functions')
%% Testing TOPTD_process, PIDcontroller and TuningRule
opt_tuning_rule_ise=TuningRule;
opt_tuning_rule_ise.rule_type=TuningRuleType.pm_based;
opt_tuning_rule_ise.beta=-0.7308;
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

quad_att=TOPTD_process;
quad_att.K=5;
quad_att.tau=0.005;
quad_att.T1=0.05;
quad_att.T2=0.5;

quad_att.findOptTuningRule(opt_tuning_rule_iae)
quad_att.applyOptTuningRule(quad_att.optTuningRule)
quad_att.applyTuningRule(quad_att.optTuningRule)

%% Testing generateProcessObjects
list_of_processes=generateProcessObjects(linspace(0.0083333333333333,1.333333333333333,3),[1],linspace(1.333333333333333,5.833333333333333,3),1);
optProc=getOptimalTuningRuleFromProcesses(list_of_processes,opt_tuning_rule_iae);