classdef MRFTController < handle
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
        function obj_copy = returnCopy(obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         obj_copy = MRFTController(0, 0);
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

