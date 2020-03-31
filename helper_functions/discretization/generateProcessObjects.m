function list_of_processes=generateProcessObjects(process_type, K, T1, T2, tau, opt_tuning_rule, inner_process)
K=0;%TODO: Include K

if process_type == "SOIPTD"
    num_of_processes=length(tau)*length(T1)*length(T2);
    list_of_processes=[];
    for i=1:num_of_processes
        list_of_processes = [list_of_processes, SOIPTD_process()];
    end
%     list_of_processes=FOIPTD_outer_process.empty(num_of_processes,0);
%     for i=1:num_of_processes
%         list_of_processes(i).inner_loop_process = inner_process;
%     end
elseif process_type == "FOIPTD_outer"
    num_of_processes=length(tau)*length(T1);
    list_of_processes=[];
    for i=1:num_of_processes
        list_of_processes = [list_of_processes, FOIPTD_outer_process(inner_process)];
    end
%     list_of_processes=FOIPTD_outer_process.empty(num_of_processes,0);
%     for i=1:num_of_processes
%         list_of_processes(i).inner_loop_process = inner_process;
%     end
elseif process_type == "FOPTD_outer"
    num_of_processes=length(tau)*length(T1);
    list_of_processes=[];
    for i=1:num_of_processes
        list_of_processes = [list_of_processes, FOPTD_outer_process(inner_process)];
    end
else
    warning("not implemented: systems other than SOIPTD or FOIPTD_outer not implemented")
    return
end

if list_of_processes(1).sysOrder == 1
    current_process=0;
    for itr1=1:length(tau)
        for itr2=1:length(T1)
            current_process=current_process+1;
            list_of_processes(current_process).tau=tau(itr1);
            list_of_processes(current_process).list_of_T(1)=T1(itr2);
            list_of_processes(current_process).K=1;
            list_of_processes(current_process).setID(current_process);
            list_of_processes(current_process).findOptTuningRule(opt_tuning_rule);
        end
    end    
elseif list_of_processes(1).sysOrder == 2
    current_process=0;
    for itr1=1:length(tau)
        for itr2=1:length(T1)
            for itr3=1:length(T2)
                current_process=current_process+1;
                list_of_processes(current_process).tau=tau(itr1);
                list_of_processes(current_process).list_of_T(1)=T1(itr2);
                list_of_processes(current_process).list_of_T(2)=T2(itr3);
                list_of_processes(current_process).K=1;
                list_of_processes(current_process).setID(current_process);
                list_of_processes(current_process).findOptTuningRule(opt_tuning_rule);
            end
        end
    end 
else
    warning("not implemented: systems other than SOIPTD or FOIPTD_outer not implemented")
    return
end

list_of_processes=list_of_processes';

end