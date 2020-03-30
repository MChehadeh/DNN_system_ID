function [R_limits,theta_limits, phi_limits] = getProcessSphericalLimits(process_list)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
min_R = realmax; max_R = realmin; 
min_theta = realmax; max_theta = realmin; 
min_phi = realmax; max_phi = realmin; 

for i=1:length(process_list)
    [~, temp_spherical_cor] = process_list(i).get_spherical_params;
    %R
    if temp_spherical_cor(1) < min_R
        min_R = temp_spherical_cor(1);
    end
    if temp_spherical_cor(1) > max_R
        max_R = temp_spherical_cor(1);
    end
    %theta
    if temp_spherical_cor(2) < min_theta
        min_theta = temp_spherical_cor(2);
    end
    if temp_spherical_cor(2) > max_theta
        max_theta = temp_spherical_cor(2);
    end
    %phi
    if temp_spherical_cor(3) < min_phi
        min_phi = temp_spherical_cor(2);
    end
    if temp_spherical_cor(3) > max_phi
        max_phi = temp_spherical_cor(3);
    end
end

R_limits = [min_R, max_R];
theta_limits = [min_theta, max_theta];
phi_limits = [min_phi, max_phi]; 

end

