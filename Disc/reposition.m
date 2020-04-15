function new_pos = reposition(current_pos, step)
% Calculates the new position of an agent given its current location and 
% next location (in polar coordinates).
% new_pos - the new coordinate of the agent as r, theta
% current_pos - the current position of the agent as r, theta
%   coordinates
% step - the polar coordinates of the agent step

% convert polar coordiantes to cartesian coordinates
x1 = current_pos(1)*cos(current_pos(2)); y1 = current_pos(1)*sin(current_pos(2));
x2 = step(1)*cos(step(2)); y2 = step(1)*sin(step(2));

% calculate destination and convert back to spherical coordinates
dest_xy = [x1+x2, y1+y2];
[new_THE,new_r] = cart2pol(dest_xy(1),dest_xy(2));
new_pos = [new_r, new_THE]; 

end