function flag = is_near_interf(R,current_r,curr_layer,delta)
% Checks if the agent is near a layer interface and outputs a flag
% indicating if its near 
% - an internal interface (flag=1)
% - the inner-most interface if not equal to 0 (flag=2)
% - the outer-most interface (flag=3)
% - not near any interface (flag=0).
% Near the interface is defined as being within one delta away from a value
% in the vector R.

if abs(current_r - R(curr_layer)) < delta
    
    if curr_layer == 1 % if layer is the inside one
        if R(1) == 0 
            flag = 0; % if sphere is not hollow (so no interface)
        else
            flag = 2; % if sphere is hollow
        end
    else
        flag = 1; % if at some internal interface not on either boundary
    end
    
elseif abs(current_r - R(curr_layer+1)) < delta
    
    if curr_layer == length(R)-1 
        flag = 3; % if layer is the outer-most one
    else
        flag = 1; % if at some internal interface not on either boundary
    end
    
else
    flag = 0; % Not at an interface
end

end