function new_pos = interface_move(P,R,current_pos,delta,partitions,angle_step,layer_num)
% FUNCTION new_pos = interface_move(P,R,current_pos,delta,
% partitions,N_part) handles movements near layer interfaces.

rand_n = rand;
prob_sum = 0;
new_pos = current_pos;
for k = 1:partitions
    
    % Determine the position of the potential half step to be taken
    pos = reposition(current_pos, [delta/2, angle_step*(k-1)] );
    Pk = Pfunc(P,R,layer_num,pos(1)); % evalute probability at potential step
    if rand_n < prob_sum + Pk/partitions % add this probability to the probability total and check
        new_pos = reposition(current_pos, [delta angle_step*(k-1)] ); % calculate new position
        break
    else
        prob_sum = prob_sum + Pk/partitions; % update total
    end

end