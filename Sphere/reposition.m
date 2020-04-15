function new_pos = reposition(current_pos, step)
% Calculates the new position of an agent given its current location and 
% next location (in spherical coordinates).
% new_pos - the new coordinate of the agent as r, theta, phi
% current_pos - the current position of the agent as r, theta, phi
%   coordinates
% step - the spherical coordiantes of the agent step

% convert spherical coordiantes to cartesian coordinates
[x1,y1,z1] = sph2cart(current_pos(2),current_pos(3),current_pos(1));
[x2,y2,z2] = sph2cart(step(2),step(3),step(1));

% calculate destination and convert back to spherical coordinates
dest_xyz = [x1+x2, y1+y2, z1+z2];
[new_THE,new_PHI,new_r] = cart2sph(dest_xyz(1),dest_xyz(2),dest_xyz(3));
new_pos = [new_r, new_THE, new_PHI]; 

end