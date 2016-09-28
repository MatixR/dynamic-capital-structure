%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% firm_value_without_options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
clear global;
clear gcf;

% dbstop if error;
% dbstop if warning;

addpath ../extension

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global alpha m
global X_D X_U capital coupons tax

load_scenario(1);

x_domain		 = (0:.01:2.2)';
x_domain_len = length(x_domain);

firm_values = nan(x_domain_len, 4);

% Benchmark: firm value with both options
for i = 1:x_domain_len
	
	x = x_domain(i);

	if (x <= X_D(2,2)) || (x >= X_U(2,2))
		continue;
	end

	S = equity_price(x, 2);
	B = debt_price(x, 2);
	
	firm_values(i,1) = S(2) + B(2);
	
end


% Case 2: firm value without growth options
X_U(1,:) = 1e4;

renew_q_params();

for i = 1:x_domain_len
	
	x = x_domain(i);

	if (x <= X_D(2,2)) || (x >= X_U(2,2))
		continue;
	end

	S = equity_price(x, 2);
	B = debt_price(x, 2);
	
	firm_values(i,2) = S(2) + B(2);
	
end


% Case 3: firm value without default options
load_scenario(1);

X_D(1,:) = 1e-4;

renew_q_params();

for i = 1:x_domain_len
	
	x = x_domain(i);

	if (x <= X_D(2,2)) || (x >= X_U(2,2))
		continue;
	end

	S = equity_price(x, 2);
	B = debt_price(x, 2);
	
	firm_values(i,3) = S(2) + B(2);
	
end


% Case 4: firm value without bothoptions
load_scenario(1);

X_D(1,:) = 1e-4;
X_U(1,:) = 1e4;

renew_q_params();

for i = 1:x_domain_len
	
	x = x_domain(i);

	if (x <= X_D(2,2)) || (x >= X_U(2,2))
		continue;
	end

	S = equity_price(x, 2);
	B = debt_price(x, 2);
	
	firm_values(i,4) = S(2) + B(2);
	
end

plot(x_domain, firm_values);


dlmwrite('firm_value_without_options.csv', [x_domain firm_values], 'delimiter', '\t');


