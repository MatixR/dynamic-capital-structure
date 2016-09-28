function find_default_boundary()

	global X_D coupons;
	
	% confirm that the equity price is zero at the default boundary
	S = equity_price(X_D(1,1), 1);
	assert( S(1) == 0 );
	
	S = equity_price(X_D(1,2), 1);
	assert( S(2) == 0 );
	

%	fmin_option = optimset('TolFun',1e-6,'TolX',1e-6);
	fmin_option = optimset('TolX',1e-6);
	
	initial_guess = X_D(1,:);

	[x,fval] = fminsearch(@(x) find_default_boundary_finder(x), initial_guess, fmin_option);
	
% 	assert( fval < 1e-3 );
	
	X_D(1,:) = x;
	X_D(2,:) = X_D(1,:) * coupons(2)/coupons(1);

	renew_q_params();
   
%  assert_convexity_at_XD();
	
end


function abs_err = find_default_boundary_finder(x)
	
	global X_D X_U coupons
	
	X_D(1,:) = x;
	X_D(2,:) = X_D(1,:) * coupons(2)/coupons(1);
	
	assert( max(X_D(:)) < 1 );
	
	if( X_D(1,1) > min(X_U(1,:)) )
		abs_err = 1e50 * (X_D(1,1) - min(X_U(1,:)));
		return
	end
	
	renew_q_params();
	
	partial_S1 = partial_S_partial_X(X_D(1,1), 1);
	partial_S2 = partial_S_partial_X(X_D(1,2), 1);
	
	abs_err = abs(partial_S1(1)) + abs(partial_S2(2));
	
end


function assert_convexity_at_XD()

	global X_D

	old_XD = X_D;

	% assert : equity price at X_D is zero
	S = equity_price(old_XD(1,1), 1);
	assert( S(1) == 0 );

	S = equity_price(old_XD(1,2), 1);
	assert( S(2) == 0 );


	% assert : limited liability, equity price is positive if X > X_D
	S = equity_price(old_XD(1,1) + 1e-6, 1);
	assert( S(1) > 0 );

	S = equity_price(old_XD(1,2) + 1e-6, 1);
	assert( S(2) > 0 );


	% assert : no need to delay default at state 1
	X_D(1,1) = X_D(1,1) - 1e-6;

	renew_q_params();

	S = equity_price(old_XD(1,1), 1);
	assert( S(1) < 0 );


	% assert : no need to delay default at state 2
	X_D = old_XD;
	X_D(1,2) = X_D(1,2) - 1e-6;

	renew_q_params();

	S = equity_price(old_XD(1,2), 1);
	assert( S(2) < 0 );


	% restore the old values
	X_D = old_XD;
	renew_q_params();

end


