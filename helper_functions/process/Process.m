classdef Process < handle
    %Abstract class for process class
    properties
        id {mustBeNumeric} =0
        K {mustBeNumeric} =1
        tau {mustBeNumeric} 
        list_of_T {mustBeNumeric}
        sysOrder {mustBeNumeric} 
        num_of_integrators {mustBeNumeric}
        T_sim {mustBeNumeric} =0
        optTuningRule TuningRule = TuningRule
        optController PIDcontroller = PIDcontroller
        optCost {mustBeNumeric} = 0
        worstTuningRule TuningRule
        worstDeterioration {mustBeNumeric}=0
    end
    
    methods
        function obj = Process(obj)
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
        end
        
        function obj = setID(obj,id_para)
          obj.id=id_para;
          obj.optTuningRule.id=id_para;
        end
        
        function obj = setPID(obj,PIDcontroller)
          obj.optController=PIDcontroller;
          [~, Q] = getStep(obj,PIDcontroller);
          obj.optCost = Q;
        end
        
        function [obj,g]=get_open_TF(obj, varargin)
            if nargin > 1
              incorporate_delay = varargin{1};
            else
              incorporate_delay = true;
            end
            g= tf([obj.K],[obj.list_of_T(1) 1]);
            for i=2:obj.sysOrder
                g = g * tf([1],[obj.list_of_T(i), 1]);
            end
            for i=1:obj.num_of_integrators
                g = g * tf([1], [1 0]);
            end
            if(incorporate_delay)
                g = g * tf([1],[1], 'IODelay', obj.tau);
            end
        end
        
        function [obj,g]=get_closed_TF(obj)
            [~, g] = obj.optController.getFeedbackTF(obj);
        end
        
        function obj = findOptTuningRule(obj,optimization_parameters)
