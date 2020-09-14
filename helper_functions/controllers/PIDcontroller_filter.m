classdef PIDcontroller_filter < PIDcontroller
    properties
        FC {mustBeNumeric}=10
    end
   methods 
       function obj = PIDcontroller_filter(obj, filter_fc)
           obj.FC = filter_fc;
       end
       
       function [obj,TF]=getTF(obj)
           TF= tf([obj.P], [1]) + tf([obj.I], [1 0]) + tf([obj.D 0], [1])*tf([obj.FC], [1 obj.FC])*tf([obj.FC], [1 obj.FC]);
       end
       
       function [obj, TF] = getFeedbackTF(obj, process)
           % This function return the feedback transfer function when the
           % PID controller is applied to a process. The D term is applied
           % to the derivative of the process value rather than the error
           % signal to avoid derivative kick.
           [~, g_open] = process.get_open_TF(false);
           g_D = g_open / (1 + g_open * pid(0,0, obj.D) * tf([obj.FC], [1 obj.FC]) * tf([obj.FC], [1 obj.FC]) * tf([1],[1],'IODelay', process.tau));
           g_PID = pid(obj.P, obj.I,0) * g_D;
           TF = g_PID / (1 + g_PID * tf([1],[1],'IODelay', process.tau));  
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
         obj_copy = PIDcontroller_filter(NaN, obj.FC);
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
end