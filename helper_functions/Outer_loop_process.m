classdef Outer_loop_process < Process
    properties
        inner_loop_process = Process
    end
   methods      
      function [obj,g]=get_open_TF(obj)
            [~, g_inner] = obj.inner_loop_process.get_closed_TF;
            
            g = g_inner * tf([obj.K],[obj.list_of_T(1) 1], 'IODelay', obj.tau);
            for i=2:obj.sysOrder
                g = g * tf([1],[obj.list_of_T(i), 1]);
            end
            for i=1:obj.num_of_integrators
                g = g * tf([1], [1 0]);
            end            
      end
   end
end