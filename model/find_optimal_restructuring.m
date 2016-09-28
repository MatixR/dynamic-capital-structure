function find_optimal_restructuring()

	global X_U X_D capital coupons B0 S0
	global restructuring_initial_guess_stack
	global find_optimal_restructuring_finder_counter
	
	tol_fun = mean(B0 + S0) / (10^6);
	
	if( tol_fun < 0 )
		tol_fun = .01;
	end
	
	fmin_option = optimset('TolFun',tol_fun);
	
	if isempty(restructuring_initial_guess_stack)
		
		initial_guess = zeros(4,1);
		initial_guess(1) = coupons(1);
		initial_guess(2) = capital(1);
		initial_guess(3:4) = X_U(1,:)';
		
	else
		
		[min_c2_error, idx] = min(abs(restructuring_initial_guess_stack(:,1) - coupons(2)));
		
		initial_guess	= restructuring_initial_guess_stack(idx, 2:5)';
		
	end
	
	
	find_optimal_restructuring_finder_counter = 0;

	[x,fval] = fminsearch(@(x) find_optimal_restructuring_finder(x), initial_guess, fmin_option);
	
	assert( fval < 0 );

	coupons(1) = x(1);
	capital(1) = x(2);
	X_U(1,:)   = x(3:4)';
	X_U(2,:)	  = X_U(1,:) * coupons(2)/coupons(1);

	
	temp_row = [coupons(2) x'];
	restructuring_initial_guess_stack = [restructuring_initial_guess_stack; temp_row];
	
	renew_q_params();
	
	fprintf(1, '\n');
	fprintf(1, '* Optimal restructuring boundaries are found!!\n');
	fprintf(1, '* XD: %.4f/%.4f, XU: %.4f/%.4f, K1: %.4f, coupons: %.4f/%.4f\n', ...
		X_D(1,1), X_D(1,2), X_U(1,1), X_U(1,2), capital(1), coupons(1), coupons(2) );
	
end


function result = find_optimal_restructuring_finder(x)
	
	global iota capital coupons X_U X_D B0 S0
	global find_optimal_restructuring_finder_counter
	
	coupons(1) = x(1);
	capital(1) = x(2);
	X_U(1,:)   = x(3:4)';
	X_U(2,:) = X_U(1,:) * coupons(2)/coupons(1);
	X_D(2,:) = X_D(1,:) * coupons(2)/coupons(1);
	
	assert( coupons(1) > 0 );
	assert( sum(sum(X_U < 1)) == 0 );

	renew_q_params();
	
	find_default_boundary();
	
	
	% levered firm value
	F1 = B0(1) * (1 - iota(1)) - capital(1) + S0(1);
	
	fprintf(1, '.');
	
	find_optimal_restructuring_finder_counter = find_optimal_restructuring_finder_counter + 1;
	
	if mod(find_optimal_restructuring_finder_counter, 80) == 0
		fprintf(1, '\n');
	end
	
% 	fprintf(1, 'K1: %.3f, coupons: %.3f/%.3f, XU: %.3f/%.3f, XD: %.3f/%.3f, F1: %.4f\n', ...
% 		capital(1), coupons(1), coupons(2), X_U(1,1), X_U(1,2), X_D(1,1), X_D(1,2), F1 );
% 	
% 	fprintf(1, 'B0: %.3f, S0: %.3f\n', B0(1), S0(1));

	result = -F1;
	
end



