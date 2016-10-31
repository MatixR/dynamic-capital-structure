%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% table_reg_investment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table_reg_investment(inst_id)

addpath ../model

if nargin == 0
	inst_id = 1;
end

rng(inst_id);



global alpha m

load_parameters();

% Compustat sample: 44 years (1972-2015), 1489 firms per year on average
years_to_simulate = 84;
years_to_drop     = 40;

T = years_to_simulate * 12;
N = 165;

senario_ids = [1 3 14 23 (28:32)];
no_scenarios = length(senario_ids);


% the tables to store results for every simulation
reg_results = [];

no_simulations = 100;

for sim_id = 1:no_simulations
	
	fprintf(1, '**************************************************\n');
	fprintf(1, '** Simulation ID : %d (%s)\n', sim_id, datestr(now()));
	fprintf(1, '**************************************************\n');

	% the tables to store simulated data to run a regression
	reg_no_obs = (years_to_simulate - years_to_drop - 1) * N;
	reg_deps   = zeros(reg_no_obs * no_scenarios, 1);
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
		
% 		comparison = [lev_mkt(:,1) lev_quasi(:,1)];
% 		plot(comparison);

		capital_annual  = simulated.capital_hist(12:12:T,:);
		Q_annual        = Q(12:12:T,:);
		leverage_annual = lev_quasi(12:12:T,:);


		% derive annual investments
		ind_default_annual = false(years_to_simulate, N);
		profit_annual		 = zeros(years_to_simulate, N);

		for t = 1:years_to_simulate
			
			idx1 = (t-1) * 12 + 1;
			idx2 = t * 12;
			
			ind_default_annual(t,:) = any( simulated.ind_default(idx1:idx2,:), 1);
			profit_annual(t,:) = sum( simulated.netincome(idx1:idx2,:), 1);
			
		end
		
		profit_annual = profit_annual ./ capital_annual;
		profit_annual(ind_default_annual) = nan;

		net_invest = zeros(years_to_simulate, N);
		net_invest(2:end,:) = ( capital_annual(2:end,:) - capital_annual(1:end-1,:) ) ./ capital_annual(1:end-1,:);

		net_invest(ind_default_annual) = nan;


		% drop the first 'years_to_drop' years
		net_invest		 = net_invest     ((years_to_drop+2):end   ,:);
		Q_annual        = Q_annual       ((years_to_drop+1):end-1 ,:);
		profit_annual	 = profit_annual  ((years_to_drop+1):end-1 ,:);
		leverage_annual = leverage_annual((years_to_drop+1):end-1 ,:);


		% add to the regression data tables
		idx1 = (i-1) * reg_no_obs + 1;
		idx2 = i * reg_no_obs;

		reg_deps  (idx1:idx2)   = net_invest(:);
		reg_indeps(idx1:idx2,1) = Q_annual(:);
		reg_indeps(idx1:idx2,2) = profit_annual(:);
		reg_indeps(idx1:idx2,3) = leverage_annual(:);

	end
	
	this_reg_result = [];
	
	s = regstats(reg_deps(1:reg_no_obs), reg_indeps(1:reg_no_obs,1), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Homogenous - Q alone, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];

	s = regstats(reg_deps(1:reg_no_obs), reg_indeps(1:reg_no_obs,2), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Homogenous - profitability alone, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];

	s = regstats(reg_deps(1:reg_no_obs), reg_indeps(1:reg_no_obs,1:3), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Homogenous - Q, profitability and leverage, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];

	s = regstats(reg_deps, reg_indeps(:,1), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Heterogenous - Q alone, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];

	s = regstats(reg_deps, reg_indeps(:,2), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Heterogenous - profitability alone, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];
	
	s = regstats(reg_deps, reg_indeps(:,1:3), 'linear', {'tstat','rsquare'} );
	fprintf(1, 'Heterogenous - Q, profitability and leverage, R2: %.3f\n', s.rsquare);
	[s.tstat.beta s.tstat.t]
	
	this_reg_result = [this_reg_result s.tstat.beta' s.rsquare];


	% append the regressino results to the stack
	reg_results = [reg_results; this_reg_result];
	
	filename = sprintf('simulation_outputs/table_reg_investment%04d.csv', inst_id);
	dlmwrite(filename, reg_results(1:sim_id,:), 'delimiter', '\t');
	
	fprintf(1, '\n\n\n');
	
end




