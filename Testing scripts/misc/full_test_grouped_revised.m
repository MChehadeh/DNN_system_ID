%%
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

K_inner_limits = [10, 500];
tau_inner_limits = [5e-4, 25e-3];
T1_inner_limits = [0.015, 0.08];
T2_inner_limits = [0.2, 2];

K_outer_limits = [10, 500];
tau_outer_limits = [5e-4, 1e-1];
T1_outer_limits = [0.2, 6];

N_test = 50; %Number of test inputs

max_inner_loop_bias = 0.3;
max_outer_loop_bias = 0.3;

max_noise_power = 0.1;

%%
for i=1:length(list_of_inner_loop_processes)
    if (grp2idx(list_of_index_inner_loop(i))==3) || (grp2idx(list_of_index_inner_loop(i))==16) || (grp2idx(list_of_index_inner_loop(i))==21)
    %Define inner and outer loop system
    quad_att = list_of_inner_loop_processes(i).returnCopy();
    
    quad_pos = list_of_outer_loop_processes(i).returnCopy();



    %%
    %classify inner loop system
    load("attitude_identification_DNN", "trained_DNN");
    attitude_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");
    amplitude_scales_att = load("inner_loop_amplitude_scale", "list_of_amplitude_scales");
%     MRFT_responses_inner_loop = generateResponses([quad_att], 1, optTuningRule_att, 1, 0.001, 20, max_inner_loop_bias, max_noise_power);
%     list_of_inner_loop_MRFT_response(i) = MRFT_responses_inner_loop.returnCopy();
    MRFT_responses_inner_loop = list_of_inner_loop_MRFT_response(i).returnCopy();
    
    [Xtest_att, ~] = prepareDNNData(MRFT_responses_inner_loop, trained_DNN.Layers(1,1).InputSize(1));

    attitude_prediction = classify(trained_DNN, Xtest_att);
    list_of_index_inner_loop(i) = attitude_prediction;
    
    attitde_predicted_system = attitude_processes.list_of_discrete_processes(attitude_prediction);

    [~,~,normalized_gain_joint_cost_att,~] = get_joint_cost(attitde_predicted_system, quad_att, optTuningRule_att);
    list_of_inner_loop_normalized_joint_cost(i) = normalized_gain_joint_cost_att;
    [~, normalized_controller_att] = attitde_predicted_system.get_normalized_optController(optTuningRule_att);

    optAttitudeController_approximated_gain = normalized_controller_att.returnCopy();
    optAttitudeController_approximated_gain.P = optAttitudeController_approximated_gain.P * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_inner_loop.response_amplitude);
    optAttitudeController_approximated_gain.D = optAttitudeController_approximated_gain.D * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_inner_loop.response_amplitude);
    list_of_inner_loop_PD_approximated_gain(i) = optAttitudeController_approximated_gain.returnCopy();
    [~, prediction_cost_approximated_gain] = quad_att.getStep(optAttitudeController_approximated_gain);
    joint_cost__att_approximated_PD = prediction_cost_approximated_gain / quad_att.optCost;
    list_of_inner_loop_joint_cost_approximated_gain(i) = joint_cost__att_approximated_PD;

    optAttitudeController = normalized_controller_att.returnCopy();
    optAttitudeController.P = optAttitudeController.P * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(attitude_prediction) * MRFT_responses_inner_loop.response_amplitude);
    optAttitudeController.D = optAttitudeController.D * MRFT_responses_inner_loop.mrftcontroller.h_relay / ( amplitude_scales_att.list_of_amplitude_scales(attitude_prediction) * MRFT_responses_inner_loop.response_amplitude);
    list_of_inner_loop_PD(i) = optAttitudeController.returnCopy();
    [~, prediction_cost_att] = quad_att.getStep(optAttitudeController);
    joint_cost_att = prediction_cost_att / quad_att.optCost;
    list_of_inner_loop_joint_cost(i) = joint_cost_att;

    %%
    %Identify outer loop system
    class = num2str(double(attitude_prediction));
    
    if isfile(strcat('output_files/',class,'/identification_DNN.mat'))
        load(strcat('output_files/',class,'/identification_DNN'), "trained_DNN");
    else
        load(strcat('output_files/',class,'/identification_DNN_auto'), "trained_DNN");
    end
    position_processes = load(strcat('output_files/',class,'/discrete_processes'), "list_of_outer_loop_processes");
    optTuningRule_pos = load(strcat('output_files/',class,'/distinguishing_phase'), "optTuningRule");
    amplitude_scales_pos = load(strcat('output_files/',class,'/amplitude_scale'), "list_of_amplitude_scales");
    optTuningRule_pos = optTuningRule_pos.optTuningRule;

    %create outer loop copy 
    simulation_sys = quad_pos.returnCopy();
    simulation_sys.inner_loop_process.optController = optAttitudeController.returnCopy();

    MRFT_responses_outer_loop = generateResponses([simulation_sys], 1, optTuningRule_pos, 1, 0.001, 60, max_outer_loop_bias, max_noise_power);
    list_of_outer_loop_MRFT_response(i) = MRFT_responses_outer_loop.returnCopy();
    
    [Xtest_pos, ~] = prepareDNNData(MRFT_responses_outer_loop, trained_DNN.Layers(1,1).InputSize(1));

    position_prediction = classify(trained_DNN, Xtest_pos);
    list_of_index_outer_loop(i) = position_prediction;
        
    position_predicted_system = position_processes.list_of_outer_loop_processes(position_prediction);

    [~,~,double_normalized_gain_joint_cost_pos,~] = get_joint_cost_outer(position_predicted_system, quad_pos, optTuningRule_pos, optTuningRule_att);
    list_of_outer_loop_double_normalized_joint_cost(i) = double_normalized_gain_joint_cost_pos;
    
    [~,~,normalized_gain_joint_cost_pos,~] = get_joint_cost(position_predicted_system, quad_pos, optTuningRule_pos);
    list_of_outer_loop_normalized_joint_cost(i) = normalized_gain_joint_cost_pos;
    
    [~, normalized_controller_pos] = position_predicted_system.get_normalized_optController(optTuningRule_pos);
    
    optPositionController_approximated_gain = normalized_controller_pos.returnCopy();
    optPositionController_approximated_gain.P = optPositionController_approximated_gain.P * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_outer_loop.response_amplitude);
    optPositionController_approximated_gain.D = optPositionController_approximated_gain.D * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( (pi/4) * MRFT_responses_outer_loop.response_amplitude);
    list_of_outer_loop_PD_approximated_gain(i) = optPositionController_approximated_gain.returnCopy();
    [~, prediction_cost_pos_approximated_gain] = quad_pos.getStep(optPositionController_approximated_gain);
    joint_cost_pos_approximated_gain = prediction_cost_pos_approximated_gain / quad_pos.optCost;
    list_of_outer_loop_joint_cost_approximated_gain(i) = joint_cost_pos_approximated_gain;
     
    simulation_sys_approximated_gain = quad_pos.returnCopy();
    simulation_sys_approximated_gain.inner_loop_process.optController = optAttitudeController_approximated_gain.returnCopy();
    simulation_sys_approximated_gain.optController = optPositionController_approximated_gain.returnCopy();
    [~, prediction_cost_double_approximated_gain] = simulation_sys_approximated_gain.getStep(optPositionController_approximated_gain);
    joint_cost_double_approximated_gain = prediction_cost_double_approximated_gain / quad_pos.optCost;
    list_of_joint_cost_double_approximated_gain(i) = joint_cost_double_approximated_gain;
    
    [~, predicted_sys_TF] = simulation_sys_approximated_gain.get_open_TF();
    [~, PD_TF] = simulation_sys_approximated_gain.optController.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin_double_approximated_gain, ~, ~] = margin(full_TF);
    list_of_phase_margins_double_approximated_gain(i) = phase_margin_double_approximated_gain;
    
    optPositionController = normalized_controller_pos.returnCopy();
    optPositionController.P = optPositionController.P * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( amplitude_scales_pos.list_of_amplitude_scales(position_prediction) * MRFT_responses_outer_loop.response_amplitude);
    optPositionController.D = optPositionController.D * MRFT_responses_outer_loop.mrftcontroller.h_relay / ( amplitude_scales_pos.list_of_amplitude_scales(position_prediction) * MRFT_responses_outer_loop.response_amplitude);
    list_of_outer_loop_PD(i) = optPositionController.returnCopy();
    [~, prediction_cost_pos] = quad_pos.getStep(optPositionController);
    joint_cost_pos = prediction_cost_pos / quad_pos.optCost;
    list_of_outer_loop_joint_cost(i) = joint_cost_pos;
    
    simulation_sys.optController = optPositionController.returnCopy();
    [~, prediction_cost_full] = simulation_sys.getStep(optPositionController);
    joint_cost_full = prediction_cost_full / quad_pos.optCost;
    list_of_full_joint_cost(i) = joint_cost_full;
    
    [~, predicted_sys_TF] = simulation_sys.get_open_TF();
    [~, PD_TF] = simulation_sys.optController.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin, ~, ~] = margin(full_TF);
    list_of_phase_margins(i) = phase_margin;
    
    save('test_results_final_fixed', 'list_of_inner_loop_processes', 'list_of_outer_loop_processes','list_of_index_inner_loop','list_of_index_outer_loop','list_of_inner_loop_MRFT_response','list_of_outer_loop_MRFT_response','list_of_inner_loop_PD_approximated_gain','list_of_inner_loop_PD','list_of_outer_loop_PD_approximated_gain','list_of_outer_loop_PD','list_of_inner_loop_normalized_joint_cost','list_of_inner_loop_joint_cost_approximated_gain','list_of_inner_loop_joint_cost','list_of_outer_loop_normalized_joint_cost','list_of_outer_loop_double_normalized_joint_cost','list_of_outer_loop_joint_cost_approximated_gain','list_of_joint_cost_double_approximated_gain','list_of_outer_loop_joint_cost','list_of_full_joint_cost', 'list_of_phase_margins_double_approximated_gain', 'list_of_phase_margins');
    
    if rem(i, 50) == 0
        Simulink.sdi.clear;
    end
    end
end