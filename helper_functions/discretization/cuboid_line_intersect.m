function [status,intersection_point] = cuboid_line_intersect(cuboid_x, cuboid_y, cuboid_z,P0,P1)
%cuboid_LINE_INTERSECT Summary of this function goes here
%   Detailed explanation goes here

status = 0; 
intersection_point = [];
normals = eye(3);
vertices = [cuboid_x(1), cuboid_x(2);
            cuboid_y(1), cuboid_y(2);
            cuboid_z(1), cuboid_z(2);];

%tolerance 
tol_x = 0.05 * cuboid_x(1); 
tol_y = 0.05 * cuboid_y(1); 
tol_z = 0.05 * cuboid_z(1); 

points_list = zeros(3, 6);
distance_list = zeros(1, 6); %distance to cuboid edge

for i=1:6 %six cuboid sides/planes
    normal = normals(:, rem(i-1, 3) + 1);
    vertix = vertices(:, ceil(i/3));
    
    [point, plane_status] = plane_line_intersect(normal,vertix,P0,P1); %check intersection with side/plane
    
    if (plane_status~=0) %intersection exists
        
        if( (point(1) >= (cuboid_x(1)-tol_x)) && (point(1) <= (cuboid_x(2)+tol_x)) && ...
                    (point(2) >= (cuboid_y(1)-tol_y)) && (point(2) <= (cuboid_y(2)+tol_y)) && ...
                        (point(3) >= (cuboid_z(1)-tol_z)) && (point(3) <= (cuboid_z(2)+tol_z)) ) %point in cuboid
                    
                    intersection_point = point;
                    status = 1;
                    break;
        else
            distance_2 = 0;
            if (point(1) <= (cuboid_x(1)-tol_x))
                distance_2 = distance_2 + (point(1) - cuboid_x(1))^2;
            elseif (point(1) >= (cuboid_x(2)+tol_x))
                distance_2 = distance_2 + (point(1) - cuboid_x(2))^2;
            end

            if (point(2) <= (cuboid_y(1)-tol_y))
                distance_2 = distance_2 + (point(2) - cuboid_y(1))^2;
            elseif (point(2) >= (cuboid_y(2)+tol_y))
                distance_2 = distance_2 + (point(2) - cuboid_y(2))^2;
            end

            if (point(3) <= (cuboid_z(1)-tol_z))
                distance_2 = distance_2 + (point(3) - cuboid_z(1))^2;
            elseif (point(3) >= (cuboid_z(2)+tol_z))
                distance_2 = distance_2 + (point(3) - cuboid_z(2))^2;
            end

            distance_list(i) = sqrt(distance_2); %distance to closest point on cuboid
            points_list(:, i) = point;
        end
    end
    
end

if (status == 0) %ray does not intersect cuboid
    closest_point_idx = find(distance_list == min(distance_list));
    intersection_point = points_list(:, closest_point_idx(1));
    
    if (intersection_point(1) <= (cuboid_x(1)-tol_x))
        intersection_point(1) = cuboid_x(1);
    elseif (intersection_point(1) >= (cuboid_x(2)+tol_x))
        intersection_point(1) = cuboid_x(2);
    end

    if (intersection_point(2) <= (cuboid_y(1)-tol_y))
        intersection_point(2) = cuboid_y(1);
    elseif (intersection_point(2) >= (cuboid_y(2)+tol_y))
        intersection_point(2) = cuboid_y(2);
    end

    if (intersection_point(3) <= (cuboid_z(1)-tol_z))
        intersection_point(3) = cuboid_z(1);
    elseif (intersection_point(3) >= (cuboid_z(2)+tol_z))
        intersection_point(3) = cuboid_z(2);
    end
    
    status = 2;    
end
                    
end

