%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fig_character_within_cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
clear global;
clear gcf;

dbstop if error;
dbstop if warning;

addpath ../model

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global alpha m
global X_D X_U capital coupons tax

scenarios = [3 1 14];
no_scenarios = length(scenarios);

x_domain		 = (0:.01:2.2)';
x_domain_len = length(x_domain);

outputs_logB		= nan(x_domain_len, no_scenarios + 1);
outputs_logB(:,1) = x_domain;

outputs_logS		= outputs_logB;
outputs_growth		= outputs_logB;
outputs_Q			= outputs_logB;
outputs_lever		= outputs_logB;
outputs_profit		= outputs_logB;


for i = 1:no_scenarios
	
	load_scenario( scenarios(i) );
	
	firmvalue_hypothetical = nan(x_domain_len, 3);
	
	for x_id = (1:x_domain_len)
		
		x = x_domain(x_id);
		
		if (x <= X_D(2,2)) || (x >= X_U(2,2))
			continue;
		end
		
		S = equity_price(x, 2);
		B = debt_price(x, 2);
		
		firm_value = S(2) + B(2);
		assert( firm_value >= 0 );
		
		if firm_value == 0
			continue;
		end
		
		A = unlevered_assets(x, 2);
		earnings = (x^(1-alpha)) * (capital(2)^(alpha)) - m * capital(2);
		netincome = (1 - tax) * (earnings - coupons(2));
		
		outputs_logB(x_id,i+1)		= log(B(2));
		outputs_logS(x_id,i+1)		= log(S(2));
		outputs_Q(x_id,i+1)		= firm_value / capital(2);
		outputs_lever(x_id,i+1)	= B(2) / firm_value;
		outputs_profit(x_id,i+1)= netincome / capital(2);
		
		firmvalue_hypothetical(x_id, 1) = firm_value;
		
	end
	
	
	X_U(1,:) = [1000 1000];
	renew_q_params();
	
	for x_id = (1:x_domain_len)
		
		x = x_domain(x_id);
		
		if (x <= X_D(2,2)) || (x >= X_U(2,2))
			continue;
		end
		
		S = equity_price(x, 2);
		B = debt_price(x, 2);
		
		firmvalue_hypothetical(x_id,2) = S(2) + B(2);
	end
	
	
	outputs_growth(:,i+1) = ( firmvalue_hypothetical(:,1) - firmvalue_hypothetical(:,2)) ./ firmvalue_hypothetical(:,1);
	
end

dlmwrite('fig_character_within_cycle_logB.csv',		outputs_logB, 'delimiter', '\t');
dlmwrite('fig_character_within_cycle_logS.csv',		outputs_logS, 'delimiter', '\t');
dlmwrite('fig_character_within_cycle_growth.csv',	outputs_growth, 'delimiter', '\t');
dlmwrite('fig_character_within_cycle_Q.csv',			outputs_Q,		'delimiter', '\t');
dlmwrite('fig_character_within_cycle_lever.csv',	outputs_lever, 'delimiter', '\t');
dlmwrite('fig_character_within_cycle_profit.csv',	outputs_profit, 'delimiter', '\t');




