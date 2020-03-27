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
      function [obj]=set_T_sim(obj)
           if (obj.T_sim==0)
              obj.T_sim=max([obj.inner_loop_process.tau obj.inner_loop_process.list_of_T obj.tau obj.list_of_T])*30; %TODO handle when proc parameters change
           end   
       end
   end
end