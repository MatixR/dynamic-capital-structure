* investment_per_debt_issue

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"

!rm investment_per_debt_issue*.txt



***************************************************************************
* data loading
***************************************************************************

use "/Users/dioscuroi/Dropbox/Research/[Research Data]/Corporate Finance/Compustat/cstat_ann", clear

drop if fyear == .

duplicates drop gvkey fyear, force

rename fyear year

destring sic, replace

drop if floor(sic / 1000) == 6
drop if floor(sic / 1000) == 9



merge 1:1 gvkey year using "/Users/dioscuroi/Dropbox/Research/[Research Data]/Stocks/matched with Compustat/firm_characteristics", keep(match) nogen

tsset permno year

drop if prstkc > marcap


foreach var of var dv dvt prstkc sstk {
	replace `var' = 0 if `var' == .
}




***************************************************************************
* Scatter plot of new investments relative to debt issuance
***************************************************************************

gen debt_issue = (dltt - L.dltt + dlc - L.dlc) / L.mkt_asset

gen chg_ppent  = (ppent - L.ppent) / L.mkt_asset
gen chg_intan  = (intan - L.intan) / L.mkt_asset
gen chg_cash   = (che   - L.che) / L.mkt_asset
gen equity_payout = (dvt + prstkc - sstk) / L.mkt_asset

gen book_debt_new = dltt + dlc
gen leverage_new  = book_debt_new / (book_debt_new + marcap)
gen Q_new		  = (book_debt_new + marcap) / (ppent + intan)


keep if debt_issue != .
keep if debt_issue > .03

_pctile debt_issue, p(99.9)
drop if debt_issue > r(r1)

_pctile Q_new, p(99)
replace Q_new = . if Q_new > r(r1)



keep  permno gvkey year debt_issue chg_ppent chg_intan chg_cash equity_payout leverage_new Q_new
order permno gvkey year

tsset permno year

corr debt_issue chg_* equity_payout


foreach var of var chg_ppent chg_intan chg_cash equity_payout {

	reg `var' debt_issue
	outreg2 using "investment_per_debt_issue.txt", `options'
}

*twoway scatter chg_ppent  debt_issue, name(scatter_ppent)
*twoway scatter chg_intan  debt_issue, name(scatter_intan)
*twoway scatter chg_cash   debt_issue, name(scatter_cash)
*twoway scatter equity_payout debt_issue, name(scatter_payout)

outsheet using "investment_per_debt_issue_scatter.csv", replace




***************************************************************************
* ipdi (investment per debt issuance) portfolio formation
***************************************************************************

gen investment = chg_ppent + chg_intan
gen ipdi = investment / debt_issue

_pctile ipdi, p(0.5 99.5)

drop if ipdi < r(r1)
drop if ipdi > r(r2)

keep  permno gvkey year ipdi debt_issue investment equity_payout chg_cash leverage_new Q_new
order permno gvkey year ipdi debt_issue investment equity_payout chg_cash leverage_new Q_new

tsset permno year

summarize ipdi, detail

_pctile ipdi, p(30 70)

gen ipdi_pf = .

replace ipdi_pf = 1 if ipdi <= r(r1)
replace ipdi_pf = 2 if ipdi > r(r1) & ipdi <= r(r2)
replace ipdi_pf = 3 if ipdi > r(r2)

save "investment_per_debt_issue_portfolio", replace




***************************************************************************
* Plot the distribution of ipdi
***************************************************************************

keep year ipdi 

bysort year: egen ipdi_p25 = pctile(ipdi), p(25)
bysort year: egen ipdi_p50 = pctile(ipdi), p(50)
bysort year: egen ipdi_p75 = pctile(ipdi), p(75)

keep year ipdi_p*

duplicates drop

tsset year

line ipdi_p* year, name(ipdi_ptiles)

outsheet using "investment_per_debt_issue_ipdi_ptiles.csv", replace






***************************************************************************
* clear temporary files
***************************************************************************

!rm temp*.dta

