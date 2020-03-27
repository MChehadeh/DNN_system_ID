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
    end
   methods 
       function obj=setTuningParametersBetaPM(obj,beta_para,pm_para)
           obj.beta=beta_para;
           obj.pm=pm_para;
           [obj.c1,obj.c3]=calculate_tuning_parameters_beta_pm( beta_para,pm_para );
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
       function [ c1,c3,phase_co ] = calculate_tuning_parameters_beta_pm( beta,pm )
            total_phase=rad2deg(asin(beta));
            x=tan(deg2rad(total_phase-pm));
            c3=x/(-2*pi);
            c1=1/sqrt(1+4*pi*pi*c3*c3);
            phase_co=total_phase-180;
       end
       function [ c1,phase_co ] = calculate_tuning_parameters_pm_c3( pm,c3 )
            c1=1/sqrt(1+4*pi*pi*c3*c3);
            phase_co=pm+rad2deg(atan(-2*pi*c3))-180;
       end

   end
end