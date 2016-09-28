function B0 = debt_price_at_zero()
%
% Reference: Proposition 6, Appendix (B35),(B36)
%


	global recovery rate_perpetuity
	global coupons capital

	
	% Debts at time 0
	
	q_U1 = arrow_restructuring_price(1, 1);
	q_U2 = arrow_restructuring_price(1, 2);
	q_D1 = arrow_default_price(1, 1);
	q_D2 = arrow_default_price(1, 2);

	A = zeros(2,2);
	b = zeros(2,1);
	
	A(1,1) = 1 - q_U1(1,1);
	A(1,2) = - coupons(1) / coupons(2) * q_U1(1,2);
	A(2,1) = - coupons(2) / coupons(1) * q_U2(2,1);
	A(2,2) = 1 - q_U2(2,2);
	
	for i = 1:2

		if( i == 1 )
			qd_this = q_D1;
			qu_this = q_U1;
		else
			qd_this = q_D2;
			qu_this = q_U2;
		end
		
		recovered = recovery * capital(i);
		
		temp1 = coupons(i) ./ rate_perpetuity;
		temp2 = qd_this(i,:) * (recovered - temp1);
		temp3 = qu_this(i,:) * temp1;
		
		b(i) = temp1(i) + temp2 - temp3;
		
	end
	
	B0 = A \ b;
	
end

