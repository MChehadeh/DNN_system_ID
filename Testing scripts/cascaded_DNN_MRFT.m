clear all
close all
clc
addpath(genpath(pwd))

%This script requires the discretization of the inner loop parameter space
%(refer to SOIPTD_discretization.m)
%%
%Options
inner_loop_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");
outer_process_type = "FOIPTD_outer";
range_of_T1 = [0.2, 6];
range_of_tau = [0.0005, 0.1];

%tuning rule options
%PD tuning rules for FOIPTD
tuning_rule_PD=TuningRule;
tuning_rule_PD.rule_type=TuningRuleType.pm_based;
tuning_rule_PD.beta=-0.7;
tuning_rule_PD.pm=20;
tuning_rule_PD.c1=0.4249;
tuning_rule_PD.c3=0.3391;
tuning_rule_PD.pm_min=20;
tuning_rule_PD.pm_max=90;
tuning_rule_PD.beta_min=-0.9;
tuning_rule_PD.beta_max=-0.1;

%PI tuning rules for FOPTD
tuning_rule_PI=TuningRule;
tuning_rule_PI.rule_type=TuningRuleType.gm_based;
tuning_rule_PI.beta=0.1512;
tuning_rule_PI.c1=0.3849;
tuning_rule_PI.c3=0.3817;
tuning_rule_PI.gm=1.7692;
tuning_rule_PI.gm_min=1.5;
tuning_rule_PI.gm_max=inf;
tuning_rule_PI.beta_min=-0.9;
tuning_rule_PI.beta_max=0.9;
tuning_rule_PI.controller_type = controllerType.PI;


%joint cost for discritization
target_joint_cost = 1.10;
target_joint_cost_tol = 0.03;

%mrft simulation settings
time_step = 0.001;
t_final = 60; %final simulation time
N_response_per_process_training = 30; %number of times each process point is simulated 
N_response_per_process_testing = 3; %number of times each process point is simulated 
max_noise_mag = 0.1;
max_bias_mag = 0.5;
h_relay = 1;

%%

for i=1:length(inner_loop_processes.list_of_discrete_processes)
    fprintf('Inner loop system IDa %.4f \n', i)
    mkdir('output_files/b' + string(i))
    
    inner_loop_process_i = inner_loop_processes.list_of_discrete_processes(i).returnCopy();
    
    %find distinguishing phase
    fprintf('Finding the distinguishing phase ... ')
    list_of_scattered_processes=generateProcessObjects(outer_process_type, 1, linspace(range_of_T1(1), range_of_T1(2), 3), [1], linspace(range_of_tau(1), range_of_tau(2), 3), tuning_rule_PD, inner_loop_process_i);
    [optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_scattered_processes);
    optTuningRule = optProc.optTuningRule.returnCopy();    
    fprintf('Done \n', i)
    fprintf('Distinguishing phase: %.4f', optTuningRule.beta)
    fprintf('Least Worst deterioration: %.4f', min(list_of_deter))
    save("output_files/b"+string(i)+"/distinguishing_phase.mat", "optTuningRule", "optProc", "list_of_deter");
    
    %clear simulink data to avoid running out of space
    Simulink.sdi.clear
    
    %discritize process
    fprintf('Discritizing process ...')
    pivot_processes=generateProcessObjects(outer_process_type, 1, range_of_T1, [1], range_of_tau, tuning_rule_PD, inner_loop_process_i);
    [discrete_T1_values, list_of_T1_processes] = discritize_process_space(pivot_processes, "T1", target_joint_cost, target_joint_cost_tol, optTuningRule);
    [discrete_tau_values, list_of_tau_processes] = discritize_process_space(pivot_processes, "tau", target_joint_cost, target_joint_cost_tol, optTuningRule);
    list_of_outer_loop_processes = generateProcessObjects(outer_process_type, 1, discrete_T1_values,[1],discrete_tau_values, optTuningRule, inner_loop_process_i);
    fprintf('Done \n', i)
    fprintf('Number of discrete processes: %.1f', length(list_of_outer_loop_processes))
    save("output_files/b"+string(i)+"/discrete_processes.mat", "discrete_T1_values", "discrete_tau_values", "list_of_outer_loop_processes");
    
    %clear simulink data to avoid running out of space
    Simulink.sdi.clear
    
    %Generate joint cost matrix
    fprintf('Generating Joint Cost Matrinx ...')
    joint_cost_matrix = generate_joint_cost_matrix(list_of_outer_loop_processes, optTuningRule);
    fprintf('Done \n')
    save("output_files/b"+string(i)+"/joint_cost.mat", "joint_cost_matrix")
    
    %clear simulink data to avoid running out of space
    Simulink.sdi.clear
    
    %Get training data    
    fprintf('Generating training data ...')
    MRFT_responses_training = generateResponses(list_of_outer_loop_processes, h_relay, optTuningRule, N_response_per_process_training, time_step, t_final, max_bias_mag, max_noise_mag);
    fprintf('Generating Joint Cost Matrinx ...')
    save("output_files/b"+string(i)+"/training_data.mat", "MRFT_responses_training");
    
    %clear simulink data to avoid running out of space
    Simulink.sdi.clear
    
    %Get testing data
    fprintf('Generating testing data ...')
    MRFT_responses_testing = generateResponses(list_of_outer_loop_processes, h_relay, optTuningRule, N_response_per_process_testing, time_step, t_final, max_bias_mag, max_noise_mag);
    fprintf('Done \n')
    save("output_files/b"+string(i)+"/testing_data.mat", "MRFT_responses_testing")

    %load for shortcut
%     files = dir('output_files/'+string(i));
%     for j=1:length(files)
%         if length(files(j).name) > 3
%             if files(j).name(end-2:end) == 'mat'
%                 load('output_files/'+string(i) + '/' + files(j).name)
%             end
%         end
%     end
    
    %Get exact amplitude scale    
    fprintf('Obtaining MRFT amplitude scaling factors ...')
    list_of_amplitude_scales = FindMRFTScaling(list_of_outer_loop_processes, h_relay, optTuningRule, time_step, t_final);
    fprintf('Done \n')
    save("output_files/b"+string(i)+"/amplitude_scale.mat", "list_of_amplitude_scales")
    
    %clear simulink data to avoid running out of space
    Simulink.sdi.clear
end
    

    
