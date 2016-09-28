function cost = investment_cost()

	global kappa X_U
	
	cost = (diag(X_U) - 1) .* (1 + kappa/2 * (diag(X_U) - 1));

end