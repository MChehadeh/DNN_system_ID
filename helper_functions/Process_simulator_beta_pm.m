function f=Process_simulator_beta_pm(x,varagin)
process=varagin{1,1};
aux_tuning_rule=TuningRule;
aux_tuning_rule.setTuningParametersBetaPM(x(1),x(2));
[~,f]=process.applyTuningRule(aux_tuning_rule);
end