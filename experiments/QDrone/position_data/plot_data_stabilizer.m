close all;
time = stabilizer_data(1,:);

Plot_command = [1;... % P.1 - Reference Commands
                1;... % P.2 - Attitude Angle and Rate Control 
                1;... % P.3 - Stream Issues
                1;... % P.4 - Sample and Computation Time
                1;... % P.5 - Stabilizer Model Termination
                1;... % P.6 - Battery Level
                1];   % P.7 - Motor Commands

%% Safety log (2:6) [5]

sample_time         = stabilizer_data(2,:);
computation_time    = stabilizer_data(3,:);
stop_model          = stabilizer_data(4,:);
comm_issue          = stabilizer_data(5,:);
watchdog_issue      = stabilizer_data(6,:);

%% Controller log (7:20) [14]

% Thrust
cmd_thrust_throttle      = stabilizer_data(7,:); % in Newtons

% Attitude Commands
cmd_angle_roll           = stabilizer_data(8,:);
cmd_angle_pitch          = stabilizer_data(9,:);
cmd_angle_yaw            = stabilizer_data(10,:);

% Attitude Torques
cmd_torque_roll          = stabilizer_data(11,:);
cmd_torque_pitch         = stabilizer_data(12,:);
cmd_torque_yaw           = stabilizer_data(13,:);

% Controller Output Torque
ctrl_torque_roll_sat     = stabilizer_data(14,:); 
ctrl_torque_pitch_sat    = stabilizer_data(15,:);
ctrl_torque_yaw_sat      = stabilizer_data(16,:);

% Generatlized Force
cmd_thrust_throttle      = stabilizer_data(17,:); % Percentage thrust
net_torque_roll          = stabilizer_data(18,:); % Percentage Roll Cmd
net_torque_pitch         = stabilizer_data(19,:); % Percentage Pitch Cmd
net_torque_yaw           = stabilizer_data(20,:); % Percentage Yaw Cmd

%% Plant log (21:41) [21]

% Filter and Estimator
est_acc_roll        = stabilizer_data(21,:);
est_acc_pitch       = stabilizer_data(22,:);
est_acc_yaw         = stabilizer_data(23,:);
apprx_roll          = stabilizer_data(24,:);
apprx_pitch         = stabilizer_data(25,:);
est_roll            = stabilizer_data(26,:);
est_pitch           = stabilizer_data(27,:);
est_yaw             = stabilizer_data(28,:);

% DAQ
sensor_issue        = stabilizer_data(29,:);
battery_level       = stabilizer_data(30,:);
low_battery         = stabilizer_data(31,:);
gyro_x              = stabilizer_data(32,:);
gyro_y              = stabilizer_data(33,:);
gyro_z              = stabilizer_data(34,:);
acc_x               = stabilizer_data(35,:);
acc_y               = stabilizer_data(36,:);
acc_z               = stabilizer_data(37,:);

% Motor Commands
motor_1_per_cmd     = stabilizer_data(38,:);
motor_2_per_cmd     = stabilizer_data(39,:);
motor_3_per_cmd     = stabilizer_data(40,:);
motor_4_per_cmd     = stabilizer_data(41,:);

%% Mode

flight_mode         = stabilizer_data(42,:);

%% Signal conditioning for plots
%motor_cmd = [1 -1 1 1; 1 -1 -1 -1; 1 1 1 -1; 1 1 -1 1]*(stabilizer_data(21:24,:));

% Attitude Estimates
est_roll_deg    = (180/pi).*est_roll;
est_pitch_deg   = (180/pi).*est_pitch;
est_yaw_deg     = (180/pi).*est_yaw;

% Attitude Rate Estimates (HARDWARE FILTERED GYROSCOPE)
est_roll_rate_degps     = (180/pi).*gyro_x;
est_pitch_rate_degps    = (180/pi).*gyro_y;
est_yaw_rate_degps      = (180/pi).*gyro_z;

% Attitude Rate Rate Estimates
est_roll_acc_degpsps    = (180/pi).*est_acc_roll;
est_pitch_acc_degpsps   = (180/pi).*est_acc_pitch;
est_yaw_acc_degpsps     = (180/pi).*est_acc_yaw;

%% P.1 (1 plot) - Reference Commands 

if Plot_command(1)
    figure;
    hold on;
        plot(time, cmd_thrust_throttle, 'b');
        plot(time, cmd_torque_roll, 'r');
        plot(time, cmd_torque_pitch, 'g');
        plot(time, cmd_torque_yaw, 'k');
    hold off; grid on; grid minor; 
    legend('Throttle','Roll','Pitch','Yaw');
    title('Reference Torque commands received by Stabilizer');
    xlabel('Time (s)');
    ylabel('N, Nm');

    figure;
    hold on;
        plot(time, cmd_thrust_throttle, 'b');
        plot(time, cmd_angle_roll, 'r');
        plot(time, cmd_angle_pitch, 'g');
        plot(time, cmd_angle_yaw, 'k');
    hold off; grid on; grid minor; 
    legend('Throttle','Roll','Pitch','Yaw');
    title('Reference Attitude commands received by Stabilizer');
    xlabel('Time (s)');
    ylabel('N, rad, rad/s');

    figure;
    hold on;
        plot(time, cmd_thrust_throttle/20.44, 'b');
        plot(time, net_torque_roll, 'r');
        plot(time, net_torque_pitch, 'g');
        plot(time, net_torque_yaw, 'k');
    hold off; grid on; grid minor; 
    legend('Throttle','Roll','Pitch','Yaw');
    title('Generalized Force Command (%) ');
    xlabel('Time (s)');
    ylabel('%');
