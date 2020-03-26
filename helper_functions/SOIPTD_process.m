classdef SOIPTD_process < Process
    properties
        
    end
   methods      
     function obj = SOIPTD_process(obj)
          obj.sysOrder = 2;
          obj.num_of_integrators = 1;
          obj.optTuningRule=TuningRule;
          obj.optController=PIDcontroller;
     end
   end
end