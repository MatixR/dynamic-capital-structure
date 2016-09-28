function load_parameters()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BKS 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gamma psi lambda fmin_option
global con_gr sigma_c rho f p beta tax recovery iota
global theta sigma_x_s sigma_x_id
global r_bar omega lambda_hat p_hat riskfree rate_perpetuity

gamma = 10;
psi = 1.5;

con_gr = [0.0141; 0.0420];
sigma_c = [0.0114; 0.0094];
rho = 0.1998;
f = [0.3555; 0.6445];
p = 0.7646;
beta = 0.01;
% tax = 0.15;
tax = 0.35;
recovery = 1 - [0.30  0.10]';
% covenant = .7;
iota = [0.03  0.01]';

lambda = [1, 1; f(1), f(1)-1] \ [p; 0];


% firms productivity (earnings) growth rate parameter
theta = [-0.0401   0.0782]';
sigma_x_s = [0.1334   0.0834]';
sigma_x_id = 0.2258;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% My extension to include an investment opportunity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global alpha m kappa

alpha = .627;
m = 0;
kappa = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Derived from the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r_bar = beta + 1/psi * con_gr ...
	- 1/2 * gamma * (1 + 1/psi) * sigma_c.^2;

fmin_option = optimset('TolFun',1e-5);

[ln_omega, fval] = fminsearch(@omega_finder, 1, fmin_option);

omega = exp(ln_omega);
omega = [1/omega ; omega];

lambda_hat = lambda .* omega;


% eq (B15)
temp1 = (gamma - 1) / (gamma - 1/psi);
temp2 = (omega.^temp1 - 1) / (1 - gamma);

riskfree = r_bar ...
    - (gamma - 1/psi) * lambda .* temp2 ...
    + lambda .* (1 - omega);


p_hat = sum(lambda_hat);



% eq (18)
temp1 = riskfree(end:-1:1) - riskfree;
temp2 = p_hat + riskfree(end:-1:1);

rate_perpetuity = riskfree + temp1 ./ temp2 .* lambda_hat;



end


function obj = omega_finder(ln_omega)

	omega = exp(ln_omega);
	
	obj = eq_B5(omega)^2;
	
end
