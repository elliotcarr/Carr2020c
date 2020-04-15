function exit_time = circle_rand_walk_func(P,R,delta,tau,partitions,...
    configuration,start_radius,start_theta,sim_num)
% FUNCTION exit_time = circle_rand_walk_func(P,R,delta,tau,partition_mesh,...
%    configuration,start_radius,start_theta,start_phi,sim_num) simulates a
%    random walk on a layered circle using a lattice-free method.
% OUTPUTS
% exit_time - sim_num x 1 vector of the exit time for each realistation
% INPUTS
% P - Vector of probabilities of moving within each layer
% R - Vector containing the radius of each interface including the
%   final boundary
% delta - step size of agent
% tau  - time step
% partitions - Number of uniform divisions for the angle 0 < theta < 2*pi
% configuration - a string 'outward' or 'inward' indicating if the exit is
%   located on the outer-most boundary (outward) or inner-most boundary
%   (inward).
% start_radius - Starting radius of the agent measured from the origin
% start_theta - Starting angle for the agent (interval 0
%   to 2*pi)
% sim_num - Number of identically prepared simulations to run

% Begin initialisation
layer_num = length(P);
exit_time = zeros(sim_num,1);
angle_step = 2*pi/partitions;

% Determine exit location
switch configuration
    case 'outward'
        exit_idx = layer_num + 1;
        start_idx = 1;
    case 'inward'
        exit_idx = 1;
        start_idx = layer_num + 1;
end

% Prepare realisations
for sim_count = 1:sim_num
    
    current_pos = [start_radius, start_theta]; % current position in order of r, theta
    time = 0;
    % Check exit condition
    if exit_idx == layer_num+1
        if current_pos(1) >= R(exit_idx)
            agent_exit = true;
        else
            agent_exit = false;
        end
    else
        if current_pos(1) <= R(exit_idx)
            agent_exit = true;
        else
            agent_exit = false;
        end
    end
    
    % Begin simulatation
    while agent_exit == false
        % Find the current layer
        curr_layer = 1;
        if abs(current_pos(1) - R(1)) > 1e-6
            while current_pos(1) > R(curr_layer+1) % Find layer agent is in
                curr_layer = curr_layer + 1;
            end
        end
        
        % Check if near interface
        near_interface = is_near_interf(R,current_pos(1),curr_layer,delta);
        
        if near_interface == 2 % Near inner boundary (if it exists)
            %current_pos_temp = interface_move(P,R,current_pos,delta,partitions,angle_step,layer_num);
            if rand < P(curr_layer)
                current_pos_temp = reposition(current_pos,[delta, 2*pi*rand]);                
                if start_idx == 1 && current_pos_temp(1) < R(1) % outward
                    %current_pos(1) = R(1); % treatment of reflecting boundary
                    continue; %abort step
                else
                    current_pos = current_pos_temp;
                end
            end
            
        elseif near_interface == 3 % Near outer boundary
            
            %current_pos_temp = interface_move(P,R,current_pos,delta,partitions,angle_step,layer_num);
            if rand < P(curr_layer)
                current_pos_temp = reposition(current_pos,[delta, 2*pi*rand]);
                if start_idx == layer_num+1 && current_pos_temp(1) > R(layer_num+1) % inward
                    %current_pos(1) = R(layer_num+1); % treatment of reflecting boundary
                    continue; %abort step
                else
                    current_pos = current_pos_temp;
                end
            end
            
        elseif near_interface == 1 % near internal boundary
            
            current_pos = interface_move(P,R,current_pos,delta,partitions,angle_step,layer_num);
            
        else % not near interface
            
            if rand < P(curr_layer)
                current_pos = reposition(current_pos,[delta, 2*pi*rand]);
            end
            
        end
        
        time = time + tau; % Increase timestep
        
        % Check exit condition
        if exit_idx == layer_num+1
            if current_pos(1) >= R(exit_idx)
                agent_exit = true;
            else
                agent_exit = false;
            end
        else
            if current_pos(1) <= R(exit_idx)
                agent_exit = true;
            else
                agent_exit = false;
            end
        end
    end
    exit_time(sim_count) = time;
end

end
