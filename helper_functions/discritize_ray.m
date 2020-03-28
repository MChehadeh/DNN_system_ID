function [radial_coefficient, radial_values] = discritize_ray(start_process, end_process, target_joint_cost, target_joint_cost_tolerance, tuning_rule)
%DISCRITIZE_LINE_R divides the vector from start_point to end_point in the
%radial direction into multiple points based on target deterioration
%This function is specific for discritizing the radial direction in 3D
%parameter space
%   Detailed explanation goes here


temp_process = end_process.returnCopy();
    
[joint_cost,min_joint_cost] = get_joint_cost(start_process, temp_process, tuning_rule);

if (min_joint_cost > target_joint_cost)
    
    
    [~, max_under_point] = start_process.get_spherical_params;
    [~, min_over_point] = temp_process.get_spherical_params;
    
    complete = false;
    while(~complete)  
        start_point_complete = false;               
        [joint_cost,min_joint_cost] = get_joint_cost(start_process, temp_process, tuning_rule);

        if abs(min_joint_cost-target_joint_cost)<=target_joint_cost_tolerance
           complete = true; 
        else
            %dividing approach
            if (min_joint_cost>target_joint_cost)
                [~, min_over_point] = temp_process.get_spherical_params;
            else
                [~, max_under_point] = temp_process.get_spherical_params;
            end

            temp_end_point = (min_over_point + max_under_point) / 2;
            temp_process.set_spherical_params(temp_end_point);
            temp_process.findOptTuningRule(tuning_rule);
        end
    end
end

[~, start_point_spherical_cor] = start_process.get_spherical_params;
[~, end_point_spherical_cor] = temp_process.get_spherical_params;

radial_coefficient = end_point_spherical_cor(1) / start_point_spherical_cor(1);

radial_values = start_point_spherical_cor(1);
radial_values = [radial_values; end_point_spherical_cor(1)];

%extend to end point
iterator = 2;
end_R_temp = end_point_spherical_cor(1);
while 1
    R_temp = end_R_temp * radial_coefficient^iterator;
    end_R_temp = R_temp;
    
    [~, limit_point_spherical_cor] = end_process.get_spherical_params;
    if (R_temp < limit_point_spherical_cor(1))
        radial_values = [radial_values; R_temp];
        iterator = iterator + 1;
    else
        break;
    end
end


end

