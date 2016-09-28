function S = equity_price(X, state0)
%
%	Reference: Proposition 7, Appendix (B37)
%

	global X_D


	Div = value_of_dividends(X, state0);
	
	q_U = arrow_restructuring_price(X, state0);
	
	E = equity_before_restructure();
	
	S = Div + q_U * E(state0,:)';
	
	
	if X <= X_D(state0,2)
		S = zeros(2,1);
	elseif X <= X_D(state0,1)
		S(1) = 0;
	end

end

