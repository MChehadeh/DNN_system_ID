function [opt_process] = find_process_at_ray_with_freq_heuristic(process_seed,beta,target_freq,tolerance,use_MRFT)
%FIND_PROCESS_AT_RAY_WITH_FREQ Find the process at a specific ray with
%desired specific frequency
%   use_MRFT=1; get frequency response of MRFT
%   use_MRFT=0; get frequency response of bode
%   tolerance; absoulte in percentage: 0.01 means 1%
% current_freq=0;
% [~,param_init]=process_seed.get_spherical_params();
% 
% test_phase=rad2deg(asin(beta))-180;
% [a,w]=get_system_phase_response(process_seed,test_phase);
% param_init(1)=param_init(1)*(w/target_freq);
% param_init(1)=param_init(1)*(0.148478099480327);
% r_scale=1/param_init(1);
% r_bias=r_scale*param_init(1);
% r_min=-1;
% r_max=1;
% %DiffMinChange_val=param_init(1)*0.01;
% options = optimoptions('fmincon','Display','notify','OutputFcn',@check_for_fun_tol,'TolFun',1e-14,'TolX',1e-16,'OptimalityTolerance',1e-18,'DiffMinChange',0.01);
% 
% 
% [x,fval,exitflag,output]=fmincon(cost_fun,[0],[],[],[],[],[r_min],[r_max]...
%     ,[],options);
% process=process_seed.returnCopy();
% [~,param_opt]=process_seed.get_spherical_params();
% param_opt(1)=x;
% process.set_spherical_params(param_opt);
% x
% fval
% current_freq
% exitflag
% output
%     function stop = check_for_fun_tol(x,optimValues,state) 
%         stop = false;
%         if (abs((current_freq-target_freq)/target_freq) < tolerance)
%         stop = true; 
%         disp(strcat('Stopping, error f = ',num2str(current_freq-target_freq)));
%         end
%     end
% 
%     function f=get_exact_MRFT_err_abs(x,varagin)
%         seed_process=varagin{1};
%         [~,param_opt]=seed_process.get_spherical_params();
%         param_opt(1)=(x+1)*(1/r_scale);
%         seed_process.set_spherical_params(param_opt);
%         max_time_qty=max([seed_process.tau,seed_process.list_of_T(1),seed_process.list_of_T(2)]);
%         min_time_qty=min([seed_process.tau,seed_process.list_of_T(1),seed_process.list_of_T(2)]);
%         test_phase=rad2deg(asin(varagin{2}))-180;
%         [a,w]=get_system_phase_response(seed_process,test_phase);
%         if (w<0.1*target_freq)
%             current_freq=w;
%         elseif (w>10*target_freq)
%             current_freq=w;
%         else
%             % Find exact response
%             h_relay=1;
%             N_response_per_process=1;
%             time_step=(1/target_freq)*1e-3;
%             t_final=(1/target_freq)*100;
%             if (t_final>200)
%                 t_final=200;
%             end
%             max_bias_mag=0;
%             max_noise_mag=0;
%             %This is just needed for the beta
%             optTuningRule_att=TuningRule;
%             optTuningRule_att.rule_type=TuningRuleType.pm_based;
%             optTuningRule_att.beta=varagin{2};
%             optTuningRule_att.pm=30;
%             optTuningRule_att.c1=1;
%             optTuningRule_att.c2=1;
% 
% 
% 
% 
% 
%             list_of_responses = generateResponses(seed_process, h_relay, optTuningRule_att, N_response_per_process, time_step, t_final, max_bias_mag, max_noise_mag);
%             current_freq=list_of_responses(1).response_frequency;
%         end
%         disp_current_freq=current_freq;
%         %f=(log(abs(current_freq-varagin{3})/varagin{3}))^2;
%         f=(log(abs(current_freq)))^2;
%     end

test_phase=rad2deg(asin(beta))-180;
[a,w]=get_system_phase_response(process_seed,test_phase);
current_freq=0;
first_run=true;
while abs((current_freq-target_freq)/target_freq) > tolerance
    [~,param_init]=process_seed.get_spherical_params();
    if (first_run)
        param_init(1)=param_init(1)*(w/target_freq);
        first_run=false;
    else
        param_init(1)=param_init(1)*(current_freq/target_freq);
    end
    
    process_seed.set_spherical_params(param_init);
    
    % Find exact response
    h_relay=1;
    N_response_per_process=1;
    time_step=(1/target_freq)*1e-3;
    t_final=(1/target_freq)*100;
    if (t_final>200)
        t_final=200;
    end
    max_bias_mag=0;
    max_noise_mag=0;
    %This is just needed for the beta
    optTuningRule_att=TuningRule;
    optTuningRule_att.rule_type=TuningRuleType.pm_based;
    optTuningRule_att.beta=beta;
    optTuningRule_att.pm=30;
    optTuningRule_att.c1=1;
    optTuningRule_att.c2=1;
    
    list_of_responses = generateResponses(process_seed, h_relay, optTuningRule_att, N_response_per_process, time_step, t_final, max_bias_mag, max_noise_mag);
    current_freq=list_of_responses(1).response_frequency;
    
    

end
opt_process=process_seed;
end



%Initial point is a local minimum that satisfies the constraints.Optimization completed because at the initial point, the objective function is non-decreasing in feasible directions to within the value of the optimality tolerance, and constraints are satisfied to within the value of the constraint tolerance.<stopping criteria details>Optimization completed: The final point is the initial point.The first-order optimality measure, 0.000000e+00, is less than options.OptimalityTolerance =1.000000e-09, and the maximum constraint violation, 0.000000e+00, is less thanoptions.ConstraintTolerance = 1.000000e-06.
