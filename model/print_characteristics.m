function print_characteristics()

	global iota tax alpha m f recovery kappa
	global X_D X_U capital coupons
	global B0 S0
	
	inv_cost = investment_cost();
	
	% value of equity after refinancing: E, 2x2 matrix by nu_0 and nu_U
	equity_refinanced = zeros(2,2);
	
	for i = 1:2  % nu_0
		for j = 1:2  % nu_U
			equity_refinanced(i,j) = ...
				B0(j) * ((1 - iota(j)) * X_U(i,j) - coupons(i)/coupons(j)) ...
				- capital(i) * inv_cost(j) ...
				+ X_U(i,j) * S0(j);
		end
	end

	% debt issuance: 2x2 matrix by nu_0 and nu_U
	debt_issue_gross = zeros(2,2);
	
	for i = 1:2  % nu_0
		for j = 1:2  % nu_U
			debt_issue_gross(i,j) = B0(j) * (X_U(i,j) - coupons(i)/coupons(j));
		end
	end
	
	lagged_mkt_asset = [B0 B0] + equity_refinanced;
	
	debt_issue = debt_issue_gross ./ lagged_mkt_asset;
	debt_issue
	f' * debt_issue * f
	
	
% 	% investment per debt issuance (ipdi)
% 	ipdi = zeros(2,2);
% 	
% 	for i = 1:2
% 		for j = 1:2
% 			ipdi(i,j) = (capital(i) * X_U(i,j) - capital(i)) / debt_issue_gross(i,j);
% 		end
% 	end
% 	
% 	ipdi
% 	f' * ipdi * f
	

	% market leverage
	mkt_leverage = B0 ./ (B0 + S0);
	mkt_leverage
	mkt_leverage' * f
	
	
	% Q
	Q = (B0 + S0) ./ capital;
	Q
	Q' * f
	

	% profitability
	net_income = zeros(2,2);
	
	for i = 1:2
		for j = 1:2
            
            % why X_U here?????
            earnings = X_U(i,j)^(1-alpha) * capital(i)^(alpha) - m * capital(i);
			net_income(i,j) = earnings - coupons(i);
            
		end
	end
	
	profitability = (1 - tax) * net_income ./ lagged_mkt_asset;
	profitability
	f' * profitability * f
	
	
	% effective recovery rate
% 	eff_recov = zeros(2,2);
% 	
% 	for i = 1:2
% 		for j = 1:2
% 			unlev = unlevered_assets(X_D(i,j), i);
% 			eff_recov(i,j) = recovery(j) * unlev(j) / B0(i);
% 		end
% 	end
% 	
% 	eff_recov
% 	f' * eff_recov * f
	
	
	
end

