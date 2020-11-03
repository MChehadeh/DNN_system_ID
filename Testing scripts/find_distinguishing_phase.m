clear all
close all
clc
addpath(genpath(pwd))
%% Initialization of variables
opt_tuning_rule_PI=TuningRule;
opt_tuning_rule_PI.rule_type=TuningRuleType.gm_based;
%Info for Optimizer
opt_tuning_rule_PI.beta=0.15;
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
opt_tuning_rule_PD.beta_max=-0.1;

% process def
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

%% Find the distinguishing phase of SOIPTD process
T1_min = 0.015; T1_max = 0.3; 
T2_min = 0.2; T2_max = 2;
tau_min = 0.0005; tau_max = 0.1;
number_of_points = 3;
list_of_processes=generateProcessObjects('SOIPTD', 1, linspace(T1_min, T1_max,3),linspace(T2_min, T2_max, 3),linspace(tau_min, tau_max, 3), opt_tuning_rule_PD, []);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
optTuningRule = optProc.optTuningRule;
distinguishing_beta = optTuningRule.beta; 
%% Find the distinguishing phase of outer loop x and y position (FOIPTD)
T1_min = 0.2; T1_max = 6; 
tau_min = 0.0005; tau_max = 0.1;
number_of_points = 3;
list_of_processes=generateProcessObjects('FOIPTD_outer', 1, linspace(T1_min, T1_max,3),[1],linspace(tau_min, tau_max, 3), opt_tuning_rule_PD, quad_att);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
optTuningRule = optProc.optTuningRule;
distinguishing_beta = optTuningRule.beta;
%% Find the distinguishing phase of outer loop x and y velocity (FOPTD)
T1_min = 0.2; T1_max = 6; 
tau_min = 0.0005; tau_max = 0.1;
number_of_points = 3;
list_of_processes=generateProcessObjects('FOPTD_outer', 1, linspace(T1_min, T1_max,3),[1],linspace(tau_min, tau_max, 3), opt_tuning_rule_PI, quad_att);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
optTuningRule = optProc.optTuningRule;
distinguishing_beta = optTuningRule.beta;