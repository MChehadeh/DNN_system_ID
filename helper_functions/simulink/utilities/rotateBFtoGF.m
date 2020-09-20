% Wil Selby
% Washington, DC
% May 30, 2015

% This function rotates a point or matrix of points from the Body Frame to
% the Global Frame based on the quadrotor's Euler angles (orientation)

function [X,Y,Z]=rotateBFtoGF(X,Y,Z,phi,theta,psi)
  % define rotation matrix
  
  R_roll = [...
          1, 0, 0;...
          0, cos(phi), -sin(phi);...
          0, sin(phi), cos(phi)];
  R_pitch = [...
          cos(theta), 0, sin(theta);...
          0, 1, 0;...
          -sin(theta), 0, cos(theta)];
  R_yaw = [...
          cos(psi), -sin(psi), 0;...
          sin(psi), cos(psi), 0;...
          0, 0, 1];
  R_yaw1 = [...
          cos(pi/4), -sin(pi/4), 0;...
          sin(pi/4), cos(pi/4), 0;...
          0, 0, 1];
  R = R_yaw1'*R_roll'*R_pitch'*R_yaw';
%   
%   angle = norm([phi,theta,psi]);
% 
%     if(angle ~= 0)
%         euler_axis_ref = [phi,theta,psi] / angle;
%     else
%         euler_axis_ref = [0, 0, 0];
%     end
% 
%     quaternion = euler_axis_ref * sin(angle / 2);
%     quaternion = [cos(angle / 2), quaternion];
% 
%     R = quat2rotm(quaternion);
%     R = R';


  % rotate vertices
  B=size(X);
  
  for i=1:B(2)*B(1)
  pts = [X(i), Y(i), Z(i)]*R;
  
  X(i) = pts(:,1);
  Y(i) = pts(:,2);
  Z(i) = pts(:,3);
  end
end