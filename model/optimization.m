function optimization(id)

    if nargin < 1
        id = 33;
    end

	fprintf(1, '*************************************\n');
	fprintf(1, '* Scenario ID: %d\n', id);
	fprintf(1, '*************************************\n\n');
	
	warning('off', 'MATLAB:nearlySingularMatrix')
	
% 	dbstop if error
% 	dbstop if warning
    
	global alpha m theta sigma_x_s sigma_x_id tax recovery iota f
	global X_D X_U capital coupons B0 S0
	global fid_output
	
	load_scenario(id);
	
	fprintf(1, '*** Parameters ***\n');
	fprintf(1, 'alpha      : %.3f\n', alpha);
	fprintf(1, 'm          : %.2f\n', m);
	fprintf(1, 'theta      : %.4f/%.4f\n', theta(1), theta(2));
	fprintf(1, 'sigma_x_s  : %.4f/%.4f\n', sigma_x_s(1), sigma_x_s(2));
	fprintf(1, 'sigma_x_id : %.4f\n', sigma_x_id);
	fprintf(1, 'tax        : %.2f\n', tax);
	fprintf(1, 'recovery   : %.2f/%.2f\n', recovery(1), recovery(2));
	fprintf(1, 'debt issue : %.2f/%.2f\n', iota(1), iota(2));
	fprintf(1, '\n\n');
	
% 	iterate_stack_to_find_initial_guess();
	
	fprintf(1, '*** Initial Guess ***\n');
	fprintf(1, 'X_D      : %.6f/%.6f\n', X_D(1,1), X_D(1,2) );
	fprintf(1, 'X_U      : %.6f/%.6f\n', X_U(1,1), X_U(1,2) );
	fprintf(1, 'capital1 : %.4f\n', capital(1) );
	fprintf(1, 'coupons  : %.4f/%.4f\n', coupons(1), coupons(2) );
	fprintf(1, '\n\n');

	filename = sprintf('outputs/optimization%03d.csv', id);
	fid_output = fopen(filename, 'w');
	
	find_optimal_coupon2();
	find_default_boundary();

	
	% leverage and Q
	Q = (B0 + S0) ./ capital;
	Q_avg = Q' * f;
	
	mkt_leverage = B0 ./ (B0 + S0);
	lev_avg = mkt_leverage' * f;
	
	debt_recovery = recovery .* capital ./ B0;
	

	fprintf(1, '%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\n', ...
		X_D(1,1), X_D(1,2), X_U(1,1), X_U(1,2), capital(1), coupons(1), coupons(2), Q_avg, lev_avg, debt_recovery(1), debt_recovery(2) );
	fprintf(1, '\n\n');

	print_characteristics();

end



function iterate_stack_to_find_initial_guess()

	global iota
	global X_D X_U capital coupons B0 S0
	global scenario_stack
	
	no_scenarios = size(scenario_stack, 1);
	
	best_so_far.X_D		= X_D;
	best_so_far.X_U		= X_U;
	best_so_far.capital	= capital;
	best_so_far.coupons	= coupons;
	best_so_far.firm_value = B0(2) * (1 - iota(2)) - capital(2) + S0(2);
	

	for i = 1:no_scenarios
		
		X_D(1,:)		= scenario_stack(i,8:9);
		X_U(1,:)		= scenario_stack(i,10:11);
		capital(1)	= scenario_stack(i,12);
		coupons		= scenario_stack(i,13:14)';
		
		renew_q_params();
		
		try
			find_default_boundary();
		catch
			continue;
		end
		
		
		if sum(B0 < 0) + sum(S0 < 0) > 0
			continue;
		end
		
		F2 = B0(2) * (1 - iota(2)) - capital(2) + S0(2);
		
		if F2 <= best_so_far.firm_value
			continue;
		end
		
		
		best_so_far.X_D		= X_D;
		best_so_far.X_U		= X_U;
		best_so_far.capital	= capital;
		best_so_far.coupons	= coupons;
		best_so_far.firm_value = F2;
		
	end

	
	X_D		= best_so_far.X_D;
	X_U		= best_so_far.X_U;
	capital	= best_so_far.capital;
	coupons	= best_so_far.coupons;
	
end


