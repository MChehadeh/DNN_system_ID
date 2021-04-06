function processes_list_radial=discretize_process_polar_equi_lin_spaced(process_type,num_of_r_steps,min_r,max_r,num_of_theta_steps,min_theta,max_theta)
% Discretizes a polar segment based on fixed step size
% process_type is string. Others are numbers
if (num_of_theta_steps>0)
    theta_step=(max_theta-min_theta)/num_of_theta_steps;
else
    theta_step=0;
end

if (num_of_r_steps>0)
    r_step=(max_r-min_r)/num_of_r_steps;
else
    r_step=0;
end

if strcmp(process_type,'FOPTD')
    processes_list_radial(num_of_r_steps+1,num_of_theta_steps+1)=FOPTD_process;
elseif strcmp(process_type,'FOIPTD')
    processes_list_radial(num_of_r_steps+1,num_of_theta_steps+1)=FOIPTD_process;
elseif strcmp(process_type,'FODIPTD')
    processes_list_radial(num_of_r_steps+1,num_of_theta_steps+1)=FODIPTD_process;
end

for i=1:num_of_r_steps+1
    for k=1:num_of_theta_steps+1
        processes_list_radial(i,k).K=1;
        processes_list_radial(i,k).tau=cos(min_theta+theta_step*(k-1))*(min_r+r_step*(i-1));
        processes_list_radial(i,k).list_of_T(1)=sin(min_theta+theta_step*(k-1))*(min_r+r_step*(i-1));
    end
end