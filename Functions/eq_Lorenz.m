function dxdt = eq_Lorenz(~,x,flag)
% flag = [sigma rho beta];
sigma = flag(1);
rho = flag(2);
beta = flag(3);

dxdt = zeros(3,1);
dxdt(1) = sigma * ( x(2) - x(1) );
dxdt(2) = x(1) * (rho - x(3)) - x(2);
dxdt(3) = x(1) * x(2) - beta * x(3);
%{
dxdt = [...
    sigma * ( x(2) - x(1) );...
    x(1) * (rho - x(3)) - x(2);...
    x(1) * x(2) - beta * x(3)];
%}
end

