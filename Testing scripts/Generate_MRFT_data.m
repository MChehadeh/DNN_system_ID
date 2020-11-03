%%
clear all
addpath(genpath(pwd))

%%
%load list of processes
load("discrete_processes_SOIPTD", "list_of_discrete_processes")

%%
%Data generation properties
time_step = 0.001;
t_final = 10; %final simulation time

N_response_per_process = 3; %number of times each process point is simulated 

mrft_controller = MRFTController(-0.73, 1);

%max relay bias percentage of the mrft_controller
max_bias_mag = 0.5;

%max noise power
max_noise_mag = 0.1;

%%
%Generate data
list_of_responses = [];

for i=1:length(list_of_discrete_processes)
    for j=1:N_response_per_process
        temp_mrft_response = MRFTResponse(list_of_discrete_processes(i), mrft_controller, t_final, time_step);
        temp_mrft_response.input_bias = max_bias_mag * (2*rand()-1) * mrft_controller.h_relay;
        temp_mrft_response.simulateResponse();        
        temp_mrft_response.add_noise(max_noise_mag * rand());
              
        list_of_responses = [list_of_responses; temp_mrft_response.returnCopy()];
    end
end

