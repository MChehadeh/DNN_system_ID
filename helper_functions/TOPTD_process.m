classdef TOPTD_process < handle
    properties
        id {mustBeNumeric} =0
        K {mustBeNumeric}
        tau {mustBeNumeric}
        T1 {mustBeNumeric}
        T2 {mustBeNumeric}
        T_sim {mustBeNumeric} =0
        optTuningRule TuningRule = TuningRule
        optController PIDcontroller = PIDcontroller
        optCost {mustBeNumeric} = 0
        worstTuningRule TuningRule
        worstDeterioration {mustBeNumeric}=0
    end
   methods
      function obj = TOPTD_process(obj)
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
      end
      function obj = setID(obj,id_para)
          obj.id=id_para;
          obj.optTuningRule.id=id_para;
      end
      function obj = findOptTuningRule(obj,optimization_parameters)
          [a,obj.optCost,exitflag] = fminsearchbnd((@TOPTD_simulator_beta_pm),[optimization_parameters.beta optimization_parameters.pm],[optimization_parameters.beta_min optimization_parameters.pm_min],[optimization_parameters.beta_max optimization_parameters.pm_max],optimset('MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-8,'TolX',1e-10,'Display','none'),obj);
          obj.optTuningRule.setTuningParametersBetaPM(a(1),a(2));
          obj.applyOptTuningRule(obj.optTuningRule);
      end
      function [obj]=applyOptTuningRule(obj,tuning_rule)
          [~,g]=obj.getTF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          obj.optController=PIDcontroller;
          obj.optController.P=tuning_rule.c1/a0;
          Td=tuning_rule.c3*((2*pi)/w0);
          obj.optController.D=obj.optController.P*Td;
          [~,obj.optCost]=obj.getStep(obj.optController);
      end
      function [obj,res_controller,deterioration]=applySubOptTuningRule(obj,tuning_rule)
          [~,g]=obj.getTF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          res_controller=PIDcontroller;
          res_controller.P=tuning_rule.c1/a0;
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
      function [obj,Q]=applyTuningRule(obj,tuning_rule)
          [~,g]=obj.getTF;
          [w0,a0]=TuningRule.get_w_mag_from_phase(g,rad2deg(asin(tuning_rule.beta))-180);
          auxController=PIDcontroller;
          auxController.P=tuning_rule.c1/a0;
          Td=tuning_rule.c3*((2*pi)/w0);
          auxController.D=auxController.P*Td;
          [~,Q]=obj.getStep(auxController);
      end
      function [obj,g]=getTF(obj)
          g1=tf([obj.K],[obj.T1 1]);
          g2=tf([1],[obj.T2 1 0],'InputDelay',obj.tau);
          g=g1*g2;
      end
      function [obj,Q,t,y]=getStep(obj,PIDcontroller_obj)
          if (obj.T_sim==0)
              obj.T_sim=max([obj.tau obj.T1 obj.T2])*30; %TODO handle when proc parameters change
          end
          [~,g]=obj.getTF;
          [~,ctrl_tf]=PIDcontroller_obj.getTF;
          g_fb=feedback(g*ctrl_tf,1);
          [y,t] = step(g_fb,obj.T_sim);
          val_err=1-y;
          Q=trapz(t,val_err.*val_err)/obj.T_sim;
          %Q=trapz(t,abs(val_err))/obj.T_sim;
      end
   end
end