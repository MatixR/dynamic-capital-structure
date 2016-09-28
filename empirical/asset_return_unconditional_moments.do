* stock_market_exrets

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"



use "/Users/dioscuroi/Research Data/Stocks/CRSP stock returns/CRSP Stock Market Indexes", clear

gen datem = mofd(date)

format %tm datem

keep  datem vwretd ewretd
order datem

rename datem date


merge 1:1 date using "/Users/dioscuroi/Research Data/Stocks/Fama_French/ff3factors_monthly.dta", nogen keep(match)

replace vwretd = vwretd * 100
replace ewretd = ewretd * 100

gen vw_exret = vwretd - rf
gen ew_exret = ewretd - rf

summarize



foreach var in "value" "profitability" "investment" {

	use "/Users/dioscuroi/Research Data/Stocks/Fama_French/portfolio_`var'.dta", clear

	gen `var' = hi30 - lo30

	summarize `var'
}
