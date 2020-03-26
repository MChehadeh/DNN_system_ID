classdef Inner_process < Process
    %INNER_PROCESS 
   
    
    methods
        function [obj,g]=get_open_TF(obj)
            g=tf([obj.K],[obj.list_of_T(1) 1], 'IODelay', obj.tau);
            for i=2:obj.order
                g = g * 
          g1=tf([obj.K],[obj.T1 1]);
          g2=tf([1],[obj.T2 1 0],'InputDelay',obj.tau);
          g=g1*g2;
      end
    end
end

