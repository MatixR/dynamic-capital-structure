function params = arrow_restructuring_params(state0)

	global X_D X_U
	
	XD_this = X_D(state0,:)';
	XU_this = X_U(state0,:)';

% 	assert( XD_this(1) >= XD_this(2) );

	
	params = arrow_common_params();
	
	params.state0 = state0;
	params.XD_this = XD_this;
	params.XU_this = XU_this;
	
	if (XD_this(2) <= XD_this(1)) && (XU_this(2) <= XU_this(1))

		params = arrow_restructuring_params_case1(params);

	elseif (XD_this(2) <= XD_this(1)) && (XU_this(1) <= XU_this(2))

		params = arrow_restructuring_params_case2(params);

	elseif (XD_this(1) <= XD_this(2)) && (XU_this(2) <= XU_this(1))

		params = arrow_restructuring_params_case3(params);

	elseif (XD_this(1) <= XD_this(2)) && (XU_this(1) <= XU_this(2))

		params = arrow_restructuring_params_case4(params);

	else
		assert(false);
	end

end


function params = arrow_restructuring_params_case1(params)

	XD_this = params.XD_this;
	XU_this = params.XU_this;

	assert( XD_this(2) <= XD_this(1) );
	assert( XU_this(2) <= XU_this(1) );
	
	global riskfree lambda_hat
    
	j = params.j;
	k = params.k;
	l = params.l;
	eps = params.eps;

	% Ax = b
	% x = [g11, g12, h11, h12, s21, s22]

	A = zeros(16,16);
	b = zeros(16,1);

	XD1_j = XD_this(1) .^ j;
	XD1_k = XD_this(1) .^ k;
	XD2_j = XD_this(2) .^ j;
	XU1_l = XU_this(1) .^ l;
	XU2_k = XU_this(2) .^ k;
	XU2_l = XU_this(2) .^ l;
	
	% Boundary condition (a)
	A(1,5:8) = XD1_k;

	% Boundary condition (b)
	A(2,1:2) = XU2_l;
	A(2,5:8) = -XU2_k;
	
	% Boundary condition (c)
	A(3,1:2) = l .* XU2_l;
	A(3,5:8) = - (k .* XU2_k);
	
	% Boundary condition (d)
	A(4,1:2) = XU1_l;
	b(4) = 1;
		
	% Boundary condition (e)
	A(5,9:12) = XD1_k;
	
	% Boundary condition (f)
	A(6,3:4)  = XU2_l';
	A(6,9:12) = -XU2_k';
	b(6) = - lambda_hat(1) / (riskfree(1) + lambda_hat(1));
	
	% Boundary condition (g)
	A(7,3:4)  = l .* XU2_l;
	A(7,9:12) = - (k .* XU2_k);
	
	% Boundary condition (h)
	A(8,3:4) = XU1_l;
	b(8) = b(6);
	
	% Boundary condition (i)
	A(9,13:14) = XD2_j;
	
	% Boundary condition (j)
	A(10,5:8)   = eps .* XD1_k;
	A(10,13:14) = - XD1_j;
	
	% Boundary condition (k)
	A(11,5:8)   = eps .* k .* XD1_k;
	A(11,13:14) = - (j .* XD1_j);
	
	% Boundary condition (l)
	A(12,5:8) = eps .* XU2_k;	
	
	% Boundary condition (m)
	A(13,15:16) = XD2_j;
	
	% Boundary condition (n)
	A(14,9:12)  = eps .* XD1_k;
	A(14,15:16) = - XD1_j;
	
	% Boundary condition (o)
	A(15,9:12)  = eps .* k .* XD1_k;
	A(15,15:16) = - (j .* XD1_j);
	
	% Boundary condition (p)
	A(16,9:12) = eps .* XU2_k;	
	b(16) = 1;

	
	% solution
	x = A \ b;
	
	params.g11 = x(1:2);
	params.g12 = x(3:4);
	params.h11 = x(5:8);
	params.h12 = x(9:12);
	params.s21 = x(13:14);
	params.s22 = x(15:16);
	
end



