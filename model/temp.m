% temp

clc
% clf
clear
clear global
% clear gcf

dbstop if error
dbstop if warning

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_scenario(1);

find_default_boundary();


X = (0:0.01:0.2)';

out_debt_price   = zeros( length(X), 2 );
out_equity_price = zeros( length(X), 2 );

for i = 1:length(X)

	out_debt_price(i,:)   = debt_price(X(i), 1)';
	out_equity_price(i,:) = equity_price(X(i), 1)';
	
end

subplot(2,1,1), plot(X, out_debt_price);
subplot(2,1,2), plot(X, out_equity_price);

toc

