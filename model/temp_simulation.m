clc;
clear;
clear global;
clear gcf;

dbstop if error;
dbstop if warning;

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_scenario(3);

% random number generator seed
rng(1);

% Simulate sample firms
T = 12 * 1000;
N = 100;

simulated = generate_sample(T, N);

earnings_growth = log( simulated.earnings(2:end,:) ./ simulated.earnings(1:end-1,:) );
earnings_growth = [zeros(1,N) ; earnings_growth];

earnings_growth(simulated.ind_default) = nan;


idx_state1 = ( simulated.states == 1 );

growth_state1 = earnings_growth(idx_state1,:);
growth_state2 = earnings_growth(~idx_state1,:);

mean( nanmean(earnings_growth,1) ) * 12
mean( nanmean(growth_state1,1) ) * 12
mean( nanmean(growth_state2,1) ) * 12

toc




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % dynamic case example
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% tic
% 
% for id = 2:3
% 	
% 	dynamic_load_scenario(id);
% 
% 	fprintf(1, '* Scenario ID: %d\n', id);
% 
% 	coupons
% 	X_D
% 	X_U
% 
% 	% Derive equity risk premium and credit spread
% 	RP = dynamic_equity_risk_premium();
% 	CS = dynamic_debt_credit_spread();
% 	
% 	RP
% 	CS
% 
% 
% 	% compute operational leverage
% 	leverage = simulated.coupon_history ./ simulated.earnings;
% 	
% 	% index for good and bad states
% 	idx_bad  = find(simulated.states == 1);
% 	idx_good = find(simulated.states == 2);
% 	
% 	fprintf(1, 'leverage        : %.4f/%.4f/%.4f\n', ...
% 		mean(nanmean( leverage )), ...
% 		mean(nanmean( leverage(idx_bad,:) )), ...
% 		mean(nanmean( leverage(idx_good,:) )) );
% 
% 	fprintf(1, '# defaults      : %d/%d/%d\n', ...
% 		sum(sum( simulated.ind_default )), ...
% 		sum(sum( simulated.ind_default(idx_bad,:) )), ...
% 		sum(sum( simulated.ind_default(idx_good,:) )) );
% 
% 	fprintf(1, 'avg returns     : %.4f/%.4f/%.4f\n', ...
% 		mean(nanmean( simulated.stock_returns )), ...
% 		mean(nanmean( simulated.stock_returns(idx_bad,:) )), ...
% 		mean(nanmean( simulated.stock_returns(idx_good,:) )) );
% 	
% 	fprintf(1, 'stdev of returns: %.4f/%.4f/%.4f\n', ...
% 		mean(nanstd( simulated.stock_returns )), ...
% 		mean(nanstd( simulated.stock_returns(idx_bad,:) )), ...
% 		mean(nanstd( simulated.stock_returns(idx_good,:) )) );
% 	
% 	fprintf(1, '\n\n\n');
% 	
% end
% 
% 
% 
% 
% % sorted_returns = sort(stock_returns);
% % sorted_returns(1:3,:)
% % sorted_returns(end-2:end,:)
% % 
% % idx = 19;
% % target = [ earnings(2:end,idx) stocks(2:end,idx) dividends(2:end,idx) stock_returns(:,idx) ];
% % find(target(:,4) < -100)




