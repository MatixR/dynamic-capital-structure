function monte_carlo_earnigns_growth(scenario_id)

	addpath ../model
	
   rng(1);

   if nargin < 1
		scenario_id = 1;
	end
	
	
	load_parameters();
	load_scenario(scenario_id);

% 	optimization(scenario_id);
	
	run_monte_carlo(scenario_id);

	monte_carlo_print_summary(scenario_id);

end




function run_monte_carlo(scenario_id)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Simulation parameters
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	no_simulations = 200;
	no_years = 60;
	
	T = no_years * 12;
	N = 100;

	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% main body
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	fprintf(1, '****************************************************\n');
	fprintf(1, '* Scenario ID: %d\n', scenario_id);
	fprintf(1, '* #simulations: %d, #years: %d, #firms: %d\n', no_simulations, no_years, N);
	fprintf(1, '****************************************************\n\n');
	
	output_stack = zeros(no_simulations, 10);
	
	output_filename = sprintf('simulation_outputs/monte_carlo_earnigns_growth%03d.csv', scenario_id);
	
	
	for sim_id = 1:no_simulations
		
		fprintf(1, '* Simulation ID: %d/%d (%s)\n', sim_id, no_simulations, datestr(now()));
		
		starting_state = mod(sim_id, 2) + 1;
		
		economy = generate_economy(T, starting_state);

		simulated = generate_firms(N, economy);

		fprintf(1, '\n');

		recessions = (economy.states == 1);

		earnings_growth = zeros(T, N); 
		earnings_growth(1,:) = nan;
		earnings_growth(2:end,:) = log( simulated.ebitda(2:end,:) ./ simulated.ebitda(1:end-1,:) );
		earnings_growth(simulated.ind_default) = nan;

		growth_state1 = earnings_growth(recessions,:);
		growth_state2 = earnings_growth(~recessions,:);

		avg_earnings_growth = nanmean(earnings_growth, 2);

		avg_growth_state1 = avg_earnings_growth(recessions,:);
		avg_growth_state2 = avg_earnings_growth(~recessions,:);
		
		
		output = zeros(1,10);
		
		output(1) = nanmean(growth_state1(:));
		output(2) = nanmean(growth_state2(:));
		output(3) = nanmean(earnings_growth(:));
		output(4) = nanstd(growth_state1(:));
		output(5) = nanstd(growth_state2(:));
		output(6) = nanstd(earnings_growth(:));
		output(7) = nanstd(avg_growth_state1);
		output(8) = nanstd(avg_growth_state2);
		output(9) = nanstd(avg_earnings_growth);

		output(1:3) = output(1:3) * 12;
		output(4:9) = output(4:9) * sqrt(12);

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% 10-year default probability
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		% build the stack of starting point
		starting_points = zeros(N, 2); % coordinates (i,j) of new birth/refinance
		starting_points(:,2) = (1:N)';
		
		[i,j] = find(simulated.ind_default);
		starting_points = [starting_points; [i,j]];

		[i,j] = find(simulated.ind_refinan);
		starting_points = [starting_points; [i,j]];
		
		% count the number of defaults within 10 years after birth/refinance
		no_defaults = 0;
		no_starts = size(starting_points, 1);
		
		for id = 1:no_starts
			i = starting_points(id,1);
			j = starting_points(id,2);

			if i+120 <= T
				default = find( simulated.ind_default((i+1):(i+120), j) );
			else
				default = find( simulated.ind_default((i+1):end, j) );
			end
			
			no_defaults = no_defaults + ~isempty(default);
		end

		default_prob = no_defaults / no_starts;
		
		output(10) = default_prob;
		
		output

		output_stack(sim_id, :) = output;
	
		dlmwrite(output_filename, output_stack(1:sim_id,:), 'delimiter', '\t');
		
		fprintf(1, '\n\n');
		
	end
	
end
