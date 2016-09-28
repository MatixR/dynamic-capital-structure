function S0 = equity_price_at_zero()
%
%	Reference: Proposition 7, Appendix (B38), (B39)
%

	global iota
	global X_U coupons capital

	
	% Equity at time 0
	
	q_U1 = arrow_restructuring_price(1, 1);
	q_U2 = arrow_restructuring_price(1, 2);
	
	A = zeros(2,2);
	s = zeros(2,1);
	
	A(1,1) = 1 - q_U1(1,1) * X_U(1,1);
	A(1,2) = - q_U1(1,2) * X_U(1,2);
	A(2,1) = - q_U2(2,1) * X_U(2,1);
	A(2,2) = 1 - q_U2(2,2) * X_U(2,2);
	
	Div1 = value_of_dividends(1, 1);
	Div2 = value_of_dividends(1, 2);
	
	Div1 = Div1(1);
	Div2 = Div2(2);



	B0 = debt_price_at_zero();
	
	Delta = zeros(2,2);
	
	for i = 1:2
		for j = 1:2
			
			temp1 = (1 - iota(j)) * X_U(i,j) - coupons(i)/coupons(j);
			temp2 = capital(i) * ( X_U(j,j) - 1 );
			
			Delta(i,j) = temp1 * B0(j) - temp2;
			
		end
	end
	
	s(1) = Div1 + q_U1(1,:) * Delta(1,:)';
	s(2) = Div2 + q_U2(2,:) * Delta(2,:)';
	
	S0 = A \ s;
    	
end

