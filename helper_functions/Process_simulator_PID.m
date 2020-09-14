function f=Process_simulator_PID(x,varagin)
process=varagin{1};
if nargin > 1
    aux_controller = varagin{2}.returnCopy;
else
    aux_controller = PIDcontroller;
end
%set params
aux_controller.P = x(1);
aux_controller.I = 0;
aux_controller.D = x(3);
[~,f]=process.getStep(aux_controller);
end