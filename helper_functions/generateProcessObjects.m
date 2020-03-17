function list_of_processes=generateProcessObjects(tau,T1,T2,K)
K=0;%TODO: Include K
num_of_processes=length(tau)*length(T1)*length(T2);
list_of_processes=TOPTD_process.empty(num_of_processes,0);
current_process=0;
for itr1=1:length(tau)
    for itr2=1:length(T1)
        for itr3=1:length(T2)
            current_process=current_process+1;
            list_of_processes(current_process).tau=tau(itr1);
            list_of_processes(current_process).T1=T1(itr2);
            list_of_processes(current_process).T2=T2(itr3);
            list_of_processes(current_process).K=1;
            list_of_processes(current_process).setID(current_process);
        end
    end
end
list_of_processes=list_of_processes';
length(list_of_processes)
end