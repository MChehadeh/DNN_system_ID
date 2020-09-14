function [P, D, I, T_1, T_2, time_delay, output_class] = PD_classify(enable, normalized_control_timeseries, normalized_error_timeseries, scaled_gain, optTuningRule)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent Kp;
persistent Kd;
persistent Ki;
persistent T1;
persistent T2;
persistent tau;
persistent class;
persistent systems;
persistent NN_model;
persistent amplitude_scale;

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
if isempty(T2)
    T2 = 0;
end
if isempty(tau)
    tau = 0;
end
if isempty(class)
    class = 0;
end
if isempty(systems) || isempty(amplitude_scale)
    g = load('discrete_processes_SOIPTD');
    systems = g.list_of_discrete_processes;
    g = load('inner_loop_amplitude_scale');
    amplitude_scale = g.list_of_amplitude_scales;
end
if isempty(NN_model)
%     g = load('attitude_identification_DNN');
    g = load(strcat('output_files/','inner_loop','/identification_DNN'));
    NN_model = g.trained_DNN;
end

if enable
    data = zeros(length(normalized_error_timeseries), 1, 2, 1);
    data(:,1,1,1) = normalized_error_timeseries;
    data(:,1,2,1) = normalized_control_timeseries;
    
    class = classify(NN_model, data)
        
    temp_system = systems(class);
    T1 = temp_system.list_of_T(1); T2 = temp_system.list_of_T(2); tau = temp_system.tau;
    [~, normalized_controller_att] = temp_system.get_normalized_optController(optTuningRule);
    Kp = normalized_controller_att.P * scaled_gain / amplitude_scale(class); 
    Kd = normalized_controller_att.D * scaled_gain / amplitude_scale(class);
    Ki = 0;
end

P=Kp; D=Kd; I=Ki; T_1=T1; T_2=T2; time_delay=tau; output_class=class;
end

