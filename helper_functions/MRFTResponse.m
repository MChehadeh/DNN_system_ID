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
        normalized_response_u {mustBeNumeric}    
        
        response_amplitude {mustBeNumeric}
        response_frequency {mustBeNumeric}
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
            pv_data = simOut.logsout.get('pv');
            obj.response_pv = pv_data.Values.Data;             
            u_tot = simOut.logsout.get('u');
            obj.response_u = u_tot.Values.Data;            
        end
        
        function get_cycle(obj)
        end
        
        function normalize_reponse(obj)
        end
       
    end
end
