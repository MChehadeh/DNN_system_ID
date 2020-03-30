classdef PIDcontroller < handle
    properties
        P {mustBeNumeric}=0
        I {mustBeNumeric}=0
        D {mustBeNumeric}=0
    end
   methods 
       function [obj,TF]=getTF(obj)
           TF=pid(obj.P,obj.I,obj.D);
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
end