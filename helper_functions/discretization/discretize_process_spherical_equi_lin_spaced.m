function processes_list=discretize_process_spherical_equi_lin_spaced(process_type,num_of_steps_spherical_cor,min_spherical_cor,max_spherical_cor)
% Discretizes a polar segment based on fixed step size
% process_type is string. Others are numbers
% spherical_cor: r,theta,phi
step_size=zeros(3,1);
for i=1:length(step_size)
    if (num_of_steps_spherical_cor(i)>0)
        step_size(i)=(max_spherical_cor(i)-min_spherical_cor(i))/num_of_steps_spherical_cor(i);
    else
        step_size(i)=0;
    end
end

%TODO: Refactor, not good
if strcmp(process_type,'SOIPTD')
    processes_list(num_of_steps_spherical_cor(1)+1,num_of_steps_spherical_cor(2)+1,num_of_steps_spherical_cor(3)+1)=SOIPTD_process;
end

for i=1:num_of_steps_spherical_cor(1)+1
    for j=1:num_of_steps_spherical_cor(2)+1
        for k=1:num_of_steps_spherical_cor(3)+1
            processes_list(i,j,k).K=1;
            processes_list(i,j,k).set_spherical_params([min_spherical_cor(1)+step_size(1)*(i-1);min_spherical_cor(2)+step_size(2)*(j-1);min_spherical_cor(3)+step_size(3)*(k-1)])
        end
    end
end