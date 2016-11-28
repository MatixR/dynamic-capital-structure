function load_scenario(id)

	global alpha m theta sigma_x_s sigma_x_id tax recovery iota
	global X_D X_U capital coupons 
	global scenario_id scenario_stack

	load_parameters();
	
	X_D = zeros(2,2);
	X_U = zeros(2,2);
	capital = zeros(2,1);

	scenario_stack = dlmread('scenario_stack.csv', ',', 1, 0);
	
	scenario_id = id;
	
	alpha			= scenario_stack(id,2);
   m				= scenario_stack(id,3);
	theta			= scenario_stack(id,4:5)';
	sigma_x_s	= scenario_stack(id,6:7)';
	sigma_x_id	= scenario_stack(id,8);
	tax			= scenario_stack(id,9);
	recovery		= scenario_stack(id,10:11)';
	iota			= scenario_stack(id,12:13)';
	
	X_D(1,:)		= scenario_stack(id,14:15);
	X_U(1,:)		= scenario_stack(id,16:17);
	capital(1)	= scenario_stack(id,18);
	coupons		= scenario_stack(id,19:20)';
	
	assert( alpha <= 1 );
	assert( alpha >= 0 );

	renew_q_params();
		
end
