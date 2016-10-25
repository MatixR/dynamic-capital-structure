%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% table_asset_return_moments_summary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table_asset_return_moments_summary()

	clc;
	clear;

	no_machiens = 20;

	total_outputs = [];

	for machine = 1:no_machiens

		filename = sprintf('simulation_outputs/table_asset_return_moments%04d.csv', machine);

		this_output = dlmread(filename, '\t');

		total_outputs = [total_outputs; this_output];

	end


	no_simultaions = size(total_outputs,1);

	fprintf(1, '\n');
	fprintf(1, '# simulations: %d\n', no_simultaions);

	total_outputs = total_outputs * 100;
	
	pctile05 = prctile( total_outputs, 5 );
	pctile50 = prctile( total_outputs, 50 );
	pctile95 = prctile( total_outputs, 95 );

	for i = 1:6
		
		idx = (i-1)*2 + 1;
		
		fprintf(1, '%.3f\t%.3f\n', pctile50(idx), pctile50(idx+1));
		
		fprintf(1, '[%.3f, %.3f]\t[%.3f, %.3f]\n', ...
			pctile05(idx), pctile95(idx), pctile05(idx+1), pctile95(idx+1));
		
		fprintf(1, '\n');
	end
	
end

