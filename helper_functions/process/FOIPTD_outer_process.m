classdef FOIPTD_outer_process < Outer_loop_process
    properties
    end
   methods      
     function obj = FOIPTD_outer_process(inner_loop_process)
          obj.inner_loop_process = inner_loop_process;
          obj.sysOrder = 1;
          obj.num_of_integrators = 1;
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
     end
     
     function obj_copy = returnCopy(obj)
         % Construct a new object based on a deep copy of the current
         % object of this class by copying properties over.
         obj_copy = FOIPTD_outer_process(Process);
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