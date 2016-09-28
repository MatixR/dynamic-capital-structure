function rp = equity_risk_premium(X, state0)

	global gamma rho sigma_c omega lambda sigma_x_s

	S = equity_price(X, state0);
	
	partial_S = partial_S_partial_X(X, state0);
	
	rp_brown = gamma * rho * partial_S * X ./ S .* sigma_x_s .* sigma_c;
	
	temp = S(end:-1:1) ./ S;
	
	rp_jump = (1 - omega) .* (temp - 1) .* lambda;
	
	rp = rp_brown + rp_jump;
	

end