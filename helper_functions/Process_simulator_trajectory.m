function f=Process_simulator_beta_pm(x, freuqncy_in, varagin)
process=varagin{1};
if nargin > 1
    aux_tuning_rule = varagin{2}.returnCopy;
else
    aux_tuning_rule = TuningRule;
end
aux_tuning_rule.setTuningParameters(x(1),x(2));
[~,f]=process.applyTrajectoryTuningRule(aux_tuning_rule, freuqncy_in);
end