%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% market_timing_simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function market_timing_simulation(inst_id)

addpath ../model

if nargin == 0
	inst_id = 1;
end

rng(inst_id);


global alpha m

load_parameters();

years_to_simulate = 60;
years_to_drop     = 20;

T = years_to_simulate * 12;
N = 100;

senario_ids = [1 3 14 23 (28:32)];
no_scenarios = length(senario_ids);


% the tables to store results for every simulation
no_simulations = 100;

reg_results = zeros(no_simulations, 12);


for sim_id = 1:no_simulations
	
	fprintf(1, '**************************************************\n');
	fprintf(1, '** Simulation ID : %d (%s)\n', sim_id, datestr(now()));
	fprintf(1, '**************************************************\n');

	% the tables to store simulated data to run a regression
	reg_no_obs = (years_to_simulate - years_to_drop - 1) * N;
	reg_deps   = zeros(reg_no_obs * no_scenarios, 2);
	reg_indeps = zeros(reg_no_obs * no_scenarios, 3);


	starting_state = mod(sim_id, 2) + 1;
	
	economy = generate_economy(T, starting_state);

	for i = 1:no_scenarios

		% simulate sample firms
		scenario_id = senario_ids(i);

		load_scenario(scenario_id);

		fprintf(1, '** Scenario ID: %d, alpha: %.3f, m: %.2f\n', scenario_id, alpha, m);

		simulated = generate_firms(N, economy);

		fprintf(1, '\n\n');


		% estimate firm characterestics
		firm_size = simulated.stocks + simulated.debts_market;
		Q			 = firm_size ./ simulated.capital_hist;
% 		lev_mkt   = simulated.debts_market ./ firm_size;
		lev_quasi = simulated.debts_book ./ (simulated.debts_book + simulated.stocks);
		lev_book  = simulated.debts_book ./ simulated.capital_hist;
		
		% build efwa-M/B ratio
		external_finance = zeros(T, N);
		external_finance(1,:)		= simulated.capital_hist(1,:);
		external_finance(2:end,:)	= simulated.capital_hist(2:end,:) - simulated.capital_hist(1:end-1,:);
		
		external_finance(simulated.ind_default) = simulated.capital_hist(simulated.ind_default);
		
		efwa_MB = zeros(T, N);
		
		for firm_id = 1:N
			for t = 1:T
				
				start = 1;
				
				if any(simulated.ind_default(1:t,firm_id))
					start = find(simulated.ind_default(1:t,firm_id), 1, 'last');
				end
				
				weights = external_finance(start:t, firm_id);
				weights = weights ./ sum(weights);
				
				assert( sum((weights < 0)) == 0 );
				assert( sum((weights > 1)) == 0 );
				
				efwa_MB(t, firm_id) = weights' * Q(start:t, firm_id);
				
			end
		end
		
		% annualize variables
		lev_quasi_annual = lev_quasi(12:12:T,:);
		lev_book_annual  = lev_book(12:12:T,:);
		
		Q_annual       = Q(12:12:T,:);
		efwa_MB_annual	= efwa_MB(12:12:T,:);
		capital_annual = simulated.capital_hist(12:12:T,:);
		
		% compute profitability
		ind_default_annual = false(years_to_simulate, N);
		profit_annual		 = zeros(years_to_simulate, N);

		for t = 1:years_to_simulate
			
			idx1 = (t-1) * 12 + 1;
			idx2 = t * 12;
			
			ind_default_annual(t,:) = any( simulated.ind_default(idx1:idx2,:), 1);
			profit_annual(t,:) = sum( simulated.netincome(idx1:idx2,:), 1);
			
		end
		
		profit_annual = profit_annual ./ capital_annual;

		% put missing values in default years
		lev_quasi_annual(ind_default_annual) = nan;
		lev_book_annual(ind_default_annual) = nan;
		profit_annual(ind_default_annual) = nan;
		
		
		% drop the first burn-in periods
		lev_quasi_annual = lev_quasi_annual((years_to_drop+2):end   ,:);
		lev_book_annual  = lev_book_annual ((years_to_drop+2):end   ,:);
		
		efwa_MB_annual   = efwa_MB_annual  ((years_to_drop+1):end-1 ,:);
		Q_annual         = Q_annual        ((years_to_drop+1):end-1 ,:);
		profit_annual	  = profit_annual   ((years_to_drop+1):end-1 ,:);


		% add to the regression data tables
		idx1 = (i-1) * reg_no_obs + 1;
		idx2 = i * reg_no_obs;

		reg_deps  (idx1:idx2,1) = lev_quasi_annual(:);
		reg_deps  (idx1:idx2,2) = lev_book_annual(:);
		
		reg_indeps(idx1:idx2,1) = efwa_MB_annual(:);
		reg_indeps(idx1:idx2,2) = Q_annual(:);
		reg_indeps(idx1:idx2,3) = profit_annual(:);

	end
	
	
	s = regstats(reg_deps(:,1), reg_indeps(:,1), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Market leverage regressed on efwa-MB, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]

	reg_results(sim_id, 1)   = s.rsquare;
	reg_results(sim_id, 2:3) = s.tstat.beta';

	
	s = regstats(reg_deps(:,1), reg_indeps(:,1:2), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Market leverage regressed on efwa-MB and Q, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]

	reg_results(sim_id, 4)   = s.rsquare;
	reg_results(sim_id, 5:7) = s.tstat.beta';

	
	s = regstats(reg_deps(:,1), reg_indeps(:,1:3), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Market leverage regressed on efwa-MB, Q, and profitability, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]

	reg_results(sim_id, 8)   = s.rsquare;
	reg_results(sim_id, 9:12) = s.tstat.beta';

	
	filename = sprintf('simulation_outputs/market_timing_simulation%04d.csv', inst_id);
	dlmwrite(filename, reg_results(1:sim_id,:), 'delimiter', '\t');
	
	fprintf(1, '\n\n\n');
	
end

toc






