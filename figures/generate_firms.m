function simulated = generate_firms(N, economy)
%
% input:
%   N - number of firms
%   economy - simulated economy
%
% output:
%  (1) earnings and dividends are monthly
%

global tax iota
global rho theta sigma_x_s sigma_x_id alpha m
global X_D X_U capital coupons


T				= economy.T;
states		= economy.states;
shock_sys	= economy.shock_sys;


% simulated firms
productivity	= zeros(T, N);
capital_hist   = zeros(T, N);
coupons_hist	= zeros(T, N);
ebitda			= zeros(T, N);
ebit				= zeros(T, N);
netincome		= zeros(T, N);

stocks			= zeros(T, N);
debts_book		= zeros(T, N);
debts_market	= zeros(T, N);
dividends		= zeros(T, N);

productivity(1,:)	= 1;
capital_hist(1,:) = capital(states(1));
coupons_hist(1,:) = coupons(states(1));
ebitda(1,:)			= capital(states(1))^(alpha) / 12;
ebit(1,:)			= ebitda(1,:) - m * capital(states(1)) / 12;
netincome(1,:)		= (1 - tax) * (ebit(1,:) - coupons_hist(1,:)/12);

S0 = equity_price_at_zero();
B0 = debt_price_at_zero();

stocks(1,:)			= S0(states(1));
debts_book(1,:)	= B0(states(1));
debts_market(1,:)	= B0(states(1));
dividends(1,:)    = netincome(1,:);


% indicators
ind_default = false(T, N);
ind_refinan = false(T, N);

default_boundary = kron(ones(1,N), X_D(states(1),:)');
refinan_boundary = kron(ones(1,N), X_U(states(1),:)');
state_at_last_refinance = zeros(1,N) + states(1);



% iteration for time
for t = 2:T
	
	if mod(t, 500) == 0
		fprintf(1, '%d\n', t);
	elseif mod(t, 10) == 0
		fprintf(1, '.');
	end
	
	
	
	% simulate productivity growth
	shock_id = randn(1,N) / sqrt(12);
	
	growth = theta(states(t))/12 + sigma_x_id*shock_id + sigma_x_s(states(t))*shock_sys(t);
	
	productivity(t,:) = productivity(t-1,:) .* exp(growth);
	capital_hist(t,:) = capital_hist(t-1,:);
	coupons_hist(t,:) = coupons_hist(t-1,:);
	debts_book(t,:)   = debts_book(t-1,:);
	
	
	% handle default
	idx = ( productivity(t,:) < default_boundary(states(t),:) );
	
	no_default = sum(idx);
	
	if no_default > 0
		
		ind_default(t, idx) = true;
		
		% create new firms
		default_boundary(:,idx) = kron(ones(1,no_default), X_D(states(t),:)');
		refinan_boundary(:,idx) = kron(ones(1,no_default), X_U(states(t),:)');

		productivity(t,idx) = 1;
		capital_hist(t,idx) = capital(states(t));
		coupons_hist(t,idx) = coupons(states(t));
		debts_book(t,idx) = B0(states(t));
		
		state_at_last_refinance(idx) = states(t);
		
	end
	
	
	% handle refinancing
	net_debt_issues = zeros(1,N);
	invest_costs    = zeros(1,N);
	
	idx = ( productivity(t,:) > refinan_boundary(states(t),:) );
	
	if any(idx) > 0
		
		ind_refinan(t, idx) = true;
		
		% new boundaries
		crossed = refinan_boundary(states(t),idx);
		
		default_boundary(:,idx) = kron(crossed, X_D(states(t),:)');
		refinan_boundary(:,idx) = kron(crossed, X_U(states(t),:)');
		
		capital_hist(t,idx) = capital_hist(t-1,idx) * X_U(states(t),states(t));
		coupons_hist(t,idx) = coupons_hist(t-1,idx)  * X_U(states(t),states(t));
	
		for i = 1:N
			if ind_refinan(t,i)
				
				last_ref_state = state_at_last_refinance(i);
				
				scale = capital_hist(t,i) / capital(last_ref_state);
				
				temp1 = (1 - iota(states(t))) * X_U(last_ref_state, states(t));
				temp2 = coupons(last_ref_state) / coupons(states(t));
				B0 = debt_price_at_zero();
				
				net_debt_issues(i) = (temp1 - temp2) * B0(states(t)) * (scale / X_U(states(t),states(t)));
				
				temp = investment_cost();
				
				invest_costs(i) = temp(states(t)) * capital_hist(t-1,i);
				
				% incomplete yet
				debts_book(t,i) = B0(states(t)) * scale;
				
			end
		end
		
		state_at_last_refinance(idx) = states(t);
		
	end
	
	
	
	% treat the common stuffs
	ebitda(t,:)		= (productivity(t,:).^(1-alpha)) .* (capital_hist(t,:).^(alpha)) / 12;
	ebit(t,:)		= ebitda(t,:) - m * capital_hist(t,:) / 12;
	netincome(t,:) = (1-tax) * (ebit(t,:) - coupons_hist(t,:)/12);
					
	dividends(t,:) = net_debt_issues - invest_costs + netincome(t,:);
	
	% update stock and bond price
	for i = 1:N
		
		last_ref_state = state_at_last_refinance(i);
		
		scale = capital_hist(t,i) / capital(last_ref_state);
		
		S = equity_price( productivity(t,i) / scale, last_ref_state );
		B = debt_price  ( productivity(t,i) / scale, last_ref_state );
		
		stocks(t,i) = scale * S(states(t));
		debts_market(t,i)  = scale * B(states(t));
		
	end
	
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% put all simulated series into the output variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simulated.alpha			= alpha;
simulated.T					= T;
simulated.N					= N;
simulated.states			= states;
simulated.productivity	= productivity;
simulated.capital_hist	= capital_hist;
simulated.coupons_hist  = coupons_hist;
simulated.ebitda			= ebitda;
simulated.ebit				= ebit;
simulated.netincome		= netincome;
simulated.stocks			= stocks;
simulated.debts_market	= debts_market;
simulated.debts_book		= debts_book;
simulated.dividends		= dividends;
simulated.ind_default	= ind_default;
simulated.ind_refinan	= ind_refinan;





end

