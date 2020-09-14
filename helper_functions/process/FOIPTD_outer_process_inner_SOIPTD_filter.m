classdef FOIPTD_outer_process_inner_SOIPTD_filter < Outer_loop_process
    properties
    end
   methods      
     function obj = FOIPTD_outer_process_inner_SOIPTD_filter(inner_loop_process)
          obj.inner_loop_process = inner_loop_process.returnCopy();
          obj.sysOrder = 1;
          obj.num_of_integrators = 1;
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
     end
     
     function obj_copy = returnCopy(obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         obj_copy = FOIPTD_outer_process(Process);
         props = properties(obj);
         for i = 1:length(props)
            % Use Dynamic Expressions to copy the required property.
            % For more info on usage of Dynamic Expressions, refer to
            % the section "Creating Field Names Dynamically" in:
            % web([docroot '/techdoc/matlab_prog/br04bw6-38.html#br1v5a9-1'])
            if ismethod(obj_copy.(props{i}), 'returnCopy') && ~isempty(obj.(props{i}))
                obj_copy.(props{i}) = obj.(props{i}).returnCopy();
            else
                obj_copy.(props{i}) = obj.(props{i});
            end
         end
     end
      
     function [obj,Q,t,y]=getStep(obj,PIDcontroller_obj)
          obj.set_T_sim();       
          t_final = obj.T_sim;
          [~, g_open] = obj.get_open_TF(false);
          K = obj.K;
          T1 = obj.list_of_T(1);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;   
          I = PIDcontroller_obj.I;   
          K_inner = obj.inner_loop_process.K;
          T1_inner = obj.inner_loop_process.list_of_T(1);
          T2_inner = obj.inner_loop_process.list_of_T(2);
          tau_inner = obj.inner_loop_process.tau;
          P_inner = obj.inner_loop_process.optController.P;
          D_inner = obj.inner_loop_process.optController.D;
          I_inner = obj.inner_loop_process.optController.I;
          load_system("PD_controller_for_FOIPTD_with_inner_SOIPTD_filter.slx")
          set_param('PD_controller_for_FOIPTD_with_inner_SOIPTD_filter','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_controller_for_FOIPTD_with_inner_SOIPTD_filter.slx',[],options);
          y_data = simOut.logsout.get('pv');     
          t = y_data.Values.Time;  
          y = y_data.Values.Data;          
          val_err=1-y;
          simulation_status=simOut.logsout.get('simulation_status');
          if (sum(simulation_status.Values.Data)>0)
              Q=10e25;
          else          
              Q=trapz(t,val_err.*val_err)/obj.T_sim;
          end
          %Q=trapz(t,abs(val_err))/obj.T_sim;
     end
       
            
     function [obj,Q,Q_vel,t,y,ref,ref_mod]=getTrajectory(obj,PIDcontroller_obj, t_final_in, poly_x_in, original_poly_x_in)
          poly_x = poly_x_in;
          original_poly_x = original_poly_x_in;
          obj.set_T_sim();     
          t_final = t_final_in;
          [~, g_open] = obj.get_open_TF(false);
          K = obj.K;
          T1 = obj.list_of_T(1);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;   
          I = PIDcontroller_obj.I;   
          K_inner = obj.inner_loop_process.K;
          T1_inner = obj.inner_loop_process.list_of_T(1);
          T2_inner = obj.inner_loop_process.list_of_T(2);
          tau_inner = obj.inner_loop_process.tau;
          P_inner = obj.inner_loop_process.optController.P;
          D_inner = obj.inner_loop_process.optController.D;
          I_inner = obj.inner_loop_process.optController.I; 
          load_system("PD_controller_for_FOIPTD_with_inner_SOIPTD_filter.slx")
          set_param('PD_controller_for_FOIPTD_with_inner_SOIPTD_filter','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_controller_for_FOIPTD_with_inner_SOIPTD_filter.slx',[],options); 
          %NOTE: this simulink file uses a transfer function block which
          %does not support fast restart
          y_data = simOut.logsout.get('pv');   
          t = y_data.Values.Time;  
          y = y_data.Values.Data;
          y_dot_data = simOut.logsout.get('velocity'); 
          y_dot = y_dot_data.Values.Data;
          ref_data = simOut.logsout.get('ref'); 
          ref = ref_data.Values.Data;          
          ref_mod_data = simOut.logsout.get('modified_ref'); 
          ref_mod = ref_mod_data.Values.Data; 
          ref_dot_data = simOut.logsout.get('ref_dot'); 
          ref_dot = ref_dot_data.Values.Data;      
          val_err=ref-y;
          velocity_err = ref_dot - y_dot;
          simulation_status=simOut.logsout.get('simulation_status');
          if (sum(simulation_status.Values.Data)>0)
              Q=10e25;              
              Q_vel=10e25;
          else          
              Q=trapz(t,val_err.*val_err)/t_final;
              Q_vel=trapz(t,velocity_err.*velocity_err)/t_final;
          end
          %Q=trapz(t,abs(val_err))/obj.T_sim;
     end
       
     function Q=getTrajectoryCost(obj,PIDcontroller_obj, t_final_in, poly_x_in, original_poly_x_in)
          [~,Q_pos,Q_vel,~,~,~,~] = obj.getTrajectory(PIDcontroller_obj, t_final_in, poly_x_in, original_poly_x_in);
          Q = Q_pos + 0.05 * Q_vel;
     end
     
     function modified_poly_x=refineTraj(obj,PIDcontroller_obj, t_final_in, poly_x)
         initial_poly_x = zeros(9, size(poly_x, 2));
         initial_poly_x(1:size(poly_x, 1), :) = poly_x
         [modified_poly_x, Q] = fmincon(@(x) obj.getTrajectoryCost(PIDcontroller_obj, t_final_in, x, poly_x), initial_poly_x, [], []);
     end
   end
     
end
