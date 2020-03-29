function [process_list] = populate_parameter_space(pivot_processes, theta_values, phi_values, target_joint_cost, target_joint_cost_tol, tuning_rules)
%POPULATE_SPACE fills the 3D parameter space with discrete points based on
%discrete values of the spherical coordinates (theta, phi) and 
%maximum/minimum values of radial direction if they fall
%within the cartesian limits of T1, T2 and tau.
%   limits are: [min_value, max_value]

process_list = [];


%get min values of R and parameters
[R_limits, ~, ~] = getProcessSphericalLimits(pivot_processes);
[~, T1_limits, T2_limits, tau_limits] = getProcessLimits(pivot_processes);

%tolerance 
tol_T1 = 0.05 * T1_limits(1); 
tol_T2 = 0.05 * T2_limits(1); 
tol_tau = 0.05 * tau_limits(1); 

iterator = 1;

for i=1:length(theta_values)
    temp_theta = theta_values(i);
    for j=1:length(phi_values)
        temp_theta = theta_values(i);
        temp_phi = phi_values(j);
        
        i
        temp_theta
        j
        temp_phi
        
        start_point_process = pivot_processes(1).returnCopy();
        start_point_process.set_spherical_params([R_limits(1), temp_theta, temp_phi]); 
        
        end_point_process = pivot_processes(1).returnCopy();
        end_point_process.set_spherical_params([R_limits(2), temp_theta, temp_phi]);   
           
        
        %check if ray intersects cuboid
        if start_point_process.sysOrder == 2
            P0 = transpose([start_point_process.list_of_T(1), start_point_process.list_of_T(2), start_point_process.tau]);
            P1 = transpose([end_point_process.list_of_T(1), end_point_process.list_of_T(2), end_point_process.tau]);
        elseif start_point_process.sysOrder == 1
            P0 = transpose([start_point_process.list_of_T(1), 0, start_point_process.tau]);
            P1 = transpose([end_point_process.list_of_T(1), 0, end_point_process.tau]);
        else
            warning("Not implemented: Systems with order higher than two are not implemented yet")
            return
        end

        %get intersection with the cube, or the closest point to the
        %cube
        [intersection_status, closest_point] =  cuboid_line_intersect(T1_limits, T2_limits, tau_limits, P0, P1);
        intersection_status
        
        if(intersection_status == 2) %if ray doesn't intersect cuboid use closest point
           temp_process = pivot_processes(1).returnCopy();
           if temp_process.sysOrder==1
               temp_process.list_of_T = [closest_point(1)];
               temp_process.tau = [closest_point(3)];
           elseif temp_process.sysOrder==1
               temp_process.list_of_T = [closest_point(1), closest_point(2)];
               temp_process.tau = [closest_point(3)];
           else
               warning("Not implemented: Systems with order higher than two are not implemented yet")
               return
           end
           temp_process.findOptTuningRule(tuning_rules);
           temp_process.id = iterator; iterator = iterator + 1;
           process_list = [process_list; temp_process.returnCopy()];
           
        else        
            ray_representation = 0; %number of times the ray is represented in the cube

            %find radial value for the ray for the target deterioration
            start_point_process.findOptTuningRule(tuning_rules);
            end_point_process.findOptTuningRule(tuning_rules);
            [~, radial_values] = discritize_ray(start_point_process, end_point_process, target_joint_cost, target_joint_cost_tol, tuning_rules);
           
            temp_process = pivot_processes(1).returnCopy();
            for k=1:length(radial_values)        
                temp_R = radial_values(k);

                %convert from spherical coordinates
                temp_process.set_spherical_params([temp_R, temp_theta, temp_phi]);

                %check if within limits
                within_limits = false;
                if temp_process.sysOrder == 1 
                    if( (temp_process.list_of_T(1) >= (T1_limits(1)-tol_T1)) && (temp_process.list_of_T(1) <= (T1_limits(2)+tol_T1)) && ...
                            (temp_process.tau >= (tau_limits(1)-tol_tau)) && (temp_process.tau <= (tau_limits(2)+tol_tau)) )
                        within_limits = true;
                    end
                elseif temp_process.sysOrder == 2
                    if( (temp_process.list_of_T(1) >= (T1_limits(1)-tol_T1)) && (temp_process.list_of_T(1) <= (T1_limits(2)+tol_T1)) && ...
                            (temp_process.list_of_T(2) >= (T2_limits(1)-tol_T2)) && (temp_process.list_of_T(2) <= (T2_limits(2)+tol_T2)) && ...
                                (temp_process.tau >= (tau_limits(1)-tol_tau)) && (temp_process.tau <= (tau_limits(2)+tol_tau)) )
                        within_limits = true;
                    end
                end                    
                    
                if(within_limits)
                   %point is within limits
                   ray_representation = ray_representation + 1;
                   temp_process.findOptTuningRule(tuning_rules);
                   temp_process.id = iterator; iterator = iterator + 1;
                   process_list = [process_list; temp_process.returnCopy()];
                end
            end

            if(ray_representation == 0) %if the ray was not represented in the cube, use intersection
               
               if temp_process.sysOrder==1
                   temp_process.list_of_T = [closest_point(1)];
                   temp_process.tau = [closest_point(3)];
               elseif temp_process.sysOrder==2
                   temp_process.list_of_T = [closest_point(1), closest_point(2)];
                   temp_process.tau = [closest_point(3)];
               else
                   warning("Not implemented: Systems with order higher than two are not implemented yet")
                   return
               end
               temp_process.findOptTuningRule(tuning_rules);
               temp_process.id = iterator; iterator = iterator + 1;
               process_list = [process_list; temp_process.returnCopy()];
            end
         end
    end
end


                    

end

