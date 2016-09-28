% default_refinan_prob_simulation_summary

clear;
clf;

scenarios = (1:28);

no_scenarios = length(scenarios);
no_machiens = 20;


total_outputs = [];

for machine = 1:no_machiens
	
	filename = sprintf('simulation_outputs/default_refinan_prob_simulation%03d.csv', machine);
	
	this_output = dlmread(filename, '\t');
	
	total_outputs = [total_outputs; this_output];

end


fprintf(1, '\n');
fprintf(1, '* Total number of simulations: %d\n', size(total_outputs,1));


default_prob = median(total_outputs(:,1:no_scenarios), 1);
refinan_prob = median(total_outputs(:,(no_scenarios+1):end), 1);

index_alpha = [ (12:-1:1) (13:18) ];
index_m     = [ (23:-1:19) 1 (24:28) ];

results_alpha = [default_prob(index_alpha)'	refinan_prob(index_alpha)'];
results_m     = [default_prob(index_m)'		refinan_prob(index_m)'];

% smooth the curves
alpha = [ (0.1:0.05:0.6) 0.627 (0.65:0.05:0.9) ]';
m     = (0:0.02:0.2)';

f_alpha1 = fit( alpha, results_alpha(:,1), 'poly4' );
f_alpha2 = fit( alpha, results_alpha(:,2), 'poly6' );

f_m1 = fit( m, results_m(:,1), 'poly3' );
f_m2 = fit( m, results_m(:,2), 'poly3' );

subplot(2,2,1), plot( alpha, [results_alpha(:,1) f_alpha1(alpha)] );
subplot(2,2,2), plot( alpha, [results_alpha(:,2) f_alpha2(alpha)] );
subplot(2,2,3), plot( m, [results_m(:,1) f_m1(m)] );
subplot(2,2,4), plot( m, [results_m(:,2) f_m2(m)] );

% subplot(2,2,1), plot( alpha, f_alpha1(alpha) );
% subplot(2,2,2), plot( alpha, f_alpha2(alpha) );
% subplot(2,2,3), plot( m, f_m1(m) );
% subplot(2,2,4), plot( m, f_m2(m) );


fitted_alpha = [f_alpha1(alpha) f_alpha2(alpha)];
fitted_m		 = [f_m1(m) f_m2(m)];

dlmwrite('default_refinan_prob_simulation_summary_alpha.csv',	fitted_alpha, 'delimiter', '\t');
dlmwrite('default_refinan_prob_simulation_summary_m.csv',		fitted_m,	  'delimiter', '\t');

