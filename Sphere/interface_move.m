function new_pos = interface_move(P,R,current_pos,delta,partition_mesh,layer_num,N_part)
% FUNCTION new_pos = interface_move(P,R,current_pos,delta,
% partition_mesh,N_part) handles movements near layer interfaces.

rand_n = rand;
prob_sum = 0;
new_pos = current_pos;
for k = 1:N_part
    % Determine the position of the potential half step to be taken
    pos = reposition(current_pos,[delta/2; partition_mesh(:,k)]');
    Pk = Pfunc(P,R,layer_num,pos(1)); % evalute probability at potential step
    if rand_n < prob_sum + Pk/N_part % add this probability to the probability total and check
        new_pos = reposition(current_pos,[delta; partition_mesh(:,k)]'); % calculate new position
        break
    else
        prob_sum = prob_sum + Pk/N_part; % update total
    end
end