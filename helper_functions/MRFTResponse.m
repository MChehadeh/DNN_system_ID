classdef MRFTResponse < handle
    %MRFTRESPONSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        process
        mrftcontroller
        T_sim {mustBeNumeric} = 0
        step_time {mustBeNumeric} = 0.001
        input_bias {mustBeNumeric} = 0
        noise_power {mustBeNumeric} = 0        
        
        response_pv {mustBeNumeric}
        response_u {mustBeNumeric}
        single_cycle_response_pv {mustBeNumeric}
        single_cycle_response_u {mustBeNumeric}
        normalized_response_pv {mustBeNumeric}        
        noisy_response_pv {mustBeNumeric}
        
        response_amplitude {mustBeNumeric}
        response_frequency {mustBeNumeric}
        response_period {mustBeNumeric}
    end
    
    methods
        function obj = MRFTResponse(process, mrftcontroller, simulation_time, step_time)
            %MRFTRESPONSE Construct an instance of this class
            %   Detailed explanation goes here
            obj.process = process.returnCopy();
            obj.mrftcontroller = mrftcontroller.returnCopy();
            obj.T_sim = simulation_time;
            obj.step_time = step_time;
        end
        
        function simulateResponse(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            [~, open_loop_sys] = obj.process.get_open_TF();
            t_final = obj.T_sim;
            time_step = obj.step_time;
            h_mrft = obj.mrftcontroller.h_relay;
            beta_mrft = obj.mrftcontroller.beta;     
            bias_relay = obj.input_bias();
            [w0,a0]=TuningRule.get_w_mag_from_phase(open_loop_sys,rad2deg(asin(beta_mrft))-180);  
            options = simset('SrcWorkspace','current');
            simOut = sim('MRFT_CONTROL.slx',[],options);
            pv_data = logsout.get('pv');           
            u_tot = logsout.get('u');
            
            obj.response_pv = pv_data.Values.Data;  
            obj.response_u = u_tot.Values.Data;     
            
            obj.get_cycle();
            obj.normalize_reponse();
        end
        
        function [pv, u] = get_cycle(obj)
            %cycle is deterimented by two subsequent rising esgeds of the
            %mrft controller output
            cycle_start = 0;
            cycle_end = 0;
            
            for j=1:length(obj.response_u)-10
                if ((obj.response_u(end-j+1) - obj.response_u(end-j)) > 1.95 * obj.mrftcontroller.h_relay)
                    if cycle_end == 0
                        cycle_end = length(obj.response_u) - j;                    
                    else
                        cycle_start = length(obj.response_u) - j + 1;
                        break;
                    end
                end
            end
            
            obj.single_cycle_response_pv = obj.response_pv(cycle_start:cycle_end);
            obj.single_cycle_response_u = obj.response_u(cycle_start:cycle_end);
            
            obj.response_period = (cycle_end - cycle_start) * obj.step_time;
            obj.response_frequency = 1 / obj.response_period;
            obj.response_amplitude = (max(obj.single_cycle_response_pv) - min(obj.single_cycle_response_pv)) / 2;
            
            pv = obj.response_pv(cycle_start:cycle_end);
            u = obj.response_u(cycle_start:cycle_end);
        end
        
        function [pv, u] = normalize_reponse(obj)
            pv_offset = (max(obj.single_cycle_response_pv) + min(obj.single_cycle_response_pv)) / 2;
            obj.normalized_response_pv = (obj.single_cycle_response_pv - pv_offset) / obj.response_amplitude ;        
        end
        
        function [pv, u] = add_noise(obj, noise_power)
            obj.noise_power = noise_power;
            obj.noisy_response_pv = obj.normalized_response_pv + noise_power * 2 * (rand(length(obj.normalized_response_pv), 1) - 1);        
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
         obj_copy = MRFTResponse(Process, MRFTController(0,0), 0, 0);
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

