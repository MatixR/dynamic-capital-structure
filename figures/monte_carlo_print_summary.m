function monte_carlo_print_summary(scenario_id)

   if nargin < 1
		id_start = 24;
		id_end   = 27;
	else
		id_start = scenario_id;
		id_end   = scenario_id;
	end
	
	for id = id_start:id_end
		print_summary_statistics(id);
	end

end


function print_summary_statistics(scenario_id)

	filename = sprintf('simulation_outputs/monte_carlo_earnigns_growth%03d.csv', scenario_id);

	output_stack = dlmread(filename, '\t');
	

	no_var = size(output_stack, 2);
	
	summary_stat = zeros(no_var, 4);

	summary_stat(:,1) = mean(output_stack, 1)';
	summary_stat(:,2) = prctile(output_stack, 25, 1)';
	summary_stat(:,3) = prctile(output_stack, 50, 1)';
	summary_stat(:,4) = prctile(output_stack, 75, 1)';
	
	summary_stat
	
	filename = sprintf('simulation_outputs/monte_carlo_summary%03d.csv', scenario_id);

	dlmwrite(filename, summary_stat, 'delimiter', '\t');
	
end

