%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% table_asset_return_moments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table_asset_return_moments(inst_id)

addpath ../extension

if nargin == 0
	inst_id = 1;
end

% rng('shuffle');
rng(inst_id);


no_simulations = 100;

years_to_simulate = 100;
years_to_drop     = 10;

T = years_to_simulate * 12;
N = 100;

senario_ids = [1 3 14 23 (28:32)];
no_scenarios = length(senario_ids);


% The table to store simulated moments
% : riskfree rate, stock market return, value premium,
%   market credit spreads, value credit premium
simulated_moments = zeros(no_simulations, 10);



global alpha m riskfree rate_perpetuity

load_parameters();

for sim_id = 1:no_simulations
	
	fprintf(1, '**************************************\n');
	fprintf(1, '** Simulation ID : %d\n', sim_id);
	fprintf(1, '**************************************\n\n');

	
	economy = generate_economy(T, 2);

	panel_Q					= zeros(T, no_scenarios * N);
	panel_ebitda			= zeros(T, no_scenarios * N);
	panel_capital			= zeros(T, no_scenarios * N);
	panel_stock_returns	= zeros(T, no_scenarios * N);
	panel_credit_spreads = zeros(T, no_scenarios * N);

	for i = 1:no_scenarios

		% simulate sample firms
		scenario_id = senario_ids(i);

		load_scenario(scenario_id);

		fprintf(1, '** Scenario ID: %d, alpha: %.3f, m: %.2f\n', scenario_id, alpha, m);

		simulated = generate_firms(N, economy);

		fprintf(1, '\n\n');
		
		
		Q = (simulated.debts_market + simulated.stocks) ./ simulated.capital_hist;

		
		% negative dividends are replaced by zero
		idx_negative_dividends = (simulated.dividends < 0 );
		simulated.dividends(idx_negative_dividends) = 0;
		
		stock_returns = zeros(T, N);
		stock_returns(2:end,:) = (simulated.stocks(2:end,:) + simulated.dividends(2:end,:)) ./ simulated.stocks(1:end-1,:) - 1;
		stock_returns(simulated.ind_default) = nan;
		
		rate_perpetuity_history = rate_perpetuity(economy.states);
		
		credit_spreads = simulated.coupons_hist ./ simulated.debts_market - kron(rate_perpetuity_history, ones(1,N));

		idx1 = (i - 1) * N + 1;
		idx2 = i * N;
		
		panel_Q				  (:,idx1:idx2) = Q;
		panel_ebitda		  (:,idx1:idx2) = simulated.ebitda;
		panel_capital		  (:,idx1:idx2) = simulated.capital_hist;
		panel_stock_returns (:,idx1:idx2) = stock_returns;
		panel_credit_spreads(:,idx1:idx2) = credit_spreads;

	end
	
	
	% filter stock returns
	p1  = prctile( panel_stock_returns(:),  0.5 );
	p99 = prctile( panel_stock_returns(:), 99.5 );
	
	idx_outliers = ((panel_stock_returns < p1) | (panel_stock_returns > p99));
	panel_stock_returns(idx_outliers) = nan;

	
	% index to drop the burn-in periods
	idx_from = years_to_drop * 12 + 1;
	
	% moments : riskfree rates
	riskfree_history = riskfree(economy.states) / 12;
	riskfree_history = riskfree_history(idx_from:end);
	
	simulated_moments(sim_id, 1) = mean(riskfree_history);
	simulated_moments(sim_id, 2) = std(riskfree_history);
	
	% stock market excess returns
	stock_market_exrets = nanmean(panel_stock_returns, 2);
	stock_market_exrets = stock_market_exrets(idx_from:end);
	stock_market_exrets = stock_market_exrets - riskfree_history;
	
	simulated_moments(sim_id, 3) = mean(stock_market_exrets);
	simulated_moments(sim_id, 4) = std(stock_market_exrets);
	
	% Q, profitability, and investment portfolio formation
	portfolios{1} = zeros(T, no_scenarios * N);
	portfolios{2} = zeros(T, no_scenarios * N);
	portfolios{3} = zeros(T, no_scenarios * N);
	
	for t = 12:12:(T-12)
		
		idx1 = t + 7;
		idx2 = min(t + 18, T);

		for i = 1:3
			
			if i == 1
				variable = panel_Q(t,:);
			elseif i == 2
				variable = sum(panel_ebitda(t-11:t,:)) ./ panel_capital(t,:);
			elseif i == 3
				if t == 12
					variable = (panel_capital(t,:) - panel_capital(t-11,:)) ./ panel_capital(t-11,:);
				else
					variable = (panel_capital(t,:) - panel_capital(t-12,:)) ./ panel_capital(t-12,:);
				end
			end
			
			p30 = prctile( variable, 30 );
			p70 = prctile( variable, 70 );

			idx_low  = ( variable <= p30 );
			idx_high = ( variable >= p70 );
			
			if (i == 3) && (p70 == 0)
				idx_high = ( variable > 0 );
			end

			portfolios{i}(idx1:idx2, idx_low ) = 1;
			portfolios{i}(idx1:idx2, idx_high) = 2;
		end
				
	end
	
	for t = 2:T
		idx_default = isnan(panel_stock_returns(t,:));
		
		if sum(idx_default) == 0
			continue;
		end
		
		temp = (floor((t-1)/12) + 1)*12 + 6;
		
		for i = 1:3
			portfolios{i}(t:temp,idx_default) = 0;
		end
		
	end
	

	% average credit spreads
	avg_credit_spreads = nanmean(panel_credit_spreads, 2);
	avg_credit_spreads = avg_credit_spreads(idx_from:end);
	
	simulated_moments(sim_id, 5) = mean(avg_credit_spreads);
	simulated_moments(sim_id, 6) = std(avg_credit_spreads);
	
	% value, profitability, and investment premium
	portfolio_returns{1} = zeros(T, 2);
	portfolio_returns{2} = zeros(T, 2);
	portfolio_returns{3} = zeros(T, 2);
	
	for i = 1:3
		for t = 19:T
			idx1 = (portfolios{i}(t,:) == 1);
			idx2 = (portfolios{i}(t,:) == 2);

			portfolio_returns{i}(t,1) = nanmean(panel_stock_returns(t,idx1));
			portfolio_returns{i}(t,2) = nanmean(panel_stock_returns(t,idx2));
		end
		
		portfolio_returns{i} = portfolio_returns{i}(idx_from:end,:);
	end
	
	value_premium = portfolio_returns{1}(:,1) - portfolio_returns{1}(:,2);
	profit_premium = portfolio_returns{2}(:,2) - portfolio_returns{2}(:,1);
	invest_premium = portfolio_returns{3}(:,2) - portfolio_returns{3}(:,1);
	
	simulated_moments(sim_id, 7) = mean(value_premium);
	simulated_moments(sim_id, 8) = std(value_premium);
	
	simulated_moments(sim_id,  9) = mean(profit_premium);
	simulated_moments(sim_id, 10) = std(profit_premium);

	simulated_moments(sim_id, 11) = nanmean(invest_premium);
	simulated_moments(sim_id, 12) = nanstd(invest_premium);

	
	% store the results
	filename = sprintf('simulation_outputs/table_asset_return_moments%04d.csv', inst_id);
	dlmwrite(filename, simulated_moments(1:sim_id,:), 'delimiter', '\t');
	
	fprintf(1, '\n\n\n');
	
end

toc






