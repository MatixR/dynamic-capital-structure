function partial = partial_qU_partial_X(X, state0)

	global X_D X_U
	
	XD_this = X_D(state0,:);
	XU_this = X_U(state0,:);
	
	
	% 2x2 matrix by (nu_t, nu_U)
	
	if (XD_this(2) <= XD_this(1)) && (XU_this(2) <= XU_this(1))
		
		partial = partial_qU_partial_X_case1(X, state0);
		
	elseif (XD_this(2) <= XD_this(1)) && (XU_this(1) <= XU_this(2))
		
		partial = partial_qU_partial_X_case2(X, state0);
		
	elseif (XD_this(1) <= XD_this(2)) && (XU_this(2) <= XU_this(1))

		partial = partial_qU_partial_X_case3(X, state0);

	elseif (XD_this(1) <= XD_this(2)) && (XU_this(1) <= XU_this(2))

		partial = partial_qU_partial_X_case4(X, state0);

	else
		assert(false);
	end
	
	
end


function partial = partial_qU_partial_X_case1(X, state0)

	global X_D X_U
	global qu_params
	
	XD_this = X_D(state0,:);
	XU_this = X_U(state0,:);
	
	param = qu_params(state0);
	
	partial = zeros(2,2);
	
	if X >= XD_this(2) && X < XD_this(1)

		Xj = X.^(param.j - 1);

		partial(2,1) = sum(param.s21 .* param.j .* Xj);
		partial(2,2) = sum(param.s22 .* param.j .* Xj);

	elseif X >= XD_this(1) && X <= XU_this(2)

		Xk = X.^(param.k - 1);
		
		partial(1,1) = sum(param.h11 .* param.k .* Xk);
		partial(1,2) = sum(param.h12 .* param.k .* Xk);
		partial(2,1) = sum(param.h11 .* param.eps .* param.k .* Xk);
		partial(2,2) = sum(param.h12 .* param.eps .* param.k .* Xk);

	elseif X > XU_this(2) && X <= XU_this(1)

		Xl = X.^(param.l - 1);

		partial(1,1) = sum(param.g11 .* param.l .* Xl);
		partial(1,2) = sum(param.g12 .* param.l .* Xl);

	end
		
end



function partial = partial_qU_partial_X_case2(X, state0)

	global X_D X_U
	global qu_params
	
	XD_this = X_D(state0,:);
	XU_this = X_U(state0,:);
	
	param = qu_params(state0);
	
	partial = zeros(2,2);

	if X >= XD_this(2) && X < XD_this(1)

		Xj = X.^(param.j - 1);
		
		partial(2,1) = sum(param.s21 .* param.j .* Xj);
		partial(2,2) = sum(param.s22 .* param.j .* Xj);

	elseif X >= XD_this(1) && X <= XU_this(1)

		Xk = X.^(param.k - 1);
		
		partial(1,1) = sum(param.h11 .* param.k .* Xk);
		partial(1,2) = sum(param.h12 .* param.k .* Xk);
		partial(2,1) = sum(param.h11 .* param.eps .* param.k .* Xk);
		partial(2,2) = sum(param.h12 .* param.eps .* param.k .* Xk);

	elseif X > XU_this(1) && X <= XU_this(2)

		Xj = X.^(param.j - 1);

		partial(2,1) = sum(param.g21 .* param.j .* Xj);
		partial(2,2) = sum(param.g22 .* param.j .* Xj);

	end

end



function partial = partial_qU_partial_X_case3(X, state0)

	global X_D X_U
	global qu_params
	
	XD_this = X_D(state0,:);
	XU_this = X_U(state0,:);
	
	param = qu_params(state0);
	
	partial = zeros(2,2);

	if X >= XD_this(1) && X < XD_this(2)

		Xl = X.^(param.l - 1);
		
		partial(1,1) = sum(param.s11 .* param.l .* Xl);
		partial(1,2) = sum(param.s12 .* param.l .* Xl);

	elseif X >= XD_this(2) && X <= XU_this(2)

		Xk = X.^(param.k - 1);
		
		partial(1,1) = sum(param.h11 .* param.k .* Xk);
		partial(1,2) = sum(param.h12 .* param.k .* Xk);
		partial(2,1) = sum(param.h11 .* param.eps .* param.k .* Xk);
		partial(2,2) = sum(param.h12 .* param.eps .* param.k .* Xk);

	elseif X > XU_this(2) && X <= XU_this(1)

		Xl = X.^(param.l - 1);

		partial(1,1) = sum(param.g11 .* param.l .* Xl);
		partial(1,2) = sum(param.g12 .* param.l .* Xl);

	end

end



function partial = partial_qU_partial_X_case4(X, state0)

	global X_D X_U
	global qu_params
	
	XD_this = X_D(state0,:);
	XU_this = X_U(state0,:);
	
	param = qu_params(state0);
	
	partial = zeros(2,2);

	if X >= XD_this(1) && X < XD_this(2)

		Xl = X.^(param.l - 1);
		
		partial(1,1) = sum(param.s11 .* param.l .* Xl);
		partial(1,2) = sum(param.s12 .* param.l .* Xl);

	elseif X >= XD_this(2) && X <= XU_this(1)

		Xk = X.^(param.k - 1);
		
		partial(1,1) = sum(param.h11 .* param.k .* Xk);
		partial(1,2) = sum(param.h12 .* param.k .* Xk);
		partial(2,1) = sum(param.h11 .* param.eps .* param.k .* Xk);
		partial(2,2) = sum(param.h12 .* param.eps .* param.k .* Xk);

	elseif X > XU_this(1) && X <= XU_this(2)

		Xj = X.^(param.j - 1);

		partial(2,1) = sum(param.g21 .* param.j .* Xj);
		partial(2,2) = sum(param.g22 .* param.j .* Xj);

	end

end


