classdef SOIPTD_process_filter < SOIPTD_process
    properties        
        FC {mustBeNumeric}=10
    end
   methods      
     function obj = SOIPTD_process_filter(obj, filter_fc)
          obj.sysOrder = 2;
          obj.num_of_integrators = 1;
          obj.optTuningRule=TuningRule;
          obj.FC = filter_fc;
          obj.optController=PIDcontroller_filter(NaN,filter_fc);
     end
     
     function obj_copy = returnCopy(obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         obj_copy = SOIPTD_process_filter(NaN, obj.FC);
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
          K = obj.K;
          T1 = obj.list_of_T(1);
          T2 = obj.list_of_T(2);
          tau = obj.tau;
          FC = obj.FC;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;   
          I = PIDcontroller_obj.I;           
          load_system("PD_controller_for_SOIPTD_filter_parametric.slx")
          set_param('PD_controller_for_SOIPTD_filter_parametric','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_controller_for_SOIPTD_filter_parametric.slx',[],options);
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
       
     function [obj,Q,t,y,ref]=getTrajectory(obj,PIDcontroller_obj, frequency_in)
          obj.set_T_sim();     
          t_final = obj.T_sim;
          [~, g_open] = obj.get_open_TF(false);
          K = obj.K;
          T1 = obj.list_of_T(1);
          T2 = obj.list_of_T(2);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;   
          I = PIDcontroller_obj.I;  
          frequency = frequency_in;
          load_system("PD_vel_controller_for_SOIPTD_parametric.slx")
          set_param('PD_vel_controller_for_SOIPTD_parametric','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_vel_controller_for_SOIPTD_parametric.slx',[],options); 
          %NOTE: this simulink file uses a transfer function block which
          %does not support fast restart
          y_data = simOut.logsout.get('pv');     
          t = y_data.Values.Time;  
          y = y_data.Values.Data;
          ref_data = simOut.logsout.get('ref'); 
          ref = ref_data.Values.Data;     
          val_err=ref-y;
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