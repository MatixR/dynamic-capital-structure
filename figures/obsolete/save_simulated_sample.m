%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save_simulated_sample
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

global alpha

T = 12 * 100;
N = 20;

no_scenarios = 17;

load_parameters();

economy = generate_economy(T, 2);

for id = 1:no_scenarios
	
	load_scenario(id);

	fprintf(1, '*************************************\n');
	fprintf(1, '* Scenario ID: %d, alpha: %.2f\n', id, alpha);
	fprintf(1, '*************************************\n');
	
	% random number generator seed
	rng(1);

	% Simulate sample firms
	simulated = generate_sample(T, N);
	
	filename = sprintf('simulated_samples/scenario%d.mat', id);
	save(filename, '-v7.3', '-struct', 'simulated');
	
	fprintf(1, '\n\n\n');
	
end

toc






