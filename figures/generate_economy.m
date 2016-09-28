function economy = generate_economy(T, state0)
%
% input:
%   T - number of periods in months
%   state0 - the initial state at time 0
%


global lambda rho

states = zeros(T, 1);
states(1) = state0;

shock_con = randn(T,1)/sqrt(12);
shock_sys = rho*shock_con + sqrt(1-rho^2)*randn(T,1)/sqrt(12);


% iteration for time
for t = 2:T
	
	% simulate regime switch
	prob_switch = 1 - exp(-lambda(states(t-1))/12);
	
	if rand() < prob_switch
		states(t) = 3 - states(t-1);
	else
		states(t) = states(t-1);
	end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% put all simulated series into the output variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

economy.T = T;
economy.states = states;
economy.shock_con = shock_con;
economy.shock_sys = shock_sys;


end

