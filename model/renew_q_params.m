function renew_q_params()

	global riskfree gamma alpha rho sigma_x_s sigma_c theta lambda_hat p_hat
	global X_U X_D capital coupons
	global rate_asset qd_params qu_params B0 S0


	% -- Original BKS(2010)
	% % eq (14)
	% mu_bar = riskfree + gamma * rho * sigma_x_s .* sigma_c;
	% 
	% % eq (13)
	% temp1 = mu_bar - theta;
	% temp2 = temp1(end:-1:1);
	% temp3 = (temp2 - temp1) ./ (p_hat + temp2);
	%     
	% rate_asset = mu_bar - theta + temp3 .* lambda_hat;

	% -- my own extension
	mu_bar = riskfree + gamma * rho * (1-alpha) * sigma_x_s .* sigma_c;

	temp1 = mu_bar - (1 - alpha) * theta;
	temp2 = temp1(end:-1:1);
	temp3 = (temp2 - temp1) ./ (p_hat + temp2);

	rate_asset = temp1 + temp3 .* lambda_hat;
	
	
	
	% Homogeneity condition: Eq (40)
	X_U(2,:) = X_U(1,:) * coupons(2)/coupons(1);
	X_D(2,:) = X_D(1,:) * coupons(2)/coupons(1);
	
	capital(2) = capital(1) * coupons(2)/coupons(1);
	
	
	% Update q_D and q_U's parameters
	qd_params    = arrow_default_params(1);
	qd_params(2) = arrow_default_params(2);
	qu_params    = arrow_restructuring_params(1);
	qu_params(2) = arrow_restructuring_params(2);
	
	
	% Compute the value of debt at time 0
	B0 = debt_price_at_zero();
	
	% Compute the value of equity at time 0
	S0 = equity_price_at_zero();


%     % Confirm eqn (16) : S = Div + Sigma q_U E
%     E = equity_before_restructure();
%     
%     temp = zeros(2,1);
%     temp(1) = Div1(1) + q_U1(1,:) * E(1,:)';
%     temp(2) = Div2(2) + q_U2(2,:) * E(2,:)';
%     
%     S0 - temp
%     assert( sum(abs(S0 - temp)) < 1e-6 );

end
