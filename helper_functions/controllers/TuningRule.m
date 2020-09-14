classdef TuningRule < handle
    properties
        id {mustBeNumeric}
        beta {mustBeNumeric}=0
        beta_min {mustBeNumeric}= -0.99
        beta_max {mustBeNumeric}=0.99
        c1 {mustBeNumeric}
        c2 {mustBeNumeric}
        c3 {mustBeNumeric}
        pm {mustBeNumeric}=0
        pm_min {mustBeNumeric}=0
        pm_max {mustBeNumeric}=90
        gm {mustBeNumeric}
        gm_min {mustBeNumeric}=0
        gm_max {mustBeNumeric}=1000
        rule_type TuningRuleType = TuningRuleType.pm_based
        controller_type = controllerType.PD
    end
   methods 
       function obj=setTuningParameters(obj,beta_para, stability_margin)
           obj.beta=beta_para;
           if obj.rule_type == TuningRuleType.pm_based
            obj.pm=stability_margin;
           elseif obj.rule_type == TuningRuleType.gm_based
            obj.gm=stability_margin;
           end
           [obj.c1, obj.c2, obj.c3]=obj.calculate_tuning_parameters();
       end
       
       function [ c1,c2,c3,phase_co ] = calculate_tuning_parameters(obj)
            total_phase=rad2deg(asin(obj.beta));
            %TODO: incorporate controller type
            if obj.rule_type == TuningRuleType.pm_based
                %phase margin constraint
                x=tan(deg2rad(total_phase-obj.pm));
                c3=x/(-2*pi);
                c2 = inf;
                c1=1/sqrt(1+4*pi*pi*c3*c3);
            elseif obj.rule_type == TuningRuleType.gm_based
                %gain margin constraint
                x=tan(deg2rad(total_phase));
                c3 = 0;
                c2 = 1 / (2*pi*x);
                c1=1/(obj.gm *sqrt(1+(1/(4*pi*pi*c2*c2))));
            end
            phase_co=total_phase-180;
       end
       
       function margin = getTuningRuleMargin(obj)
           if obj.rule_type == TuningRuleType.pm_based
            margin = obj.pm;
           elseif obj.rule_type == TuningRuleType.gm_based
            margin = obj.gm;
           end
       end
       
       function margins = getTuningRuleMarginLimits(obj)
           if obj.rule_type == TuningRuleType.pm_based
            min = obj.pm_min;
            max = obj.pm_max;
           elseif obj.rule_type == TuningRuleType.gm_based
            min = obj.gm_min;
            max = obj.gm_max;
           end
           margins = struct("min",min,"max",max);
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
         obj_copy = TuningRule();
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
   end
   methods (Static)
       function [ w,mag ] = get_w_mag_from_phase( g_model,phase )
            p = phase;

            w=logspace(-1,3,10000);
            [mag_bode,phase,wout] = bode(g_model,w);

            mag = interp1( squeeze(phase), squeeze(mag_bode), p);
            w   = interp1( squeeze(phase), wout, p);
            if isnan(w)
                w=logspace(-2,4,10000);
                [mag_bode,phase,wout] = bode(g_model,w);

                mag = interp1( squeeze(phase), squeeze(mag_bode), p);
                w   = interp1( squeeze(phase), wout, p);
            end
           
       end

   end
end