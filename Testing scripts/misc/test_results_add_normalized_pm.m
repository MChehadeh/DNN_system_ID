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

%%
for i=1:length(list_of_inner_loop_processes)
    %classify inner loop system
    load("attitude_identification_DNN", "trained_DNN");
    attitude_processes = load("discrete_processes_SOIPTD", "list_of_discrete_processes");
    
    quad_att = list_of_inner_loop_processes(i).returnCopy();    
    quad_pos = list_of_outer_loop_processes(i).returnCopy();


    attitude_prediction = list_of_index_inner_loop(i);
    
    attitde_predicted_system = attitude_processes.list_of_discrete_processes(attitude_prediction);

    [~, normalized_controller_att] = attitde_predicted_system.get_normalized_optController(optTuningRule_att);
    
    [~, normalized_k_inner] = quad_att.normalize_gain_at_phase(optTuningRule_att);
    [~, predicted_sys_TF] = quad_att.get_open_TF();
    predicted_sys_TF = predicted_sys_TF * normalized_k_inner / quad_att.K;
    [~, PD_TF] = normalized_controller_att.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin, ~, ~] = margin(full_TF);
    list_of_phase_margins_inner_loop_normalized(i) = phase_margin;
        
    optAttitudeController_approximated_gain = list_of_inner_loop_PD_approximated_gain(i).returnCopy;
    [~, predicted_sys_TF] = quad_att.get_open_TF();
    [~, PD_TF] = optAttitudeController_approximated_gain.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin, ~, ~] = margin(full_TF);
    list_of_phase_margins_inner_loop_approximated_gain(i) = phase_margin;

    optAttitudeController = list_of_inner_loop_PD(i).returnCopy();
    [~, predicted_sys_TF] = quad_att.get_open_TF();
    [~, PD_TF] = optAttitudeController.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin, ~, ~] = margin(full_TF);
    list_of_phase_margins_inner_loop_exact_gain(i) = phase_margin;

    %%
    %Identify outer loop system
    class = num2str(double(attitude_prediction));
    
    position_processes = load(strcat('output_files/',class,'/discrete_processes'), "list_of_outer_loop_processes");
    optTuningRule_pos = load(strcat('output_files/',class,'/distinguishing_phase'), "optTuningRule");
    optTuningRule_pos = optTuningRule_pos.optTuningRule;

    position_prediction = list_of_index_outer_loop(i);        
    position_predicted_system = position_processes.list_of_outer_loop_processes(position_prediction);
    
    %create outer loop copy 
    simulation_sys = quad_pos.returnCopy();
    simulation_sys.inner_loop_process.K = normalized_k_inner;
    simulation_sys.inner_loop_process.optController = normalized_controller_att.returnCopy();
    [~, normalized_k_outer] = quad_pos.normalize_gain_at_phase(optTuningRule_pos);
    simulation_sys.K = normalized_k_outer;
    [~, normalized_controller_pos] = position_predicted_system.get_normalized_optController(optTuningRule_pos);
    simulation_sys.optController = normalized_controller_pos.returnCopy();
    
    [~, predicted_sys_TF] = simulation_sys.get_open_TF();
    [~, PD_TF] = simulation_sys.optController.getTF();
    full_TF = PD_TF * predicted_sys_TF;
    [~, phase_margin, ~, ~] = margin(full_TF);
    list_of_phase_margins_outer_loop_normalized(i) = phase_margin;
    
    save('test_results_fixed_with_pm', 'list_of_inner_loop_processes', 'list_of_outer_loop_processes','list_of_index_inner_loop','list_of_index_outer_loop','list_of_inner_loop_MRFT_response','list_of_outer_loop_MRFT_response','list_of_inner_loop_PD_approximated_gain','list_of_inner_loop_PD','list_of_outer_loop_PD_approximated_gain','list_of_outer_loop_PD','list_of_inner_loop_normalized_joint_cost','list_of_inner_loop_joint_cost_approximated_gain','list_of_inner_loop_joint_cost','list_of_outer_loop_normalized_joint_cost','list_of_outer_loop_double_normalized_joint_cost','list_of_outer_loop_joint_cost_approximated_gain','list_of_joint_cost_double_approximated_gain','list_of_outer_loop_joint_cost','list_of_full_joint_cost', 'list_of_phase_margins_double_approximated_gain', 'list_of_phase_margins', 'list_of_phase_margins_outer_loop_normalized', 'list_of_phase_margins_inner_loop_exact_gain', 'list_of_phase_margins_inner_loop_approximated_gain', 'list_of_phase_margins_inner_loop_normalized');
    
    if rem(i, 50) == 0
        Simulink.sdi.clear;
    end
end