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
   end
end