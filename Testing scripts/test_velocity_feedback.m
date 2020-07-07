%%
%This script aims to test the validity of step response optimal PD
%controllers for trajectory following
clear all
addpath(genpath(pwd+"\.."))

%%Definitions
%Define opt Tuning rule
optTuningRule_att=TuningRule;
optTuningRule_att.rule_type=TuningRuleType.pm_based;
optTuningRule_att.beta=-0.7;
optTuningRule_att.pm=20;
optTuningRule_att.c1=0.3849;
optTuningRule_att.c3=0.3817;
optTuningRule_att.pm_min=20;
optTuningRule_att.pm_max=90;
optTuningRule_att.beta_min=-0.9;
optTuningRule_att.beta_max=-0.1;

%Define system
quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.001;
quad_att.list_of_T=[0.03, 0.4];

%%
%obtain step response optimal PD
quad_att.findOptTuningRule(optTuningRule_att);
step_response_optimal_PD = quad_att.optController.returnCopy;

%%
%apply step optimal PD to trajectory
[~, cost_1, t_1, y_1, ref_1] = quad_att.getTrajectory(step_response_optimal_PD, 2*pi);
[~, cost_1b, t_1b, y_1b, ref_1b] = quad_att.getTrajectory(step_response_optimal_PD, 2*pi*0.5);
[~, cost_1c, t_1c, y_1c, ref_1c] = quad_att.getTrajectory(step_response_optimal_PD, 2*pi*2);

%%
%obtain trajectory optimal PD
quad_att.findTrajOptTuningRule(optTuningRule_att, 2*pi*2);
trajectory_optimal_PD = quad_att.optController.returnCopy;

%%
%apply step optimal PD to trajectory
[~, cost_2, t_2, y_2, ref_2] = quad_att.getTrajectory(trajectory_optimal_PD, 2*pi);
[~, cost_2b, t_2b, y_2b, ref_2b] = quad_att.getTrajectory(trajectory_optimal_PD, 2*pi*0.5);
[~, cost_2c, t_2c, y_2c, ref_2c] = quad_att.getTrajectory(trajectory_optimal_PD, 2*pi*2);

