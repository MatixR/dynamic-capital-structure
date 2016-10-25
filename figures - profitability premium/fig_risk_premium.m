%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fig_risk_premium
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
clear global;
clear gcf;

dbstop if error;
dbstop if warning;

addpath ../extension

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global f rate_perpetuity alpha
global X_D X_U capital coupons

scenarios = [3 1 14 23 28];
no_scenarios = length(scenarios);

x_domain		 = (0:.01:2)';
x_domain_len = length(x_domain);

outputs_equity = nan(x_domain_len, no_scenarios);
outputs_credit = nan(x_domain_len, no_scenarios);
outputs_Q		= nan(x_domain_len, no_scenarios);
outputs_profit = nan(x_domain_len, no_scenarios);

for i = 1:no_scenarios
	
	load_scenario( scenarios(i) );
	
	for x_id = (1:x_domain_len)
		
		X = x_domain(x_id);

		if (X <= max(X_D(:))) || (X > min(X_U(:)))
			continue;
		end
		
		% nu_0 x nu_t
		equity_rp = zeros(2,2);
		credit_sp = zeros(2,2);
		Q			 = zeros(2,2);
		profit    = zeros(2,2);
		
		for state0 = 1:2
			
			B = debt_price(X, state0);
			S = equity_price(X, state0);
			
			credit_sp(state0,:) = (coupons(state0) ./ B - rate_perpetuity)';
			equity_rp(state0,:) = equity_risk_premium(X, state0)';
			
			Q(state0,:) = ((B + S) ./ capital(state0))';
			
			profit(state0,:) = (X.^(1-alpha) .* capital(state0).^alpha) ./ capital(state0);
			
		end
		
		outputs_equity(x_id,i) = f' * equity_rp * f;
		outputs_credit(x_id,i) = f' * credit_sp * f;
		outputs_Q(x_id,i)		  = f' * Q * f;
		outputs_profit(x_id,i) = f' * profit * f;
		
	end
	
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot: risk premiums w.r.t. Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q_domain = (0.7:0.01:6.2)';

equity_Q = nan( length(Q_domain), no_scenarios );
credit_Q = nan( length(Q_domain), no_scenarios );

for i = 1:no_scenarios
	
	idx = ~isnan( outputs_Q(:,i) );
	
	f = fit( outputs_Q(idx,i), outputs_equity(idx,i), 'linearinterp' );

	equity_Q(:,i) = f(Q_domain);

	f = fit( outputs_Q(idx,i), outputs_credit(idx,i), 'linearinterp' );

	credit_Q(:,i) = f(Q_domain);
	
	
	idx = ( Q_domain > max(outputs_Q(:,i)) );
	
	equity_Q(idx,i) = nan;
	credit_Q(idx,i) = nan;

end


% subplot(2,2,1), plot(x_domain, outputs_equity);
% subplot(2,2,2), plot(x_domain, outputs_credit);
% subplot(2,2,3), plot(Q_domain, equity_Q);
% subplot(2,2,4), plot(Q_domain, credit_Q);

% dlmwrite('fig_risk_premium_equity_X.csv', [x_domain outputs_equity], 'delimiter', '\t');
% dlmwrite('fig_risk_premium_credit_X.csv', [x_domain outputs_credit], 'delimiter', '\t');
dlmwrite('fig_risk_premium_equity_Q.csv', [Q_domain equity_Q], 'delimiter', '\t');
dlmwrite('fig_risk_premium_credit_Q.csv', [Q_domain credit_Q], 'delimiter', '\t');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot: stock risk premium w.r.t. profitability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
profit_domain = (0:0.01:0.45)';

equity_profit = nan( length(profit_domain), no_scenarios );

for i = 1:no_scenarios
	
	idx = ~isnan( outputs_profit(:,i) );
	
	f = fit( outputs_profit(idx,i), outputs_equity(idx,i), 'linearinterp' );

	equity_profit(:,i) = f(profit_domain);

	idx1 = ( profit_domain > max(outputs_profit(:,i)) );
	idx2 = ( profit_domain < min(outputs_profit(:,i)) );
	
	equity_profit(idx1,i) = nan;
	equity_profit(idx2,i) = nan;

end


subplot(2,1,1), plot(x_domain, outputs_profit);
subplot(2,1,2), plot(profit_domain, equity_profit);

dlmwrite('fig_risk_premium_profit_X.csv', [x_domain outputs_profit], 'delimiter', '\t');
dlmwrite('fig_risk_premium_equity_profit.csv', [profit_domain equity_profit], 'delimiter', '\t');
