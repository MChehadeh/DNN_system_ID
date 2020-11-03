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
quad_att.K=50;
quad_att.tau=0.0180;
quad_att.list_of_T=[0.0254, 0.2556];
quad_att.findOptTuningRule(optTuningRule_att);

quad_pos = FOIPTD_outer_process(quad_att);
quad_pos.K=50;
quad_pos.tau=0.0223;
quad_pos.list_of_T=[6];
quad_pos.findOptTuningRule(optTuningRule_att);

max_inner_loop_bias = 0.4;
max_outer_loop_bias = 0.3;

max_noise_power = 0.1;

%%
%classify inner loop system
load("attitude_identification_DNN", "trained_DNN");
attitude_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");
amplitude_scales_att = load("inner_loop_amplitude_scale", "list_of_amplitude_scales");
MRFT_responses_inner_loop = generateResponses([quad_att], 1, optTuningRule_att, 1, 0.001, 20, max_inner_loop_bias, max_noise_power);

[Xtest_att, ~] = prepareDNNData(MRFT_responses_inner_loop, trained_DNN.Layers(1,1).InputSize(1));

attitude_prediction = classify(trained_DNN, Xtest_att);

attitde_predicted_system = attitude_processes.list_of_discrete_processes(attitude_prediction);

[~,~,normalized_gain_joint_cost_att,~] = get_joint_cost(attitde_predicted_system, quad_att, optTuningRule_att);

[~, normalized_controller_att] = attitde_predicted_system.get_normalized_optController(optTuningRule_att);

optAttitudeController_approximated_gain = normalized_controller_att.returnCopy();
optAttitudeController_approximated_gain.P = optAttitudeController_approximated_gain.P * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_inner_loop.response_amplitude);
optAttitudeController_approximated_gain.D = optAttitudeController_approximated_gain.D * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_inner_loop.response_amplitude);

[~, prediction_cost_approximated_gain] = quad_att.getStep(optAttitudeController_approximated_gain);

joint_cost__att_approximated_PD = prediction_cost_approximated_gain / quad_att.optCost;

optAttitudeController = normalized_controller_att.returnCopy();
optAttitudeController.P = optAttitudeController.P * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(attitude_prediction) * MRFT_responses_inner_loop.response_amplitude);
optAttitudeController.D = optAttitudeController.D * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(attitude_prediction) * MRFT_responses_inner_loop.response_amplitude);

[~, prediction_cost_att] = quad_att.getStep(optAttitudeController);

joint_cost_att = prediction_cost_att / quad_att.optCost;

%%
%Identify outer loop system
class = num2str(double(attitude_prediction));
load(strcat('output_files/',class,'/identification_DNN_auto'), "trained_DNN");
position_processes = load(strcat('output_files/',class,'/discrete_processes'), "list_of_outer_loop_processes");
optTuningRule_pos = load(strcat('output_files/',class,'/distinguishing_phase'), "optTuningRule");
amplitude_scales_pos = load(strcat('output_files/',class,'/amplitude_scale'), "list_of_amplitude_scales");
optTuningRule_pos = optTuningRule_pos.optTuningRule;

%create outer loop copy 
simulation_sys = quad_pos.returnCopy();
simulation_sys.inner_loop_process.optController = optAttitudeController.returnCopy();

MRFT_responses_outer_loop = generateResponses([simulation_sys], 1, optTuningRule_pos, 1, 0.001, 50, max_outer_loop_bias, max_noise_power);

[Xtest_pos, ~] = prepareDNNData(MRFT_responses_outer_loop, trained_DNN.Layers(1,1).InputSize(1));

position_prediction = classify(trained_DNN, Xtest_pos);

position_predicted_system = position_processes.list_of_outer_loop_processes(position_prediction);

[~,~,double_normalized_gain_joint_cost_pos,~] = get_joint_cost_outer(position_predicted_system, quad_pos, optTuningRule_pos, optTuningRule_att);

[~,~,normalized_gain_joint_cost_pos,~] = get_joint_cost(position_predicted_system, quad_pos, optTuningRule_pos);

[~, normalized_controller_pos] = position_predicted_system.get_normalized_optController(optTuningRule_pos);

optPositionController_approximated_gain = normalized_controller_pos.returnCopy();
optPositionController_approximated_gain.P = optPositionController_approximated_gain.P * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_outer_loop.response_amplitude);
optPositionController_approximated_gain.D = optPositionController_approximated_gain.D * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_outer_loop.response_amplitude);

[~, prediction_cost_pos_approximated_gain] = quad_pos.getStep(optPositionController_approximated_gain);

joint_cost_pos_approximated_gain = prediction_cost_pos_approximated_gain / quad_pos.optCost;

simulation_sys_approximated_gain = quad_pos.returnCopy();
simulation_sys_approximated_gain.inner_loop_process.optController = optAttitudeController_approximated_gain.returnCopy();
simulation_sys_approximated_gain.optController = optPositionController_approximated_gain.returnCopy();
[~, prediction_cost_double_approximated_gain] = simulation_sys_approximated_gain.getStep(optPositionController_approximated_gain);
joint_cost_double_approximated_gain = prediction_cost_double_approximated_gain / quad_pos.optCost;
    
optPositionController = normalized_controller_pos.returnCopy();
optPositionController.P = optPositionController.P * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(position_prediction) * MRFT_responses_outer_loop.response_amplitude);
optPositionController.D = optPositionController.D * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(position_prediction) * MRFT_responses_outer_loop.response_amplitude);

[~, prediction_cost_pos] = quad_pos.getStep(optPositionController);

joint_cost_pos = prediction_cost_pos / quad_pos.optCost;

simulation_sys.optController = optPositionController.returnCopy();
[~, prediction_cost_full] = simulation_sys.getStep(optPositionController);
joint_cost_full = prediction_cost_full / quad_pos.optCost;

[~, predicted_sys_TF] = simulation_sys.get_open_TF();
[~, PD_TF] = simulation_sys.optController.getTF();
full_TF = PD_TF * predicted_sys_TF;
[~, phase_margin, ~, ~] = margin(full_TF);