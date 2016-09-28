function E = equity_before_restructure()

% E(\nu_0, \nu_U) :
% the value of equity right before restructuring takes place

global alpha iota X_U X_D coupons capital B0 S0


net_debt_issue = zeros(2,2);
inv_adj_cost	= zeros(2,2);
new_equity		= zeros(2,2);


if alpha == 0
	inv_scale = zeros(2,1);
else
	inv_scale = investment_cost();
end


for i = 1:2			% nu_0
	for j = 1:2		% nu_U
		
		 temp = (1 - iota(j)) * X_U(i,j) - coupons(i)/coupons(j);
		 net_debt_issue(i,j) = temp * B0(j);
		 
		 inv_adj_cost(i,j) = capital(i) * inv_scale(j);
		 
		 new_equity(i,j) = X_U(i,j) * S0(j);
		
	end
end

E = net_debt_issue - inv_adj_cost + new_equity;

