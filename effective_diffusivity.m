function Deff = effective_diffusivity(D,R,configuration)
% Computes the effective diffusivity for an heterogeneous disc/annulus for either
% the outward or inward configuration. Assumes the starting position is at
% the absorbing boundary (r = R0 = R(1) and r = Rm = R(m+1) for outward and inward
% configuration, respectively).

m = length(R)-1;
den = 0;
Rf = @(j) R(j+1);

if strcmp(configuration,'outward')
    for j = 1:m
        den = den + (Rf(j)^2 - Rf(j-1)^2)/(4*D(j)) + Rf(0)^2/(2*D(j)) * log(Rf(j-1)/Rf(j));
    end
    Deff = ((Rf(m)^2-Rf(0)^2)/4 + (Rf(0)^2)/2 * log(Rf(0)/Rf(m)))/den;
elseif strcmp(configuration,'inward')
    for j = 1:m
        den = den + (Rf(j)^2 - Rf(j-1)^2)/(4*D(j)) + Rf(m)^2/(2*D(j)) * log(Rf(j-1)/Rf(j));
    end
    Deff = ((Rf(m)^2-Rf(0)^2)/4 + (Rf(m)^2)/2 * log(Rf(0)/Rf(m)))/den;
end



