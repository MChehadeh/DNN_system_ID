function plot_window(position, heading, size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if heading=='x'
    x_pos = position(1) * ones(1,5);
    y_pos = position(2) + size(2) * [-0.5 0.5 0.5 -0.5 -0.5];    
    z_pos = position(3) + size(3) * [-0.5 -0.5 0.5 0.5 -0.5];    
end
plot3(x_pos, y_pos, z_pos);

