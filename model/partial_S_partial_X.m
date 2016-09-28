function partial_S = partial_S_partial_X(X, state0)

	global tax rate_asset rate_perpetuity alpha
	global X_D X_U coupons capital

	partial_qu = partial_qU_partial_X(X, state0);
	partial_qd = partial_qD_partial_X(X, state0);

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% partial Div / partial X
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	perpetuity = (1 - tax) * coupons(state0) ./ rate_perpetuity;
	
	AD = unlevered_assets(X_D(state0,:)', state0);
	AU = unlevered_assets(X_U(state0,:)', state0);
	
	loss_at_default = perpetuity - AD;
	loss_at_restruc = perpetuity - AU;

	partial_A = (1 - tax) * capital(state0)^(alpha) * (1-alpha) * X^(-alpha) ./ rate_asset;
	
	partial_Div = partial_A + partial_qd * loss_at_default + partial_qu * loss_at_restruc;
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% partial S / partial X
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	E = equity_before_restructure();
	
	partial_S = partial_Div + partial_qu * E(state0,:)';

end


