function monte_carlo_earnigns_growth_summary()

	clc;
	clear;
	
	no_instances = 10;
	
	total_outputs = [];
	
	for inst_id = 1:no_instances
		
		filename = sprintf('simulation_outputs/monte_carlo_earnigns_growth%03d.csv', inst_id);
		
		this_output = dlmread(filename, '\t');

		total_outputs = [total_outputs; this_output];
	end


	no_var = size(total_outputs, 2);
	no_simultaions = size(total_outputs,1);
	
	summary_stat = zeros(no_var, 4);

	summary_stat(:,1) = mean(total_outputs, 1)';
	summary_stat(:,2) = prctile(total_outputs, 25, 1)';
	summary_stat(:,3) = prctile(total_outputs, 50, 1)';
	summary_stat(:,4) = prctile(total_outputs, 75, 1)';
	
	fprintf(1, '\n');
	fprintf(1, '# simulations: %d\n', no_simultaions);
	
	summary_stat
	
end

