function [discrete_values, list_of_processes] = discritize_process_space_spherical_cor(pivot_points, discritize_basis, target_joint_cost, target_joint_cost_tolerance, tuning_rule)
%DISCRITIZE_LINE divides the vector from start_point to end_point into
%multiple points based on target deterioration
%Inputs:
%   - start_point: [gain T1 T2 tau R theta rho P_optimal D_optimal]
%   - end_point: [gain T1 T2 tau R theta rho P_optimal D_optimal] --> discritization direction is inferred from start and end point

if discritize_basis=="theta"
    discretize_vector = [0 1 0];
elseif discritize_basis=="phi"
    discretize_vector = [0 0 1];
else
    warning("not implemented: only discritization in theta or phi directions are permited")
    return
end

%TODO: Find most sensitive process from pivot processes

%find minimum and maximum points
min_value=realmax;
max_value=-realmax;
for i=1:length(pivot_points)
    [~, spherical_cor] = pivot_points(i).get_spherical_params;
    temp_point = dot(discretize_vector, spherical_cor);
    if (temp_point<min_value)
        min_value = temp_point;
        min_value_process = pivot_points(i).returnCopy();
    end
    if (temp_point>max_value)
        max_value = temp_point;
    end
end

[~, min_spherical_cor] = min_value_process.get_spherical_params;
max_value_process = min_value_process.returnCopy;
max_spherical_cor = max_value * discretize_vector + min_spherical_cor .* not(discretize_vector);
max_value_process.set_spherical_params(max_spherical_cor);
max_value_process.findOptTuningRule(tuning_rule);

[joint_cost,~] = get_joint_cost(min_value_process, max_value_process, tuning_rule);

if (joint_cost > target_joint_cost)
    temp_process_1 = min_value_process.returnCopy();
    temp_process_2 = max_value_process.returnCopy();
    
    temp_end_point = max_spherical_cor;
    
    discrete_values = min_value;
    list_of_processes = min_value_process.returnCopy();
    complete = false;
    while(~complete)  
        [~, max_under_point] = temp_process_1.get_spherical_params;
        [~, min_over_point] = temp_process_2.get_spherical_params;
        start_point_complete = false;
        while(~start_point_complete)               
            [joint_cost,~] = get_joint_cost(temp_process_1, temp_process_2, tuning_rule);

            if abs(joint_cost-target_joint_cost)<=target_joint_cost_tolerance
               start_point_complete = true; 
            else
                %dividing approach
                if (joint_cost>target_joint_cost)
                    [~, min_over_point] = temp_process_2.get_spherical_params;
                else
                    [~, max_under_point] = temp_process_2.get_spherical_params;
                end

                temp_end_point = (min_over_point + max_under_point) / 2;
                temp_process_2.set_spherical_params(temp_end_point);
                temp_process_2.findOptTuningRule(tuning_rule);
            end
        end

        discrete_values = [discrete_values; dot(temp_end_point, discretize_vector)];
        list_of_processes = [list_of_processes; temp_process_2.returnCopy];

        [joint_cost,~] = get_joint_cost(max_value_process, temp_process_2, tuning_rule);

        if (joint_cost < target_joint_cost + target_joint_cost_tolerance)
           complete = true; 
        else
            temp_process_1 = temp_process_2.returnCopy();
            temp_process_2 = max_value_process.returnCopy();
        end 
    end
    discrete_values = [discrete_values; max_value];
    list_of_processes = [list_of_processes; max_value_process.returnCopy];
else
    discrete_values = [min_value, max_value];
    list_of_processes = [min_value_process, max_value_process.returnCopy];
end


end