function params = arrow_restructuring_params_case2(params)

	XD_this = params.XD_this;
	XU_this = params.XU_this;

	assert( XD_this(2) <= XD_this(1) );
	assert( XU_this(1) <= XU_this(2) );

	global riskfree lambda_hat
    
	j = params.j;
	k = params.k;
	l = params.l;
	eps = params.eps;

	% Ax = b
	% x = [g21, g22, h11, h12, s21, s22]

	A = zeros(16,16);
	b = zeros(16,1);

	XD1_j = XD_this(1) .^ j;
	XD1_k = XD_this(1) .^ k;
	XD2_j = XD_this(2) .^ j;
	XU1_j = XU_this(1) .^ j;
	XU1_k = XU_this(1) .^ k;
	XU2_j = XU_this(2) .^ j;
	
	
	% Boundary condition (a)
	A(1,5:8) = XD1_k;

	% Boundary condition (b)
	A(2,5:8) = XU1_k;
	b(2) = 1;
	
	% Boundary condition (c)
	A(3,9:12) = XD1_k;
	
	% Boundary condition (d)
	A(4,9:12) = XU1_k;
		
	% Boundary condition (e)
	A(5,13:14) = XD2_j;
	
	% Boundary condition (f)
	A(6,5:8)   = eps .* XD1_k;
	A(6,13:14) = - XD1_j;
	
	% Boundary condition (g)
	A(7,5:8)   = eps .* k .* XD1_k;
	A(7,13:14) = - j .* XD1_j;
	
	% Boundary condition (h)
	A(8,1:2) = XU1_j;
	A(8,5:8) = - eps .* XU1_k;
	b(8) = - lambda_hat(2) / (riskfree(2) + lambda_hat(2));
	
	% Boundary condition (i)
	A(9,1:2) = j .* XU1_j;
	A(9,5:8) = - eps .* k .* XU1_k;
	
	% Boundary condition (j)
	A(10,1:2) = XU2_j;
	b(10) = - lambda_hat(2) / (riskfree(2) + lambda_hat(2));
	
	% Boundary condition (k)
	A(11,15:16) = XD2_j;
	
	% Boundary condition (l)
	A(12,9:12)  = eps .* XD1_k;
	A(12,15:16) = - XD1_j;
	
	% Boundary condition (m)
	A(13,9:12)  = eps .* k .* XD1_k;
	A(13,15:16) = - j .* XD1_j;
	
	% Boundary condition (n)
	A(14,3:4)  = XU1_j;
	A(14,9:12) = - eps .* XU1_k;
	
	% Boundary condition (o)
	A(15,3:4)  = j .* XU1_j;
	A(15,9:12) = - eps .* k .* XU1_k;
	
	% Boundary condition (p)
	A(16,3:4) = XU2_j;
	b(16) = 1;

	
	
	% solution
	x = A \ b;
	
	params.g21 = x(1:2);
	params.g22 = x(3:4);
	params.h11 = x(5:8);
	params.h12 = x(9:12);
	params.s21 = x(13:14);
	params.s22 = x(15:16);

end



function params = arrow_restructuring_params_case3(params)

	XD_this = params.XD_this;
	XU_this = params.XU_this;

	assert( XD_this(1) <= XD_this(2) );
	assert( XU_this(2) <= XU_this(1) );

	global riskfree lambda_hat
    
	j = params.j;
	k = params.k;
	l = params.l;
	eps = params.eps;

	% Ax = b
	% x = [g11 (1:2), g12 (3:4), h11 (5:8), h12 (9:12), s11 (13:14), s12 (15:16)]

	A = zeros(16,16);
	b = zeros(16,1);

	XD1_l = XD_this(1) .^ l;
	XD2_l = XD_this(2) .^ l;
	XD2_k = XD_this(2) .^ k;
	XU2_k = XU_this(2) .^ k;
	XU2_l = XU_this(2) .^ l;
	XU1_l = XU_this(1) .^ l;
	
	
	% Boundary condition (a)
	A(1,13:14)  = XD1_l;

	% Boundary condition (b)
	A(2,13:14)  = XD2_l;
	A(2,5:8)    = - XD2_k;
	
	% Boundary condition (c)
	A(3,13:14)  = l .* XD2_l;
	A(3,5:8)    = - k .* XD2_k;
	
	% Boundary condition (d)
	A(4,5:8)    = XU2_k;
	A(4,1:2)    = - XU2_l;
		
	% Boundary condition (e)
	A(5,5:8)    = k .* XU2_k;
	A(5,1:2)    = - l .* XU2_l;
	
	% Boundary condition (f)
	A(6,1:2)    = XU1_l;
	b(6) = 1;
	
	% Boundary condition (g)
	A(7,15:16)  = XD1_l;
	
	% Boundary condition (h)
	A(8,15:16)  = XD2_l;
	A(8,9:12)   = - XD2_k;
	
	% Boundary condition (i)
	A(9,15:16)  = l .* XD2_l;
	A(9,9:12)   = - k .* XD2_k;
	
	% Boundary condition (j)
	A(10,9:12)  = XU2_k;
	A(10,3:4)   = - XU2_l;
	b(10) = lambda_hat(1) / (riskfree(1) + lambda_hat(1));
	
	% Boundary condition (k)
	A(11,9:12)  = k .* XU2_k;
	A(11,3:4)   = - l .* XU2_l;
	
	% Boundary condition (l)
	A(12,3:4)   = XU1_l;
	b(12) = - lambda_hat(1) / (riskfree(1) + lambda_hat(1));
	
	% Boundary condition (m)
	A(13,5:8)   = eps .* XD2_k;
	
	% Boundary condition (n)
	A(14,5:8)   = eps .* XU2_k;
	
	% Boundary condition (o)
	A(15,9:12)  = eps .* XD2_k;
	
	% Boundary condition (p)
	A(16,9:12)  = eps .* XU2_k;
	b(16) = 1;

	
	
	% solution
	x = A \ b;
	
	params.g11 = x(1:2);
	params.g12 = x(3:4);
	params.h11 = x(5:8);
	params.h12 = x(9:12);
	params.s11 = x(13:14);
	params.s12 = x(15:16);

