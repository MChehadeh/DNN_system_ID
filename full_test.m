%%
clear all
addpath(genpath(pwd))

%%
%inner loop opt tuning rule
optTuningRule_att=TuningRule;
optTuningRule_att.rule_type=TuningRuleType.pm_based;
optTuningRule_att.beta=-0.73;
optTuningRule_att.pm=20;
optTuningRule_att.c1=0.3849;
optTuningRule_att.c3=0.3817;
optTuningRule_att.pm_min=20;
optTuningRule_att.pm_max=90;
optTuningRule_att.beta_min=-0.9;
optTuningRule_att.beta_max=-0.1;

%Define inner and outer loop system
quad_att=SOIPTD_process;
quad_att.K=1;
quad_att.tau=0.001;
quad_att.list_of_T=[0.03, 0.4];
quad_att.findOptTuningRule(optTuningRule_att);

quad_pos = FOIPTD_outer_process(quad_att);
quad_pos.K=20;
quad_pos.tau=0.005;
quad_pos.list_of_T=[1.5];
quad_pos.findOptTuningRule(optTuningRule_att);

%%
%classify inner loop system
load("attitude_identification_DNN", "trained_DNN");
attitude_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");
MRFT_responses_inner_loop = generateResponses([quad_att], 1, optTuningRule_att, 1, 0.001, 20, 0.5, 0.1);

[Xtest_att, ~] = prepareDNNData(MRFT_responses_inner_loop, 2500);

attitude_prediction = classify(trained_DNN, Xtest_att);

attitde_predicted_system = attitude_processes.list_of_discrete_processes(attitude_prediction);

[joint_cost,~] = get_joint_cost(attitde_predicted_system, quad_att, optTuningRule_att);

[~, normalized_controller_att] = attitde_predicted_system.get_normalized_optController(optTuningRule_att);

optAttitudeController = normalized_controller_att.returnCopy();
optAttitudeController.P = 4 * optAttitudeController.P * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( pi * MRFT_responses_inner_loop.response_amplitude);
optAttitudeController.D = 4 * optAttitudeController.D * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( pi * MRFT_responses_inner_loop.response_amplitude);


%%
%Identify outer loop system
load("output_files/25/identification_DNN", "trained_DNN");
position_processes = load("output_files/25/discrete_processes", "list_of_outer_loop_processes");
optTuningRule_pos = load("output_files/25/distinguishing_phase", "optTuningRule");
optTuningRule_pos = optTuningRule_pos.optTuningRule;

%create outer loop copy 
simulation_sys = quad_pos.returnCopy()
simulation_sys.inner_loop_process.optController = optAttitudeController.returnCopy();

MRFT_responses_outer_loop = generateResponses([simulation_sys], 1, optTuningRule_pos, 1, 0.001, 20, 0.5, 0.1);

[Xtest_pos, ~] = prepareDNNData(MRFT_responses_outer_loop, 2500);

position_prediction = classify(trained_DNN, Xtest_pos);

position_predicted_system = position_processes.list_of_outer_loop_processes(position_prediction);

[joint_cost,~] = get_joint_cost(position_predicted_system, quad_pos, optTuningRule_pos);

[~, normalized_controller_pos] = position_predicted_system.get_normalized_optController(optTuningRule_pos);

optPositionController = normalized_controller_pos.returnCopy();
optPositionController.P = 4 * optPositionController.P * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( pi * MRFT_responses_outer_loop.response_amplitude);
optPositionController.D = 4 * optPositionController.D * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( pi * MRFT_responses_outer_loop.response_amplitude);

