function [a,w]=get_system_phase_response(list_of_processes,test_phase)
%get_system_phase_response Finds system phase response from a list of
%processes
%   list_of_processes implements Process class, test phase is in degrees.
a=zeros(length(list_of_processes),1);
w=zeros(length(list_of_processes),1);


for k=1:length(list_of_processes)
    [~,g]=list_of_processes(k).get_open_TF;
    [w(k),a(k)]=TuningRule.get_w_mag_from_phase(g,test_phase);
end


end