end



function params = arrow_restructuring_params_case4(params)

	XD_this = params.XD_this;
	XU_this = params.XU_this;

	assert( XD_this(1) <= XD_this(2) );
	assert( XU_this(1) <= XU_this(2) );

	global riskfree lambda_hat
    
	j = params.j;
	k = params.k;
	l = params.l;
	eps = params.eps;

	% Ax = b
	% x = [g21 (1:2), g22 (3:4), h11 (5:8), h12 (9:12), s11 (13:14), s12 (15:16)]

	A = zeros(16,16);
	b = zeros(16,1);

	XD1_l = XD_this(1) .^ l;
	XD2_l = XD_this(2) .^ l;
	XD2_k = XD_this(2) .^ k;
	XU1_k = XU_this(1) .^ k;
	XU1_j = XU_this(1) .^ j;
	XU2_j = XU_this(2) .^ j;
	
	
	% Boundary condition (a)
	A(1,13:14)  = XD1_l;

	% Boundary condition (b)
	A(2,13:14)  = XD2_l;
	A(2,5:8)    = - XD2_k;
	
	% Boundary condition (c)
	A(3,13:14)  = l .* XD2_l;
	A(3,5:8)    = - k .* XD2_k;
	
	% Boundary condition (d)
	A(4,5:8)    = XU1_k;
	b(4) = 1;
		
	% Boundary condition (e)
	A(5,15:16)  = XD1_l;
	
	% Boundary condition (f)
	A(6,15:16)  = XD2_l;
	A(6,9:12)   = - XD2_k;
	
	% Boundary condition (g)
	A(7,15:16)  = l .* XD2_l;
	A(7,9:12)   = - k .* XD2_k;
	
	% Boundary condition (h)
	A(8,9:12)   = XU1_k;
	
	% Boundary condition (i)
	A(9,5:8)    = eps .* XD2_k;
	
	% Boundary condition (j)
	A(10,5:8)   = eps .* XU1_k;
	A(10,1:2)   = - XU1_j;
	b(10) = lambda_hat(2) / (riskfree(2) + lambda_hat(2));
	
	% Boundary condition (k)
	A(11,5:8)   = eps .* k .* XU1_k;
	A(11,1:2)   = - j .* XU1_j;
	
	% Boundary condition (l)
	A(12,1:2)   = XU2_j;
	b(12) = - lambda_hat(2) / (riskfree(2) + lambda_hat(2));
	
	% Boundary condition (m)
	A(13,9:12)  = eps .* XD2_k;
	
	% Boundary condition (n)
	A(14,9:12)  = eps .* XU1_k;
	A(14,3:4)   = - XU1_j;
	
	% Boundary condition (o)
	A(15,9:12)  = eps .* k .* XU1_k;
	A(15,3:4)   = - j .* XU1_j;
	
	% Boundary condition (p)
	A(16,3:4)   = XU2_j;
	b(16) = 1;

	
	
	% solution
	x = A \ b;
	
	params.g21 = x(1:2);
	params.g22 = x(3:4);
	params.h11 = x(5:8);
	params.h12 = x(9:12);
	params.s11 = x(13:14);
	params.s12 = x(15:16);

end


