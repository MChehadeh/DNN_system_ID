addpath(genpath(pwd))
load("attitude_identification_DNN", "trained_DNN");
% %%
% %iterate
% list_of_index_inner_loop = [];
% for i=1:length(list_of_inner_loop_MRFT_response)    
%     [Xtest_att, ~] = prepareDNNData(list_of_inner_loop_MRFT_response(i), trained_DNN.Layers(1,1).InputSize(1));
% 
%     attitude_prediction = classify(trained_DNN, Xtest_att);
%     list_of_index_inner_loop = [list_of_index_inner_loop, attitude_prediction];
% end

%%
addpath(genpath(pwd))
load('test_results_fixed.mat')

ignore_idx_1 = find(list_of_full_joint_cost>1.5);
ignore_idx_2 = find(list_of_phase_margins<10);
ignore_idx = union(ignore_idx_1, ignore_idx_2);

list_of_revised_joint_cost = [];
%%
for i=1:length(ignore_idx_2)
    idx = ignore_idx_2(i);
    attitude_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");


    inner_loop_process = list_of_inner_loop_processes(idx);
    outer_loop_process = list_of_outer_loop_processes(idx);

    %identified systems
    identified_inner_loop_process = attitude_processes.list_of_discrete_processes(list_of_index_inner_loop(idx));
    position_processes = load(strcat('output_files/',num2str(grp2idx(list_of_index_inner_loop(idx))),'/discrete_processes'), "list_of_outer_loop_processes");
    identified_outer_loop_process = position_processes.list_of_outer_loop_processes(list_of_index_outer_loop(idx));
    optTuningRule_pos = load(strcat('output_files/',num2str(grp2idx(list_of_index_inner_loop(idx))),'/distinguishing_phase'), "optTuningRule");
    amplitude_scales_pos = load(strcat('output_files/',num2str(grp2idx(list_of_index_inner_loop(idx))),'/amplitude_scale'), "list_of_amplitude_scales");
    amplitude_scales_att = load("inner_loop_amplitude_scale", "list_of_amplitude_scales");

    %%
    %generate MRFT response of predicted outer loop system against actual outer
    %loop system
    load(strcat('output_files/',num2str(grp2idx(list_of_index_inner_loop(idx))),'/identification_DNN2'), "trained_DNN");
    [x_truth, ~] = prepareDNNData(list_of_outer_loop_MRFT_response(idx), trained_DNN.Layers(1,1).InputSize(1));

    MRFT_responses_identified_sys = generateResponses([identified_outer_loop_process], 1, optTuningRule_pos.optTuningRule, 1, 0.001, 60, 0.1, 0);
    [x_identified, ~] = prepareDNNData(MRFT_responses_identified_sys, trained_DNN.Layers(1,1).InputSize(1));

    plot(x_identified(:,1,1,1));
    hold on
    plot(x_truth(:,1,1,1));

    %%
    %test
    position_prediction = classify(trained_DNN, x_truth);

    simulation_sys = outer_loop_process.returnCopy();
    simulation_sys.inner_loop_process.optController = list_of_inner_loop_PD(idx).returnCopy();

    [~, normalized_controller_pos] = position_processes.list_of_outer_loop_processes(position_prediction).get_normalized_optController(optTuningRule_pos.optTuningRule);
    optPositionController = normalized_controller_pos.returnCopy();
    optPositionController.P = optPositionController.P * list_of_outer_loop_MRFT_response(idx).mrftcontroller.h_relay / ( amplitude_scales_pos.list_of_amplitude_scales(position_prediction) * list_of_outer_loop_MRFT_response(idx).response_amplitude);
    optPositionController.D = optPositionController.D * list_of_outer_loop_MRFT_response(idx).mrftcontroller.h_relay / ( amplitude_scales_pos.list_of_amplitude_scales(position_prediction) * list_of_outer_loop_MRFT_response(idx).response_amplitude);

    simulation_sys.optController = optPositionController.returnCopy();
    [~, prediction_cost_full] = simulation_sys.getStep(optPositionController);
    joint_cost = prediction_cost_full / outer_loop_process.optCost;
    if joint_cost > 1.5
        list_of_index_inner_loop(idx)
        "whaaat"
    end

    list_of_revised_joint_cost = [list_of_revised_joint_cost, joint_cost];
    
    optPositionController = normalized_controller_pos.returnCopy();
    optPositionController.P = optPositionController.P * list_of_outer_loop_MRFT_response(idx).mrftcontroller.h_relay / ((pi/4) * list_of_outer_loop_MRFT_response(idx).response_amplitude);
    optPositionController.D = optPositionController.D * list_of_outer_loop_MRFT_response(idx).mrftcontroller.h_relay / ((pi/4) * list_of_outer_loop_MRFT_response(idx).response_amplitude);

    simulation_sys.inner_loop_process.optController = list_of_inner_loop_PD_approximated_gain(idx).returnCopy();
    [~, prediction_cost_full] = simulation_sys.getStep(optPositionController);
    joint_cost = prediction_cost_full / outer_loop_process.optCost;
    g=1;
end

list_of_original_joint_cost = list_of_full_joint_cost(ignore_idx);
