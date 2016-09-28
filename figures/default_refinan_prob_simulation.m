function default_refinan_prob_simulation(machine_id)


if nargin < 1
	machine_id = 1;
end

rng(machine_id);


addpath ../extension

warning('off','MATLAB:nearlySingularMatrix')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global f

scenarios = (1:28);

no_scenarios = length(scenarios);


% simulate the economy for the probabilities 
no_simulations = 5000;
T = 10 * 12;
N = 100;

load_parameters();

prob_default = zeros(no_scenarios, 1);
prob_refinan = zeros(no_scenarios, 1);

outputs = zeros(no_simulations, no_scenarios*2 );

output_filename = sprintf('simulation_outputs/default_refinan_prob_simulation%03d.csv', machine_id);


for sim = 1:no_simulations
	
	fprintf(1, '**********************************************************\n');
	fprintf(1, '* Machine: %d, Simulation No: %d (%s)\n', machine_id, sim, datestr(now()));
	fprintf(1, '**********************************************************\n');
	
	starting_state = mod(sim, 2) + 1;
	
	economy = generate_economy(T, starting_state);

	for id = 1:no_scenarios
		
		fprintf(1, '* Scenario ID: %d', scenarios(id) );
		
		load_scenario(scenarios(id));
		
		simulated = generate_firms(N, economy);
	
		prob_default(id) = mean( any(simulated.ind_default) );
		prob_refinan(id) = mean( any(simulated.ind_refinan) );

		fprintf(1, '\n');
	end
	
	
	% save the temporary results
	outputs(sim,:) = [prob_default' prob_refinan'];
	
	dlmwrite(output_filename, outputs(1:sim,:), 'delimiter', '\t');
	
	fprintf(1, '\n');
	
end










