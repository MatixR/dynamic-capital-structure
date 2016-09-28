function B = debt_price(X, state0)
%
%	Reference: Proposition 6, Appendix (B34)
%

	global recovery rate_perpetuity
	global X_D coupons B0 capital

	
	% Debts at time t
	q_U = arrow_restructuring_price(X, state0);
	q_D = arrow_default_price(X, state0);
	
% 	B0 = debt_price_at_zero();

	value_at_default = zeros(2,1);
	value_at_refinancing = zeros(2,1);
	
	for i = 1:2		% for nu_D and nu_U
		
		value_at_default(i) = recovery(i) * capital(state0) - coupons(state0) / rate_perpetuity(i);
		
		value_at_refinancing(i) = coupons(state0)/coupons(i) * B0(i) - coupons(state0) / rate_perpetuity(i);
		
	end
	
	temp1 = coupons(state0) ./ rate_perpetuity;
	temp2 = q_D * value_at_default;
	temp3 = q_U * value_at_refinancing;
	
	B = temp1 + temp2 + temp3;
	

% 	if X <= X_D(state0,2)
% 		B = zeros(2,1);
% 	elseif X <= X_D(state0,1)
% 		B(1) = 0;
% 	end

end

