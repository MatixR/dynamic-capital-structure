%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fig_firm_characteristics_at_t0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
clear global;
clear gcf;

% dbstop if error;
% dbstop if warning;

addpath ../model


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first by alpha
scenarios = [(12:-1:2) (13:18)];

print_outputs(scenarios, 'fig_firm_characteristics_at_t0_alpha.csv');

% then, by m
scenarios = [(23:-1:19) 1 (24:28)];

print_outputs(scenarios, 'fig_firm_characteristics_at_t0_m.csv');




function print_outputs(scenarios, filename)

	global alpha f m tax
	global capital coupons S0 B0

	no_scenarios = length(scenarios);

	outputs = zeros(no_scenarios, 5);


	% handle the non-simulation variables first
	for id = 1:no_scenarios

	% 	fprintf(1, '* Scenario ID: %d\n', id);

		load_scenario(scenarios(id));

		Q = (B0 + S0) ./ capital;
		leverage = B0 ./ (B0 + S0);

		earnings = capital.^alpha - m .* capital;
		netincome = (1 - tax) * (earnings - coupons);
		profitability = netincome ./ capital;

		outputs(id,1) = alpha;
		outputs(id,2) = m;
		outputs(id,3) = f' * Q;
		outputs(id,4) = f' * leverage;
		outputs(id,5) = f' * profitability;

	end

	dlmwrite(filename, outputs, 'delimiter', '\t');
	
end