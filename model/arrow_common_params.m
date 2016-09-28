function params = arrow_common_params()

	global gamma theta sigma_c sigma_x_s sigma_x_id rho lambda_hat riskfree

	sigma_x = sqrt( sigma_x_s.^2 + sigma_x_id.^2 );

	theta_hat = theta - gamma * rho * sigma_x_s .* sigma_c;
	
	params.sigma_x = sigma_x;
	params.theta_hat = theta_hat;


	% k from eq (S-15)
	temp1 = 1/2 * sigma_x.^2;
	temp2 = theta_hat - temp1;
	temp3 = - (lambda_hat + riskfree);

	poly1 = [temp1(1) temp2(1) temp3(1)];
	poly2 = [temp1(2) temp2(2) temp3(2)];

	poly = conv(poly1, poly2);

	poly(end) = poly(end) - prod(lambda_hat);

	k = sort(roots(poly));

	params.k = k;


	% eps from eq (S-16)
	temp1 = [ (k.^2)'; k'; ones(1,4) ];
	temp2 = poly1 * temp1;

	eps = - temp2' / lambda_hat(1);

	params.eps = eps;


	% j from eq (S-17)
	j = sort(roots(poly2));

	params.j = j;
	
	
	% l from section (S-III)
	l = sort(roots(poly1));

	params.l = l;
	

end




