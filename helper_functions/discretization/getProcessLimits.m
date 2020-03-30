function [K_limits, T1_limits,T2_limits, tau_limits] = getProcessLimits(process_list)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
min_K = realmax; max_K = realmin; 
min_T1 = realmax; max_T1 = realmin; 
min_T2 = realmax; max_T2 = realmin; 
min_tau = realmax; max_tau = realmin; 

for i=1:length(process_list)
    %K
    if process_list(i).K < min_K
        min_K = process_list(i).K;
    end
    if process_list(i).K > max_K
        max_K = process_list(i).K;
    end
    %T1
    if process_list(i).list_of_T(1) < min_T1
        min_T1 = process_list(i).list_of_T(1);
    end
    if process_list(i).list_of_T(1) > max_T1
        max_T1 = process_list(i).list_of_T(1);
    end
    %T2
    if process_list(1).sysOrder>1
        if process_list(i).list_of_T(2) < min_T2
            min_T2 = process_list(i).list_of_T(2);
        end
        if process_list(i).list_of_T(2) > max_T2
            max_T2 = process_list(i).list_of_T(2);
        end
    end
    %tau
    if process_list(i).tau < min_tau
        min_tau = process_list(i).tau;
    end
    if process_list(i).tau > max_tau
        max_tau = process_list(i).tau;
    end    
end

K_limits = [min_K, max_K];
T1_limits = [min_T1, max_T1];
T2_limits = [min_T2, max_T2];
tau_limits = [min_tau, max_tau];

if process_list(1).sysOrder==1
    T2_limits = [0,0];
end

end

