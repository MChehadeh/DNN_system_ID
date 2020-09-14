function [P, D, I, T_1, time_delay, output_class] = PD_classify(enable, normalized_control_timeseries, normalized_error_timeseries, scaled_gain, optTuningRule, inner_loop_idx)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent Kp;
persistent Kd;
persistent Ki;
persistent T1;
persistent tau;
persistent class;
persistent systems;
persistent NN_model;

if isempty(Kp)
    Kp = 0;
end
if isempty(Kd)
    Kd = 0;
end
if isempty(Ki)
    Ki = 0;
end
if isempty(T1)
    T1 = 0;
end
if isempty(tau)
    tau = 0;
end
if isempty(class)
    class = 0;
end
if isempty(systems)
    g = load('output_files/' + string(inner_loop_idx) + '_vel/discrete_processes');
    systems = g.list_of_outer_loop_processes;
end
if isempty(NN_model)
    g = load('output_files/' + string(inner_loop_idx) + '_vel/identification_DNN');
    NN_model = g.trained_DNN;
end

if enable
    data = zeros(length(normalized_error_timeseries), 1, 2, 1);
    data(:,1,1,1) = normalized_error_timeseries;
    data(:,1,2,1) = normalized_control_timeseries;
    
    class = classify(NN_model, data)
        
    temp_system = systems(class);
    T1 = temp_system.list_of_T(1); tau = temp_system.tau;
    [~, normalized_controller_pos] = temp_system.get_normalized_optController(optTuningRule);
    Kp = normalized_controller_pos.P * scaled_gain * 4 / pi; 
    Ki = normalized_controller_pos.I * scaled_gain * 4 / pi;
    Kd = 0;
end

P=Kp; D=Kd; I=Ki; T_1=T1; time_delay=tau; output_class=class;
end

