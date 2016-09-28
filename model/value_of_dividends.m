function Div = value_of_dividends(X, state0)
%
%	Reference: Eq (37)
%
% input  : X_t, coupon at nu_0, q_D, q_U
% output : Div_{nu_t} : 2x1 vector
%


global tax rate_perpetuity
global X_D X_U coupons

q_D = arrow_default_price(X, state0);
q_U = arrow_restructuring_price(X, state0);

At = unlevered_assets(X, state0);
AD = unlevered_assets(X_D(state0,:)', state0);
AU = unlevered_assets(X_U(state0,:)', state0);

perpetuity = (1 - tax) * coupons(state0) ./ rate_perpetuity;

temp1 = At - perpetuity;
temp2 = q_D * (perpetuity - AD);
temp3 = q_U * (perpetuity - AU);

Div = temp1 + temp2 + temp3;



