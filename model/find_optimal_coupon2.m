function find_optimal_coupon2()

	global coupons B0 S0
	global c2_list f2_list
	global restructuring_initial_guess_stack
	
	c2_list = [];
	f2_list = [];
	restructuring_initial_guess_stack = [];
	
	initial_guess = coupons(2);
	
	tol_fun = mean(B0 + S0) / (10^4);
	tol_x   = coupons(2) / (10^2);
	
% 	assert(tol_fun > 0);

	if( tol_fun < 0 )
		tol_fun = .1;
	end
	
	fprintf(1, 'find_optimal_coupon2() -- tol_fun: %.3f, tol_x: %.3f\n\n\n', tol_fun, tol_x);
		
	fmin_option = optimset('TolFun',tol_fun,'TolX',tol_x);
	
	[x,fval] = fminsearch(@(x) find_optimal_coupon2_finder(x), initial_guess, fmin_option);
		
	coupons(2) = x;

end


function result = find_optimal_coupon2_finder(x)
	
	global iota
	global X_U X_D capital coupons B0 S0
	global fid_output
	
	coupons(2) = x;
	
	assert( coupons(2) > 0 );
	
	renew_q_params();
	
	fprintf(1, '* coupon 2: %.4f\n', coupons(2) );
	
% 	find_default_boundary();

	find_optimal_restructuring();
	

	% levered firm value
	F2 = B0(2) * (1 - iota(2)) - capital(2) + S0(2);
	
	fprintf(1, '* levered firm value2: %.4f\n\n\n', F2 );
	
	fprintf(fid_output, '%.12f\t%.12f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', ...
		X_D(1,1), X_D(1,2), X_U(1,1), X_U(1,2), capital(1), coupons(1), coupons(2), F2 );
	
	result = -F2;

% 	Q = (B0 + S0) ./ capital;
% 	Q'
	
	
	% draw a graph of c2 and F2 that have been tried so far
	global c2_list f2_list
	
	c2_list = [c2_list; x];
	f2_list = [f2_list; F2];
	
	[sorted_c2, idx] = sort(c2_list);

	sorted_f2 = f2_list(idx);
	
	plot(sorted_c2, sorted_f2);
	drawnow
	
end


