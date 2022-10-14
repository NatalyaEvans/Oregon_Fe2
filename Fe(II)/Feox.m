function dFe2dt = Feox(t,Fe2)

%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

global kprime

dFe2dt=0;

dFe2dt=kprime.*Fe2; % rate

end