end

%% P.2 (2 plots) - Attitude Angle and Rate

if Plot_command(2)
% P.2.1 Attitude Angle
    figure;
    title('Attitude Angle Control (roll and pitch)');
    subplot(2,1,1);
    hold on;
        plot(time, est_roll_deg, 'r');
    hold off; grid on; grid minor; 
    legend('Roll Estimate');
    xlabel('Time (s)');
    ylabel('deg');
    subplot(2,1,2);
    hold on;
        plot(time, est_pitch_deg, 'r');
    hold off; grid on; grid minor; 
    legend('Pitch Estimate');
    xlabel('Time (s)');
    ylabel('deg');

% P.2.2 Attitude Rate Control
    figure;
    title('Attitude Rate (Roll, Pitch and Yaw)');
    subplot(3,1,1);
    hold on;
        plot(time, est_roll_rate_degps, 'r');
    hold off; grid on; grid minor; 
    legend('Roll Rate Estimate');
    xlabel('Time (s)');
    ylabel('deg/s');
    subplot(3,1,2);
    hold on;
        plot(time, est_pitch_rate_degps, 'r');
    hold off; grid on; grid minor; 
    legend('Pitch Rate Estimate');
    xlabel('Time (s)');
    ylabel('deg/s');
    subplot(3,1,3);
    hold on;
        plot(time, est_yaw_rate_degps, 'r');
    hold off; grid on; grid minor; 
    legend('Yaw Rate Estimate');
    xlabel('Time (s)');
    ylabel('deg/s');
end

%% P.3 (1 plot) - Connection Issues

if Plot_command(3)
    figure; 
    subplot(2,1,1);  
        plot(time, comm_issue, 'b');
        grid on; grid minor;
    ylabel('bool'); xlabel('Time (s)'); title('Communication Issue');

    subplot(2,1,2); 
        plot(time, stop_model, 'b');
        grid on; grid minor;
    ylabel('bool'); xlabel('Time (s)'); title('Stop Model');
    
end

%% P.4 (1 plot) - Sample and Computation Time

if Plot_command(4)
    figure;
    hold on;
        plot(time, sample_time, 'b');
        plot(time, computation_time, 'r');
    hold off; grid on; grid minor; 
    legend('Sample Time','Computation Time');
    title('Model Sample and Computation Time');
    xlabel('Time (s)');
    ylabel('s');
end

%% P.5 (1 plot) - Stabilizer Model Termination

if Plot_command(5)
    figure; title('Sensor Issues');
    subplot(3,1,1); 
        plot(time, sensor_issue, 'b');
        grid on; grid minor; 
    ylabel('bool'); xlabel('Time (s)'); title('Onboard sensor issue detected');

    subplot(3,1,2);
        plot(time, low_battery, 'b');
        grid on; grid minor; 
    ylabel('bool'); xlabel('Time (s)'); title('Low battery detected');

    subplot(3,1,3); 
        plot(time, watchdog_issue, 'b');
        grid on; grid minor; 
    ylabel('bool'); xlabel('Time (s)'); title('Watchdog timeout');
end

%% P.6 (1 plot) - Battery Level

if Plot_command(6)
    figure;
    hold on;
        plot(time, battery_level, 'b');
    hold off;
    title('Battery Level');
    xlabel('Time (s)');
    ylabel('Voltas (V)');
    grid on; grid minor;
end

%% P.7 (1 plot) - Motor Commands

if Plot_command(7)
   
    figure; title('Motor Commands (Percentage of battery voltage)');
    subplot(4,1,1); 
        plot(time, motor_1_per_cmd, 'b');
        grid on; grid minor; 
    ylabel('%'); xlabel('Time (s)'); title('Motor 1');

    subplot(4,1,2); 
        plot(time, motor_2_per_cmd, 'b');
        grid on; grid minor; 
    ylabel('%'); xlabel('Time (s)'); title('Motor 2');

    subplot(4,1,3); 
        plot(time, motor_3_per_cmd, 'b');
        grid on; grid minor; 
    ylabel('%'); xlabel('Time (s)'); title('Motor 3');

    subplot(4,1,4); 
        plot(time, motor_4_per_cmd, 'b');
        grid on; grid minor; 
    ylabel('%'); xlabel('Time (s)'); title('Motor 4');
end
