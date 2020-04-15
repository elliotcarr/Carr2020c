function [moment,M] = moments(R,D,configuration,dim,start_pos,moment_choice)
% Computes the closed-form expressions for the moments of the exit time
% distribution for the heterogeneous disc.
% OUTPUTS:
% moment - moment evaluated at each element in start_pos
% INPUTS:
% R - vector of radius distance for each layer interface including
%   both boundary layers
% D - vector of diffusivities in each layer
% configuration - string 'outward' or 'inward' indicating if the exit is
%   located on the outer-most boundary (outward) or inner-most boundary
%   (inward).
% dim - dimension (1 = cartesian, 2 = polar, 3 = spherical)
% start_pos - vector starting radii
% moment_choice - which moment to calculate

% Initialise variables
layer_num = length(R)-1;
syms y
a = sym('a',[layer_num 1]);
b = sym('b',[layer_num 1]);
M = sym(ones(moment_choice+1,layer_num));
eq = sym('eq', [2*layer_num,1]);
moment = zeros(length(start_pos),1);
% Loop through each moment
for k = 1:moment_choice
    % Solve ode in each layer
    for ii = 1:layer_num
        M(k+1,ii) = -( k/D(ii) ).*int((1/y^(dim-1))*int(y^(dim-1)*M(k,ii),y),y)...
            - a(ii)*int(1/y^(dim-1),y) + b(ii);
    end
    % create equations for internal BCs
    for ii = 1:layer_num - 1
        eq(2*ii) = subs(M(k+1,ii),y,R(ii+1)) == subs(M(k+1,ii+1),y,R(ii+1));
        eq(2*ii+1) = subs( D(ii)*diff(M(k+1,ii),y), y, R(ii+1) ) == ...
            subs( D(ii+1)*diff(M(k+1,ii+1),y), y, R(ii+1) );
    end
    % Create equation for outer boundary
    if strcmp(configuration,'outward')
        eq(1) = subs( M(k+1,layer_num),y,R(layer_num+1) ) == 0;
    else
        eq(1) = subs( diff(M(k+1,layer_num),y),y,R(layer_num+1) ) == 0;
    end
    % Create equation for inner boundary
    if R(1) == 0
        eq(2*layer_num) = a(1) == 0;
    elseif strcmp(configuration,'outward')
        eq(2*layer_num) = subs( diff(M(k+1,1),y),y,R(1) ) == 0;
    else
        eq(2*layer_num) = subs( M(k+1,1),y,R(1) ) == 0;
    end
    % solve for numerical constants and convert
    c = solve(eq,[a;b]);
    c = struct2cell(c);
    s = sym('s',[2*layer_num,1]);
    for ii = 1:2*layer_num
        s(ii) = sym(c{ii});
    end
    % sub in solved constants
    for ii = 1:layer_num
        M(k+1,ii) = subs(M(k+1,ii),[a(ii) b(ii)],[s(ii),s(ii+layer_num)]);
    end
    % reset constants for next loop iteration
    a = sym('a',[layer_num 1]);
    b = sym('b',[layer_num 1]);
    eq = sym('eq', [2*layer_num,1]);
end
% Loop through all starting radii in start_pos
for j = 1:length(start_pos)
    start_layer = 1;
    if abs(start_pos(j) - R(1)) > 1e-6
        while start_pos(j) > R(start_layer+1) % Find layer agent is in
            start_layer = start_layer + 1;
        end
    end
    moment(j) = subs(M(moment_choice+1,start_layer),y,start_pos(j));
end
end