%           [a,obj.optCost,exitflag] = fminsearchbnd((@Process_simulator_beta_pm),[optimization_parameters.beta optimization_parameters.getTuningRuleMargin()],[optimization_parameters.beta_min optimization_parameters.getTuningRuleMarginLimits().min],[optimization_parameters.beta_max optimization_parameters.getTuningRuleMarginLimits().max],optimset('MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-8,'TolX',1e-10,'Display','none'),obj, optimization_parameters);
          g = @(x)Process_simulator_beta_pm(x, {obj, optimization_parameters});
          [a,obj.optCost,exitflag] = fmincon(g,[optimization_parameters.beta optimization_parameters.getTuningRuleMargin()], [], [], [], [], [optimization_parameters.beta_min optimization_parameters.getTuningRuleMarginLimits().min],[optimization_parameters.beta_max optimization_parameters.getTuningRuleMarginLimits().max], [], optimset('algorithm','sqp','MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-8,'TolX',1e-10, 'UseParallel', false, 'Display','none'));
          obj.optTuningRule.copyobj(optimization_parameters);
          obj.optTuningRule.setTuningParameters(a(1),a(2));
          obj.applyOptTuningRule(obj.optTuningRule);
        end
        
        function obj = findTrajOptTuningRule(obj,optimization_parameters, frequency_in)
%           [a,obj.optCost,exitflag] = fminsearchbnd((@Process_simulator_beta_pm),[optimization_parameters.beta optimization_parameters.getTuningRuleMargin()],[optimization_parameters.beta_min optimization_parameters.getTuningRuleMarginLimits().min],[optimization_parameters.beta_max optimization_parameters.getTuningRuleMarginLimits().max],optimset('MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-8,'TolX',1e-10,'Display','none'),obj, optimization_parameters);
          g = @(x)Process_simulator_trajectory(x, frequency_in, {obj, optimization_parameters});
          [a,obj.optCost,exitflag] = fmincon(g,[optimization_parameters.beta optimization_parameters.getTuningRuleMargin()], [], [], [], [], [optimization_parameters.beta_min optimization_parameters.getTuningRuleMarginLimits().min],[optimization_parameters.beta_max optimization_parameters.getTuningRuleMarginLimits().max], [], optimset('algorithm','sqp','MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-8,'TolX',1e-10, 'UseParallel', false, 'Display','none'));
          obj.optTuningRule.copyobj(optimization_parameters);
          obj.optTuningRule.setTuningParameters(a(1),a(2));
          obj.applyOptTuningRule(obj.optTuningRule);
        end
        
        function [obj]=applyOptTuningRule(obj,tuning_rule)
          [~,g]=obj.get_open_TF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          obj.optController=PIDcontroller;
          obj.optController.P=tuning_rule.c1/a0;
          Ti=tuning_rule.c2*((2*pi)/w0);
          obj.optController.I=obj.optController.P/Ti;
          Td=tuning_rule.c3*((2*pi)/w0);
          obj.optController.D=obj.optController.P*Td;
          [~,obj.optCost]=obj.getStep(obj.optController);
        end
        
        function [obj,res_controller,deterioration]=applySubOptTuningRule(obj,tuning_rule)
          [~,g]=obj.get_open_TF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          res_controller=PIDcontroller;
          res_controller.P=tuning_rule.c1/a0;
          Ti=tuning_rule.c2*((2*pi)/w0);
          res_controller.I=res_controller.P/Ti;
          Td=tuning_rule.c3*((2*pi)/w0);
          res_controller.D=res_controller.P*Td;
          [~,Q_sub]=obj.getStep(res_controller);
          if (obj.optCost==0)
              error('No optimal cost at id:%s',obj.id);
              return
          end
          deterioration=Q_sub/obj.optCost;
          if (deterioration<1)
              warning('suboptimal tuning rule (id:%d) outperformed optimal tuning rule (id:%d) on process (id:%d)',tuning_rule.id,obj.optTuningRule.id,obj.id);
              return
          end
          if (deterioration>obj.worstDeterioration)
              obj.worstDeterioration=deterioration;
              obj.worstTuningRule=tuning_rule;
          end
        end
        
        function [obj,Q, t, y]=applyTuningRule(obj,tuning_rule)
          [~,g]=obj.get_open_TF(true);
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          auxController=PIDcontroller;
          auxController.P=tuning_rule.c1/a0;
          Ti=tuning_rule.c2*((2*pi)/w0);
          auxController.I=auxController.P/Ti;
          Td=tuning_rule.c3*((2*pi)/w0);
          auxController.D=auxController.P*Td;
          [~, Q, t, y]=obj.getStep(auxController);
        end
        
       function [obj,Q, t, y]=applyTrajectoryTuningRule(obj,tuning_rule, frequency_in)
          [~,g]=obj.get_open_TF(true);
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          auxController=PIDcontroller;
          auxController.P=tuning_rule.c1/a0;
          Ti=tuning_rule.c2*((2*pi)/w0);
          auxController.I=auxController.P/Ti;
          Td=tuning_rule.c3*((2*pi)/w0);
          auxController.D=auxController.P*Td;
          [~, Q, t, y]=obj.getTrajectory(auxController, frequency_in);
        end
              
       function [obj,Q,t,y]=getStep(obj,PIDcontroller_obj)
          obj.set_T_sim();     
          t_final = obj.T_sim;
          [~, g_open] = obj.get_open_TF(false);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;       
          I = PIDcontroller_obj.I;
          load_system("PD_control.slx")
          set_param('PD_CONTROL','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_CONTROL.slx',[],options); 
          %NOTE: this simulink file uses a transfer function block which
          %does not support fast restart
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
       
       function [obj,Q,t,y,ref]=getTrajectory(obj,PIDcontroller_obj, freuqncy_in)
          obj.set_T_sim();     
          t_final = obj.T_sim;
          [~, g_open] = obj.get_open_TF(false);
          tau = obj.tau;
          P = PIDcontroller_obj.P;
          D = PIDcontroller_obj.D;       
          I = PIDcontroller_obj.I;
          frequency = freuqncy_in;
          load_system("PD_TRAJECTORY_CONTROL.slx")
          set_param('PD_TRAJECTORY_CONTROL','FastRestart','on');
          options = simset('SrcWorkspace','current');
          simOut = sim('PD_TRAJECTORY_CONTROL.slx',[],options); 
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
       
       
       function [obj]=set_T_sim(obj)
           if (obj.T_sim==0)
              obj.T_sim=max([obj.tau obj.list_of_T])*30; %TODO handle when proc parameters change
           end   
       end
       
       function [obj]=set_time_params(obj, time_params)
           T1 = time_params(1);
           T2 = time_params(2);
           tau = time_params(3);
           if obj.sysOrder == 2
             obj.list_of_T = [T1, T2];
             obj.tau = tau;
           elseif obj.sysOrder == 1
             obj.list_of_T = [T1];
             obj.tau =tau;
           else 
               warning("Not implemented: spherical conversion for systems wuth order higher than 2 not implemented") 
           end
       end
       
       function [obj, time_params]=get_time_params(obj)
           if obj.sysOrder == 2
             T1=obj.list_of_T(1);
             T2=obj.list_of_T(2);
             tau=obj.tau;
           elseif obj.sysOrder == 1
             T1=obj.list_of_T(1);
             T2=0;%theta
             tau=obj.tau;
           else 
               warning("Not implemented: spherical conversion for systems wuth order higher than 2 not implemented") 
           end
           time_params = [T1, T2, tau];
       end
       
       function [obj]=set_spherical_params(obj, spherical_cor)
           r = spherical_cor(1);
           theta = spherical_cor(2);
           phi = spherical_cor(3);
           if obj.sysOrder == 2
             obj.list_of_T = [r.*cos(theta).*sin(phi), r.*sin(theta).*sin(phi)];
             obj.tau =r.*cos(phi);
           elseif obj.sysOrder == 1
             obj.list_of_T = [r.*sin(phi)];
             obj.tau =r.*cos(phi);
           else 
               warning("Not implemented: spherical conversion for systems wuth order higher than 2 not implemented") 
           end
       end
       
       function [obj, spherical_cor]=get_spherical_params(obj)
           if obj.sysOrder == 2
             r=sqrt(obj.list_of_T(1).^2+obj.list_of_T(2).^2+obj.tau.^2);%r
             theta=atan(obj.list_of_T(2)./obj.list_of_T(1));%theta
             phi=acos(obj.tau./r);%phi
           elseif obj.sysOrder == 1
             r=sqrt(obj.list_of_T(1).^2+obj.tau.^2);%r
             theta=0;%theta
             phi=acos(obj.tau./r);%phi
           else 
               warning("Not implemented: spherical conversion for systems wuth order higher than 2 not implemented") 
           end
           spherical_cor = [r, theta, phi];
       end
       
       function [obj, normalized_K] = normalize_gain_at_phase(obj, tuning_rule)
          [~,g]=obj.get_open_TF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          normalized_K = obj.K*(1/a0);
       end
       
       function [obj, normalized_controller] = get_normalized_optController(obj, tuning_rule)
           [~, normalized_K] = normalize_gain_at_phase(obj, tuning_rule);
           normalized_controller = obj.optController.returnCopy();
           normalized_controller.P = obj.optController.P * obj.K / normalized_K;
           normalized_controller.D = obj.optController.D * obj.K / normalized_K;
           normalized_controller.I = obj.optController.I * obj.K / normalized_K;
       end
       
       function [obj,Q,t,y]=getStep_normalized_at_phase(obj, PIDcontroller_obj, tuning_rule)
          obj.set_T_sim();       
          [~, g_open] = obj.get_open_TF(false);
          [~, normalized_K] = normalize_gain_at_phase(obj, tuning_rule);
          normalized_process = obj.returnCopy();
          normalized_process.K = normalized_K;
          [~,Q,t,y] = normalized_process.getStep(PIDcontroller_obj);
       end
           
       function copyobj(obj, reference_obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         props = properties(reference_obj);
         for i = 1:length(props)
            % Use Dynamic Expressions to copy the required property.
            % For more info on usage of Dynamic Expressions, refer to
            % the section "Creating Field Names Dynamically" in:
            % web([docroot '/techdoc/matlab_prog/br04bw6-38.html#br1v5a9-1'])
            obj.(props{i}) = reference_obj.(props{i});
         end
       end
      
       function obj_copy = returnCopy(obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         obj_copy = Process;
         props = properties(obj);
         for i = 1:length(props)
            % Use Dynamic Expressions to copy the required property.
            % For more info on usage of Dynamic Expressions, refer to
            % the section "Creating Field Names Dynamically" in:
            % web([docroot '/techdoc/matlab_prog/br04bw6-38.html#br1v5a9-1'])
            obj_copy.(props{i}) = obj.(props{i});
         end
       end
   end
   
end

