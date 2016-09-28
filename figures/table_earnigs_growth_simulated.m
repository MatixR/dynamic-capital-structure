function table_earnigs_growth_simulated(id)

   if nargin < 1
		id = 5;
	end
	 
	addpath ../extension
	
	rng(1);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% main body
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global alpha m

	no_years = 100;

	T = no_years * 12;
	N = 100;


	% Column 1-3 : earnings growth rate - mean
	% Column 4-6 : earnings growth rate - stdev
	% Column 7   : distance of mean and stdev from empirical counterparts
	
	outputs = zeros(3, 7);  % individual firms / average of firms / other characteristics

	empirical_ind = [-0.0401	0.0782	0.0361	0.2623	0.2407	0.2550];
	empirical_avg = [-0.0401	0.0782	0.0361	0.1334	0.0834	0.1184];


	load_parameters();
	load_scenario(id);
	
% 	optimization(id);

	fprintf(1, '******************************************\n');
	fprintf(1, '* Scenario ID: %d, alpha: %.3f, m: %.2f\n', id, alpha, m);
	fprintf(1, '******************************************\n');

	economy = generate_economy(T, 2);

	simulated = generate_firms(N, economy);

	fprintf(1, '\n');
	
	recessions = (economy.states == 1);
	
	earnings_growth = zeros(T, N); 
	earnings_growth(1,:) = nan;
	earnings_growth(2:end,:) = log( simulated.ebit(2:end,:) ./ simulated.ebit(1:end-1,:) );
	earnings_growth(simulated.ind_default) = nan;
	
	growth_state1 = earnings_growth(recessions,:);
	growth_state2 = earnings_growth(~recessions,:);

	outputs(1,1) = nanmean(growth_state1(:));
	outputs(1,2) = nanmean(growth_state2(:));
	outputs(1,3) = nanmean(earnings_growth(:));
	outputs(1,4) = nanstd(growth_state1(:));
	outputs(1,5) = nanstd(growth_state2(:));
	outputs(1,6) = nanstd(earnings_growth(:));
	
	outputs(1,1:3) = outputs(1,1:3) * 12;
	outputs(1,4:6) = outputs(1,4:6) * sqrt(12);

	dist = outputs(1,1:6) - empirical_ind(1:6);

	outputs(1,7) = sum(abs(dist));

	outputs(1,:)



	avg_earnings_growth = nanmean(earnings_growth, 2);

	growth_state1 = avg_earnings_growth(recessions,:);
	growth_state2 = avg_earnings_growth(~recessions,:);

	outputs(2,1) = nanmean(growth_state1);
	outputs(2,2) = nanmean(growth_state2);
	outputs(2,3) = nanmean(avg_earnings_growth);
	outputs(2,4) = nanstd(growth_state1);
	outputs(2,5) = nanstd(growth_state2);
	outputs(2,6) = nanstd(avg_earnings_growth);

	outputs(2,1:3) = outputs(2,1:3) * 12;
	outputs(2,4:6) = outputs(2,4:6) * sqrt(12);
	
	dist = outputs(2,1:6) - empirical_avg(1:6);

	outputs(2,7) = sum(abs(dist));

	outputs(2,:)




	Q = (simulated.bonds + simulated.stocks) ./ simulated.capital_hist;

	leverage = simulated.bonds ./ (simulated.bonds + simulated.stocks);

	default_prob_1month = sum(simulated.ind_default(:)) / (T * N);
	default_prob_10yrs  = 1 - (1 - default_prob_1month)^120;


	outputs(3,1:3) = prctile(Q(:), [25 50 75]);
	outputs(3,4:6) = prctile(leverage(:), [25 50 75]);
	outputs(3,7)   = default_prob_10yrs;

	outputs(3,:)

	
	filename = sprintf('table_earnigs_growth_simulated%03d.csv', id);
	
	dlmwrite(filename, outputs, 'delimiter', '\t');

end



