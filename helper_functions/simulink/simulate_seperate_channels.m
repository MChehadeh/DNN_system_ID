clc
clear all
close all

%% Initialize Workspace

addpath utilities
global Quad;

%% Initialize the plot
figure()
init_plot;
plot_quad_model;

%% Initialize Variables

quad_variables;

%% Run Simulation


tSim   = 30;                        %simulation time in seconds
SimOut = sim('QCwithActDyn_seperate_channels',tSim);    %run simulink
% SimOut = sim('QCmanualPD',tSim);    %run simulink

%% Run The Simulation Loop
for S = 1 : 30 : size(SimOut.tout,1)  
    
    Quad.X = SimOut.x_out.Data(S);
    Quad.Y = SimOut.y_out.Data(S);
    Quad.Z = SimOut.z_out.Data(S);
    Quad.phi = SimOut.phi_out.Data(S);
    Quad.theta = SimOut.theta_out.Data(S);
    Quad.psi = SimOut.psi_out.Data(S);
  
    % Plot the Quadrotor's Position

        plot_quad         
%         campos([A.X+2 A.Y+2 A.Z+2])
%         camtarget([A.X A.Y A.Z])
%         camroll(pi);
        drawnow;
  
end

%%
%% Run The Simulation Loop
for S = 40000 : 50 : length(time)  
    
    Quad.X = meas_x(S);
    Quad.Y = meas_y(S);
    Quad.Z = meas_z(S);
    Quad.phi = meas_roll(S);
    Quad.theta = meas_pitch(S);
    Quad.psi = meas_yaw(S);
  
    % Plot the Quadrotor's Position

        plot_quad         
%         campos([A.X+2 A.Y+2 A.Z+2])
%         camtarget([A.X A.Y A.Z])
%         camroll(pi);
        drawnow;
  
end
%% Plot Data
figure();
plot(SimOut.tout,SimOut.x_out.Data)
hold on;
plot(SimOut.tout,SimOut.x_ref.Data,'LineWidth',1.5)
title('X');
xlabel('Time (s)')
ylabel('X (m)')
legend('simulation', 'reference')

figure();
plot(SimOut.tout,SimOut.y_out.Data)
hold on;
plot(SimOut.tout,SimOut.y_ref.Data,'LineWidth',1.5)
title('Y');
xlabel('Time (s)')
ylabel('Y (m)')
legend('simulation', 'reference')

figure();
plot(SimOut.tout,SimOut.z_out.Data,'LineWidth',1.5)
hold on;
plot(SimOut.tout,SimOut.z_ref.Data,'LineWidth',1.5)
title('Z');
xlabel('Time (s)')
ylabel('Z (m)')
legend('simulation', 'reference')

figure();
plot(SimOut.tout,SimOut.psi_out.Data)
hold on;
title('Psi');
xlabel('Time (s)')
ylabel('\psi (degrees)')
legend('simulation', 'reference')

figure();
plot(SimOut.tout,SimOut.phi_out.Data)
hold on;
plot(SimOut.tout,SimOut.phi_ref.Data,'LineWidth',1.5)
title('Phi');
xlabel('Time (s)')
ylabel('\phi (degrees)')
legend('simulation', 'reference')

figure();
plot(SimOut.tout,SimOut.theta_out.Data)
hold on;
plot(SimOut.tout,SimOut.theta_ref.Data,'LineWidth',1.5)
title('Theta');
xlabel('Time (s)')
ylabel('\theta (degrees)')
legend('simulation', 'reference')

