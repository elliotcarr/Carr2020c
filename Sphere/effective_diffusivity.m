function Deff = effective_diffusivity(D,R,configuration)
% Computes the effective diffusivity for an heterogeneous sphere/spherical shell for either
% the outward or inward configuration. Assumes the starting position is at the absorbing 
% boundary (r = R0 = R(1) and r = Rm = R(m+1) for outward and inward configuration, 
% respectively).

m = length(R)-1;
den = 0;
Rf = @(j) R(j+1);

if strcmp(configuration,'outward')
    for j = 1:m
        den = den + (Rf(j)^2 - Rf(j-1)^2)/(6*D(j)) + Rf(0)^3/(3*D(j)) * (1/Rf(j)-1/Rf(j-1));
    end
    Deff = ((Rf(m)^2-Rf(0)^2)/6 + (Rf(0)^3)/3 * (1/Rf(m)-1/Rf(0)))/den;
elseif strcmp(configuration,'inward')
    for j = 1:m
        den = den + (Rf(j)^2 - Rf(j-1)^2)/(6*D(j)) + Rf(m)^3/(3*D(j)) * (1/Rf(j)-1/Rf(j-1));
    end
    Deff = ((Rf(m)^2-Rf(0)^2)/6 + (Rf(m)^3)/3 * (1/Rf(m)-1/Rf(0)))/den;
end



