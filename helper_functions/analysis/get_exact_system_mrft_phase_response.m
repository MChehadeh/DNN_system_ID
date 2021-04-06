function [a_exact,w_exact]=get_exact_system_mrft_phase_response(list_of_processes,test_phase)
%get_system_phase_response Finds system phase response from a list of
%processes
%   list_of_processes implements Process class, test phase is in degrees.

% Find exact response
h_relay=1;
N_response_per_process=1;
time_step=0.01;
t_final=200;
max_bias_mag=0;
max_noise_mag=0;
%This is just needed for the beta
optTuningRule_att=TuningRule;
optTuningRule_att.rule_type=TuningRuleType.pm_based;
optTuningRule_att.beta=sin(deg2rad(test_phase+180));
optTuningRule_att.pm=30;
optTuningRule_att.c1=1;
optTuningRule_att.c2=1;
optTuningRule_att.pm_min=0;
optTuningRule_att.pm_max=90;
optTuningRule_att.beta_min=-0.99;
optTuningRule_att.beta_max=0.99;

list_of_responses = generateResponses(list_of_processes, h_relay, optTuningRule_att, N_response_per_process, time_step, t_final, max_bias_mag, max_noise_mag);

a_exact=zeros(length(list_of_processes),1);
w_exact=zeros(length(list_of_processes),1);

for i=1:length(list_of_processes) %10,20
    a_exact(i)=list_of_responses(i).response_frequency*2*pi;
    w_exact(i)=list_of_responses(i).response_amplitude;
end


end

