% draw_arrow_securities

clc
clf
clear
clear global
%clear gcf

dbstop if error
dbstop if warning

tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global X_D X_U

load_scenario(8);

X_D(1,1) = 0.1;
X_D(1,2) = 0.3;
X_U(1,1) = 1.4;
X_U(1,2) = 1.7;

renew_q_params();

XU_max = max(X_U(:));
X_range = (0:0.01:XU_max)';

len = length(X_range);

qd1_list = zeros(len, 4);
qd2_list = zeros(len, 4);
qu1_list = zeros(len, 4);
qu2_list = zeros(len, 4);

for i = 1:len

	x = X_range(i);
	
	q_D1 = arrow_default_price(x, 1);
	q_D2 = arrow_default_price(x, 2);

	q_U1 = arrow_restructuring_price(x, 1);
	q_U2 = arrow_restructuring_price(x, 2);
	
	qd1_list(i,:) = q_D1(:)';
	qd2_list(i,:) = q_D2(:)';
	qu1_list(i,:) = q_U1(:)';
	qu2_list(i,:) = q_U2(:)';
	
end

subplot(2,2,1), line(X_range, qd1_list);
legend('11', '21', '12', '22');

subplot(2,2,2), line(X_range, qd2_list);
legend('11', '21', '12', '22');

subplot(2,2,3), line(X_range, qu1_list);
legend('11', '21', '12', '22');

subplot(2,2,4), line(X_range, qu2_list);
legend('11', '21', '12', '22');



toc

