function q_D = arrow_default_price(X, state0)
%
% input:		X_t, nu_0
% output:	q_{D, nu_t nu_D}
%

	global qd_params
	
	params = qd_params(state0);

	XD_this = params.XD_this;
	XU_this = params.XU_this;
	
	assert( min(XU_this) > max(XD_this) );
	
	
	if (XD_this(2) <= XD_this(1)) && (XU_this(2) <= XU_this(1))

		q_D = arrow_default_price_case1(X, state0);
		
	elseif (XD_this(2) <= XD_this(1)) && (XU_this(1) <= XU_this(2))

		q_D = arrow_default_price_case2(X, state0);

	elseif (XD_this(1) <= XD_this(2)) && (XU_this(2) <= XU_this(1))

		q_D = arrow_default_price_case3(X, state0);

	elseif (XD_this(1) <= XD_this(2)) && (XU_this(1) <= XU_this(2))

		q_D = arrow_default_price_case4(X, state0);

	else
		assert(false);
	end
	
	
	no_neg_price = sum(sum(q_D < -1e-10));
	
	assert( no_neg_price == 0 );

end



function q_D = arrow_default_price_case1(X, state0)

	global lambda_hat riskfree
	global qd_params
	
	params = qd_params(state0);

	XD_this = params.XD_this;
	XU_this = params.XU_this;
	
	q_D = zeros(2,2);

	if (X <= XD_this(2))

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(2)) && (X <= XD_this(1))

		Xj = X.^(params.j);

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = params.s21' * Xj + lambda_hat(2) / (riskfree(2) + lambda_hat(2));
		q_D(2,2) = params.s22' * Xj;

	elseif (X > XD_this(1)) && (X <= XU_this(2))

		Xk = X.^(params.k);
		eps_Xk = params.eps .* Xk;

		q_D(1,1) = params.h11' * Xk;
		q_D(1,2) = params.h12' * Xk;
		q_D(2,1) = params.h11' * eps_Xk;
		q_D(2,2) = params.h12' * eps_Xk;

	elseif (X > XU_this(2)) && (X <= XU_this(1))

		Xl = X.^(params.l);

		q_D(1,1) = params.g11' * Xl;
		q_D(1,2) = params.g12' * Xl;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	else

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	end

end



function q_D = arrow_default_price_case2(X, state0)

	global lambda_hat riskfree
	global qd_params
	
	params = qd_params(state0);

	XD_this = params.XD_this;
	XU_this = params.XU_this;
	
	q_D = zeros(2,2);

	if (X <= XD_this(2))

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(2)) && (X <= XD_this(1))

		Xj = X.^(params.j);

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = params.s21' * Xj + lambda_hat(2) / (riskfree(2) + lambda_hat(2));
		q_D(2,2) = params.s22' * Xj;

	elseif (X > XD_this(1)) && (X <= XU_this(1))

		Xk = X.^(params.k);
		eps_Xk = params.eps .* Xk;

		q_D(1,1) = params.h11' * Xk;
		q_D(1,2) = params.h12' * Xk;
		q_D(2,1) = params.h11' * eps_Xk;
		q_D(2,2) = params.h12' * eps_Xk;

	elseif (X > XU_this(1)) && (X <= XU_this(2))

		Xj = X.^(params.j);

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = params.g21' * Xj;
		q_D(2,2) = params.g22' * Xj;

	else

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	end

end



function q_D = arrow_default_price_case3(X, state0)

	global lambda_hat riskfree
	global qd_params
	
	params = qd_params(state0);

	XD_this = params.XD_this;
	XU_this = params.XU_this;
	
	q_D = zeros(2,2);

	if (X <= XD_this(1))

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(1)) && (X <= XD_this(2))

		Xl = X.^(params.l);

		q_D(1,1) = params.s11' * Xl;
		q_D(1,2) = params.s12' * Xl + lambda_hat(1) / (riskfree(1) + lambda_hat(1));
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(2)) && (X <= XU_this(2))

		Xk = X.^(params.k);
		eps_Xk = params.eps .* Xk;

		q_D(1,1) = params.h11' * Xk;
		q_D(1,2) = params.h12' * Xk;
		q_D(2,1) = params.h11' * eps_Xk;
		q_D(2,2) = params.h12' * eps_Xk;

	elseif (X > XU_this(2)) && (X <= XU_this(1))

		Xl = X.^(params.l);

		q_D(1,1) = params.g11' * Xl;
		q_D(1,2) = params.g12' * Xl;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	else

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	end

end



function q_D = arrow_default_price_case4(X, state0)

	global lambda_hat riskfree
	global qd_params
	
	params = qd_params(state0);

	XD_this = params.XD_this;
	XU_this = params.XU_this;
	
	q_D = zeros(2,2);

	if (X <= XD_this(1))

		q_D(1,1) = 1;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(1)) && (X <= XD_this(2))

		Xl = X.^(params.l);

		q_D(1,1) = params.s11' * Xl;
		q_D(1,2) = params.s12' * Xl + lambda_hat(1) / (riskfree(1) + lambda_hat(1));
		q_D(2,1) = 0;
		q_D(2,2) = 1;

	elseif (X > XD_this(2)) && (X <= XU_this(1))

		Xk = X.^(params.k);
		eps_Xk = params.eps .* Xk;

		q_D(1,1) = params.h11' * Xk;
		q_D(1,2) = params.h12' * Xk;
		q_D(2,1) = params.h11' * eps_Xk;
		q_D(2,2) = params.h12' * eps_Xk;

	elseif (X > XU_this(1)) && (X <= XU_this(2))

		Xj = X.^(params.j);

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = params.g21' * Xj;
		q_D(2,2) = params.g22' * Xj;

	else

		q_D(1,1) = 0;
		q_D(1,2) = 0;
		q_D(2,1) = 0;
		q_D(2,2) = 0;

	end

end
