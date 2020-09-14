% close all;
time = commander_data(1,:);

Plot_command = [1;... % P.1 - Pose Plots
                1;... % P.2 - FSM Monitoring Plots
                1];   % P.3 - FSM State Plots

%% FSM Monitor Log (2:21) [20]

state_prev                  = commander_data(2,:);
initializing                = commander_data(3,:);
health_issue                = commander_data(4,:);
optitrack_issue             = commander_data(5,:);
comm_issue                  = commander_data(6,:);
low_battery                 = commander_data(7,:);
arm                         = commander_data(8,:);
cmd_takeoff                 = commander_data(9,:);
estop                       = commander_data(10,:);
throttle_at_trim            = commander_data(11,:);
throttle_near_zero          = commander_data(12,:);
ctrl_throttle_near_zero     = commander_data(13,:);
takeoff_success             = commander_data(14,:);
flying_too_low              = commander_data(15,:);
flying_too_high             = commander_data(16,:);
close_to_ground             = commander_data(17,:);
sensor_failure              = commander_data(18,:);
state_next                  = commander_data(19,:);
fsm_error                   = commander_data(20,:);
stop_model                  = commander_data(21,:);

%% Controller log (22:37)[16]

cmd_x               = commander_data(22,:);
cmd_y               = commander_data(23,:);
cmd_z               = commander_data(24,:);
cmd_yaw             = commander_data(25,:);
est_x               = commander_data(26,:);
est_y               = commander_data(27,:);
est_z               = commander_data(28,:);
est_yaw             = commander_data(29,:);
est_rate_x          = commander_data(30,:);
est_rate_y          = commander_data(31,:);
est_rate_z          = commander_data(32,:);
est_rate_yaw        = commander_data(33,:);
ref_thrust          = commander_data(34,:);
ref_torque_roll     = commander_data(35,:);
ref_torque_pitch    = commander_data(36,:);
ref_torque_yaw      = commander_data(37,:);

%% Pose Plots

if Plot_command(1)
    figure; 
    subplot(2,2,1);
    hold on;
    plot(time, est_x, 'r');
    plot(time, cmd_x, 'b');
    hold off;
    ylabel('X (m)');
    xlabel('time (s)');
    grid on; grid minor;
    legend('Estimated','Commanded');
    subplot(2,2,2);
    hold on;
    plot(time, est_y, 'r');
    plot(time, cmd_y, 'b');
    hold off;
    ylabel('Y (m)');
    xlabel('time (s)');
    grid on; grid minor;
    legend('Estimated','Commanded');
    subplot(2,2,3);
    hold on;
    plot(time, est_z, 'r');
    plot(time, cmd_z, 'b');
    hold off;
    ylabel('Z (m)');
    xlabel('time (s)');
    grid on; grid minor;
    legend('Estimated','Commanded');
    subplot(2,2,4);
    hold on;
    plot(time, est_yaw.*180/pi, 'r');
    plot(time, cmd_yaw.*180/pi, 'b');
    hold off;
    ylabel('Yaw (deg)');
    xlabel('time (s)');
    grid on; grid minor;
    legend('Estimated','Commanded');
end

%% FSM Monitoring Plots

if Plot_command(2)
    figure;
    subplot(4,4,1);
        plot(time, initializing);
        grid on; grid minor;
        title('Initializing');

    subplot(4,4,2);
        plot(time, health_issue);
        grid on; grid minor;
        title('Health Issue');

    subplot(4,4,3);
        plot(time, optitrack_issue);
        grid on; grid minor;
        title('OptiTrack Issue');

    subplot(4,4,4);
        plot(time, comm_issue);
        grid on; grid minor;
        title('Communication Issue with Mission Server');

    subplot(4,4,5);
        plot(time, low_battery);
        grid on; grid minor;
        title('Low Battery');

    subplot(4,4,6);
        plot(time, arm);
        grid on; grid minor;
        title('Arm');

    subplot(4,4,7);
        plot(time, cmd_takeoff);
        grid on; grid minor;
        title('Takeoff');

    subplot(4,4,8);
        plot(time, estop);
        grid on; grid minor;
        title('Emergency Stop');

    subplot(4,4,9);
        plot(time, throttle_at_trim);
        grid on; grid minor;
        title('Net Throttle at Trim value');

    subplot(4,4,10);
        plot(time, throttle_near_zero);
        grid on; grid minor;
        title('Net Throttle near Zero');

    subplot(4,4,11);
        plot(time, ctrl_throttle_near_zero);
        grid on; grid minor;
        title('Controller Throttle at Zero');

    subplot(4,4,12);
        plot(time, takeoff_success);
        grid on; grid minor;
        title('Takeoff Success');

    subplot(4,4,13);
        plot(time, flying_too_low);
        grid on; grid minor;
        title('Flying Too Low');

    subplot(4,4,14);
        plot(time, flying_too_high);
        grid on; grid minor;
        title('Flying Too High');

    subplot(4,4,15);
        plot(time, close_to_ground);
        grid on; grid minor;
        title('Close To Ground');

    subplot(4,4,16);
        plot(time, sensor_failure);
        grid on; grid minor;
        title('Sensor Failure');
end    

%% FSM State Plots

if Plot_command(3)
    figure;
    hold on;
    plot(time, 0.1.*state_prev, 'r');
    plot(time, 0.1.*state_next, 'b');
    plot(time, fsm_error, 'g');
    plot(time, stop_model, 'k');
    hold off;
    grid on; grid minor;
    title('State Machine Data');
    xlabel('Time (s)');
    legend('Previous State','Next State','Error', 'Stop Model');
end