function A = unlevered_assets(X, state0)
%
%	Reference: Eq (12)
%

global tax rate_asset rate_perpetuity
global alpha m capital

temp1 = (X.^(1-alpha)) * (capital(state0)^(alpha)) ./ rate_asset;
temp2 = m * capital(state0) ./ rate_perpetuity;

A = (1 - tax) * (temp1 - temp2);

