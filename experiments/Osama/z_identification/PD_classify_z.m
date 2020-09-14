function [P, D, I, T_1, T_2, time_delay, output_class] = PD_classify_z(enable, normalized_control_timeseries, normalized_error_timeseries, scaled_gain)
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
if isempty(systems)
    g = load('discrete_mesh_fullspace_compressed');
    systems = g.mesh_points;
end
if isempty(NN_model)
    g = load('trained_model');
    NN_model = g.trained_network_seg;
end

if enable
    data = zeros(length(normalized_error_timeseries), 1, 2, 1);
    data(:,1,1,1) = normalized_error_timeseries;
    data(:,1,2,1) = normalized_control_timeseries;
    
    class = classify(NN_model, data)
        
    temp_system = systems(class, :);
    T1 = temp_system(1); T2 = temp_system(2); tau = temp_system(3);
    Kp = temp_system(4) * scaled_gain; 
    Kd = temp_system(5) * scaled_gain;
    Ki = 0;
end

P=Kp; D=Kd; I=Ki; T_1=T1; T_2=T2; time_delay=tau; output_class=class;
end

