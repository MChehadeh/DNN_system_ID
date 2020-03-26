function [procAssociatedWithOptTuningRule, list_of_max_deter]=getOptimalTuningRuleFromProcesses(list_of_processes,optimization_settings)
for itr=1:length(list_of_processes)
    if (list_of_processes(itr).optCost==0)
        itr
        list_of_processes(itr).findOptTuningRule(optimization_settings);
    end
end

list_of_worst_deter = zeros(length(list_of_processes), 0);

for itr=1:length(list_of_processes)
    list_of_max_deter(itr) = realmin;
    for itr2=1:length(list_of_processes)
        if (itr~=itr2)
            [~, ~, deterioration] = list_of_processes(itr2).applySubOptTuningRule(list_of_processes(itr).optTuningRule);
            if deterioration > list_of_max_deter(itr)
                list_of_max_deter(itr) = deterioration;
            end
        end
    end
end

procAssociatedWithOptTuningRule = list_of_processes(find(list_of_max_deter==min(list_of_max_deter)));

% least_worst_det=realmax;
% for itr=1:length(list_of_processes)
%     if (list_of_processes(itr).worstDeterioration<least_worst_det)
%         least_worst_det=list_of_processes(itr).worstDeterioration;
%         procAssociatedWithOptTuningRule=list_of_processes(itr);
%     end
% end
end