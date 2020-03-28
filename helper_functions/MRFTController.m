classdef MRFTController
    %MRFTCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        beta {mustBeNumeric}=0
        h_relay{mustBeNumeric} = 0.1
    end
    
    methods
        function obj = MRFTController(beta, h_relay)
            %MRFTCONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            obj.beta = beta;
            obj.h_relay = h_relay;
        end
    end
end

