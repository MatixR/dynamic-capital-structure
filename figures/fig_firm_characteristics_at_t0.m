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
scenarios = [(6:-1:1) (13:18)];

print_outputs(scenarios);

% then, by m
scenarios = [(23:-1:19) 1 (24:28)];

print_outputs(scenarios);




function print_outputs(scenarios)

	global alpha m tax
	global capital coupons S0 B0 X_U

	no_scenarios = length(scenarios);

	outputs = zeros(no_scenarios, 20);

	% handle the non-simulation variables first
	for id = 1:no_scenarios

	% 	fprintf(1, '* Scenario ID: %d\n', id);

		load_scenario(scenarios(id));

		Q = (B0 + S0) ./ capital;
		leverage = B0 ./ (B0 + S0);

		earnings = capital.^alpha - m .* capital;
		netincome = (1 - tax) * (earnings - coupons);

		outputs(id,1) = alpha;
		outputs(id,2) = m;
		outputs(id,3:4) = log(capital)';
		outputs(id,5:6) = log(B0 + S0)';
		outputs(id,7:10) = [X_U(1,:) X_U(2,:)];
		outputs(id,11:12) = (coupons ./ capital)';
		outputs(id,13:14) = (earnings ./ capital)';
		outputs(id,15:16) = (netincome ./ capital)';
		
		outputs(id,17:18) = Q';
		outputs(id,19:20) = leverage';
		
	end
	
	% determine the x-axis
	if outputs(end,1) - outputs(1,1) > 0
		x = outputs(:,1);
		x_name = 'alpha';
	else
		x = outputs(:,2);
		x_name = 'm';
	end
	
	% draw figures
	draw_figure(x, outputs(:,3:4), x_name, 'log_capital');
	draw_figure(x, outputs(:,5:6), x_name, 'log_firm_value');
	draw_figure(x, outputs(:,7:10) - 1, x_name, 'investment_rate');
	draw_figure(x, outputs(:,11:12), x_name, 'coupons_per_capital');
	draw_figure(x, outputs(:,13:14), x_name, 'EBIT_per_capital');
	draw_figure(x, outputs(:,15:16), x_name, 'net_income_per_capital');
	draw_figure(x, outputs(:,17:18), x_name, 'Q');
	draw_figure(x, outputs(:,19:20), x_name, 'leverage');

end


function draw_figure(x, y, x_name, y_name)

	clear gcf;

	if size(y,2) == 2
		diff = y(:,1) - y(:,2);
		
		disp(['X: ', x_name, ', Y: ', y_name]);
		disp(['difference-- mean: ', num2str(mean(diff)), ', stdev: ', num2str(std(diff)) ]);
		disp(' ');
		
		plot( ...
			x, y(:,1), 'b-', ...
			x, y(:,2), 'r-.');

		legend('bad state', 'good state', 'Location', 'best');
		
	else
		plot( ...
			x, smooth(y(:,1)), 'b-', ...
			x, smooth(y(:,2)), 'b:', ...
			x, smooth(y(:,3)), 'r-.', ...
			x, smooth(y(:,4)), 'r--' );

		legend('bad -> bad', 'bad -> good', 'good -> bad', 'good -> good', 'Location', 'best');
		
	end
	
	grid on;
	xlabel(x_name);
	ylabel(strrep(y_name, '_', ' '));
	
	
	filename = sprintf('./fig_firm_characteristics_at_t0/%s_%s.png', x_name, y_name);
	
	saveas(gcf, filename);
	
end


