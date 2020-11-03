clear all
close all
clc
addpath(genpath(pwd))

%% 
%Initialization of tuning rule
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

%% Find the distinguishing phase of SOIPTD process
%parameter range
T1_min = 0.015; T1_max = 0.3; 
T2_min = 0.2; T2_max = 2;
tau_min = 0.0005; tau_max = 0.1;
number_of_points = 3;

list_of_processes=generateProcessObjects('SOIPTD', 1, linspace(T1_min, T1_max,3),linspace(T2_min, T2_max, 3),linspace(tau_min, tau_max, 3), opt_tuning_rule_PD, []);
[optProc, list_of_deter]=getOptimalTuningRuleFromProcesses(list_of_processes);
optTuningRule = optProc.optTuningRule;
distinguishing_beta = optTuningRule.beta; 
save('output_files/inner_loop/distinguishing_phase.mat', 'optTuningRule', 'distinguishing_beta')

%% Discretize the SOIPTD parameter space
load('output_files/inner_loop/distinguishing_phase.mat')
tuning_rule_ise=optTuningRule;
target_joint_cost = 1.10;
target_joint_cost_tol = 0.03;

%corner processes (cartesian)
pivot_processes = generateProcessObjects('SOIPTD', 1, [T1_min, T1_max],[T2_min, T2_max],[tau_min, tau_max], tuning_rule_ise, []);

%Disxcretize in spherical coordinates
%discritize in theta direction
[discrete_theta_values, list_of_theta_processes] = discritize_process_space_spherical_cor(pivot_processes, "theta", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);
%discritize in phi direction
[discrete_phi_values, list_of_phi_processes] = discritize_process_space_spherical_cor(pivot_processes, "phi", target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%populate parameter space based on discrete values from discrete angular values of spherical coordinate system
list_of_discrete_processes = populate_parameter_space(pivot_processes, discrete_theta_values, discrete_phi_values, target_joint_cost, target_joint_cost_tol, tuning_rule_ise);

%Generate joint cost matrix
joint_cost = generate_joint_cost_matrix(list_of_discrete_processes, tuning_rule_ise);
save("output_files/inner_loop/discrete_processes_SOIPTD.mat", "list_of_discrete_processes", "joint_cost")

%% Generate training and testing data for the DNN training
%load list of processes
load("output_files/inner_loop/discrete_processes_SOIPTD.mat", "list_of_discrete_processes", "joint_cost")
load('output_files/inner_loop/distinguishing_phase.mat')

%Data generation properties
time_step = 0.001;
t_final = 10; %final simulation time

N_train_per_process = 5; %number of times each process point is simulated 
N_test_per_process = 1; %number of times each process point is simulated 

h_relay = 1; %mrft amplitude

mrft_controller = MRFTController(distinguishing_beta, h_relay);

%max relay bias percentage of the mrft_controller
max_bias_mag = 0.5;

%max noise power (uniformly distrubuted noise)
max_noise_mag = 0.1;

%%
%Generate data
MRFT_responses_training = [];
MRFT_responses_testing = [];

for i=1:length(list_of_discrete_processes)
    for j=1:N_train_per_process
        temp_mrft_response = MRFTResponse(list_of_discrete_processes(i), mrft_controller, t_final, time_step);
        temp_mrft_response.input_bias = max_bias_mag * (2*rand()-1) * mrft_controller.h_relay;
        temp_mrft_response.simulateResponse();        
        temp_mrft_response.add_noise(max_noise_mag * rand());
              
        MRFT_responses_training = [MRFT_responses_training; temp_mrft_response.returnCopy()];
    end
    
    for j=1:N_test_per_process
        temp_mrft_response = MRFTResponse(list_of_discrete_processes(i), mrft_controller, t_final, time_step);
        temp_mrft_response.input_bias = max_bias_mag * (2*rand()-1) * mrft_controller.h_relay;
        temp_mrft_response.simulateResponse();        
        temp_mrft_response.add_noise(max_noise_mag * rand());
              
        MRFT_responses_testing = [MRFT_responses_testing; temp_mrft_response.returnCopy()];
    end
end

save("output_files/inner_loop/training_data.mat", "MRFT_responses_training")
save("output_files/inner_loop/testing_data.mat", "MRFT_responses_testing")
