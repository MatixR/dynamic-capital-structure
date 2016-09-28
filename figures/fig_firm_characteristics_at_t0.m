%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fig_firm_characteristics_at_t0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
clear global;
clear gcf;

% dbstop if error;
% dbstop if warning;

addpath ../extension


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global alpha f m
global X_D X_U capital coupons S0 B0


% create the template for the output
scenarios = [ (23:-1:19) 1 (24:28) ];

no_scenarios = length(scenarios);

outputs = zeros(no_scenarios, 5);


% handle the non-simulation variables first
for id = 1:no_scenarios
	
% 	fprintf(1, '* Scenario ID: %d\n', id);
	
	load_scenario(scenarios(id));

	Q = (B0 + S0) ./ capital;
	leverage = B0 ./ (B0 + S0);
	
	outputs(id,1) = m;
	outputs(id,2) = log(f' * capital);
	outputs(id,3) = log(f' * (S0 + B0));
	outputs(id,4) = f' * Q;
	outputs(id,5) = f' * leverage;
	
end

dlmwrite('fig_firm_characteristics_at_t0.csv', outputs, 'delimiter', '\t');



% simulate the economy for the probabilities 
% no_simulations = 5000;
% T = 10 * 12;
% N = 100;
% 
% load_parameters();
% 
% prob_default = zeros(no_scenarios, 2);
% prob_refinan = zeros(no_scenarios, 2);
% 
% for sim = 1:no_simulations
% 	
% 	fprintf(1, '************************************************\n');
% 	fprintf(1, '* Simulation No: %d (%s)\n', sim, datestr(now()));
% 	fprintf(1, '************************************************\n');
% 	
% 	economy1 = generate_economy(T, 1);
% 	economy2 = generate_economy(T, 2);
% 
% 	for id = 1:no_scenarios
% 		
% 		fprintf(1, '* Scenario ID: %d', id);
% 		
% 		load_scenario(id);
% 		
% 		simulated1 = generate_firms(N, economy1);
% 		simulated2 = generate_firms(N, economy2);
% 	
% 		prob_default(id,1) = prob_default(id,1) + mean( any(simulated1.ind_default) );
% 		prob_default(id,2) = prob_default(id,2) + mean( any(simulated2.ind_default) );
% 		prob_refinan(id,1) = prob_refinan(id,1) + mean( any(simulated1.ind_refinan) );
% 		prob_refinan(id,2) = prob_refinan(id,2) + mean( any(simulated2.ind_refinan) );
% 
% 		fprintf(1, '\n');
% 	end
% 	
% 	
% 	
% 	% save the temporary results
% 	avg_prob_default = prob_default / sim;
% 	avg_prob_refinan = prob_refinan / sim;
% 
% 	outputs(:,6) = avg_prob_default * f;
% 	outputs(:,7) = avg_prob_refinan * f;
% 
% 	outputs
% 	
% 	dlmwrite('fig_firm_characteristics_wrt_alpha.csv', outputs, 'delimiter', '\t');
% 
% 	
% 	fprintf(1, '\n');
% 	
% end










