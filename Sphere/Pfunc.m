function Pr = Pfunc(Probs,R,layer_num,r)
% Calculate the layer probability Pr of an agent at radius r.
% When on an interface between layers, the outer-most layer is chosen 
% INPUTS:
% Probs - the vector of probabilities of moving within each layer
% R - vector of locations of layer interfaces including inner and outer
%   boundaries.
% layer_num - The number of layers
% r - the location to evaluate the probabiity at.

Pr = Probs(1)*( r < R(1) );
for k = 1:layer_num
    Pr = Pr + Probs(k)*(r >= R(k))*(r < R(k+1)); 
end
Pr = Pr + Probs(layer_num)*( r >= R(layer_num+1) );