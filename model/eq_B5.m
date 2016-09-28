function result = eq_B5(x)

global gamma psi r_bar con_gr sigma_c lambda

assert(psi ~= 1);
assert(x > 0);

temp1 = (1 - 1/psi) / (gamma - 1/psi);
temp2 = (1 - 1/psi) / (gamma - 1);
temp3 = (gamma - 1) / (gamma - 1/psi);
temp4 = [x^(-temp3) - 1 ; x^(temp3) - 1];

term1 = x^(-temp1);
term2 = r_bar + gamma * sigma_c.^2 - con_gr ...
	+ lambda * temp2 .* temp4;

result = term1 - term2(2) / term2(1);



