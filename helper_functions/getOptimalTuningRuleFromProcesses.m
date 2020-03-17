function [procAssociatedWithOptTuningRule]=getOptimalTuningRuleFromProcesses(list_of_processes,optimization_settings)
for itr=1:length(list_of_processes)
    if (list_of_processes(itr).optCost==0)
        itr
        list_of_processes(itr).findOptTuningRule(optimization_settings);
    end
end
for itr=1:length(list_of_processes)
    for itr2=1:length(list_of_processes)
        if (itr~=itr2)
            list_of_processes(itr2).applySubOptTuningRule(list_of_processes(itr).optTuningRule);
        end
    end
end
least_worst_det=realmax;
for itr=1:length(list_of_processes)
    if (list_of_processes(itr).worstDeterioration<least_worst_det)
        least_worst_det=list_of_processes(itr).worstDeterioration;
        procAssociatedWithOptTuningRule=list_of_processes(itr);
    end
end
end