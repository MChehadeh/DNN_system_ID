classdef SOIPTD_process < Process
    properties
        
    end
   methods      
     function obj = SOIPTD_process(obj)
          obj.sysOrder = 2;
          obj.num_of_integrators = 1;
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
     end
     
     function [obj,Q,t,y]=getStep(obj,PIDcontroller_obj)
          obj.set_T_sim();       
          t_final = obj.T_sim;
          K = obj.K;
          T1 = obj.list_of_T(1);
          T2 = obj.list_of_T(2);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;   
          I = PIDcontroller_obj.I;   
          load_system("PD_controller_for_SOIPTD_parametric.slx")
          set_param('PD_controller_for_SOIPTD_parametric','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_controller_for_SOIPTD_parametric.slx',[],options);
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