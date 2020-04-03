classdef FOIPTD_outer_process < Outer_loop_process
    properties
    end
   methods      
     function obj = FOIPTD_outer_process(inner_loop_process)
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
            obj_copy.(props{i}) = obj.(props{i});
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
          load_system("PD_controller_for_FOIPTD_with_inner_SOIPTD_parametric.slx")
          set_param('PD_controller_for_FOIPTD_with_inner_SOIPTD_parametric','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_controller_for_FOIPTD_with_inner_SOIPTD_parametric.slx',[],options);
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
     
   end
end