addpath(genpath(pwd));

%%
%load sys
inner_idx = 24; outer_idx=8;
load('output_files/24/discrete_processes.mat', 'list_of_outer_loop_processes')

%initial tuning rule
optTuningRule_att=TuningRule;
optTuningRule_att.rule_type=TuningRuleType.pm_based;
optTuningRule_att.beta=-0.7;
optTuningRule_att.pm=20;
optTuningRule_att.c1=0.3849;
optTuningRule_att.c3=0.3817;
optTuningRule_att.pm_min=20;
optTuningRule_att.pm_max=90;
optTuningRule_att.beta_min=-0.9;
optTuningRule_att.beta_max=0.9;

%%
%process
outer_loop_process = list_of_outer_loop_processes(outer_idx);
outer_loop_process.findOptTuningRule(optTuningRule_att);