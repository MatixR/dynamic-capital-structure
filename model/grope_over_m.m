function grope_over_m(id)

    if nargin < 1
        id = 6;
    end

	fprintf(1, '*************************************\n');
	fprintf(1, '* Starting Scenario ID: %d\n', id);
	fprintf(1, '*************************************\n\n');
	
	warning('off', 'MATLAB:nearlySingularMatrix')
	
% 	dbstop if error
% 	dbstop if warning
    
	global alpha m theta sigma_x_s sigma_x_id tax recovery f
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
	fprintf(1, '\n\n');
	
	fprintf(1, '*** Initial Guess ***\n');
	fprintf(1, 'X_D      : %.6f/%.6f\n', X_D(1,1), X_D(1,2) );
	fprintf(1, 'X_U      : %.6f/%.6f\n', X_U(1,1), X_U(1,2) );
	fprintf(1, 'capital1 : %.4f\n', capital(1) );
	fprintf(1, 'coupons  : %.4f/%.4f\n', coupons(1), coupons(2) );
	fprintf(1, '\n\n');

	fid_output = fopen('grope_over_m.csv', 'w');

	incr = 0.01;
	
	for m_next = (m+incr):incr:0.30
		
		m = m_next;
		
		fprintf(1, '* m       : %.2f\n', m );
		fprintf(1, '* coupon 2: %.4f\n', coupons(2) );
		
		renew_q_params();
		find_optimal_restructuring();
		
		coupons(2) = coupons(1) * 1.1;
		
		fprintf(fid_output, '%.3f\t%.8f\t%.8f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', ...
			m, X_D(1,1), X_D(1,2), X_U(1,1), X_U(1,2), capital(1), coupons(1), coupons(2) );
		
		fprintf(1, '\n\n');
		
	end
	
	
	
	fclose(fid_output);

end




