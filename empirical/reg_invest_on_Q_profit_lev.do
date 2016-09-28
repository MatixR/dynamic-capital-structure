* reg_invest_on_Q_profit_lev

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"

!rm reg_invest_on_Q_profit_lev*.txt



***************************************************************************
* data loading
***************************************************************************


/*
use "/Users/dioscuroi/Dropbox/Research/[Research Data]/Corporate Finance/Compustat/sprate", clear

gen month = month(datadate)
gen fyear = year(datadate)

keep if month == 12
keep if splticrm != ""

keep gvkey fyear splticrm

gen rating = regexr(splticrm, "[\+\-]", "")

keep if rating == "BBB"

keep gvkey fyear rating
sort gvkey fyear


merge 1:1 gvkey fyear using "/Users/dioscuroi/Dropbox/Research/[Research Data]/Corporate Finance/Compustat/cstat_ann", keep(match) nogen
*/


use "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/cstat_ann", clear

drop if fyear == .

duplicates drop gvkey fyear, force

rename fyear year

destring sic, replace

drop if floor(sic / 1000) == 6
drop if floor(sic / 1000) == 9




merge 1:1 gvkey year using "/Users/dioscuroi/Research Data/Stocks/matched with Compustat/firm_characteristics", keep(match) nogen

tsset permno year

drop if prstkc > marcap

destring gvkey, replace

foreach var of var dv dvt prstkc sstk {
	replace `var' = 0 if `var' == .
}




***************************************************************************
* generate variables and do filtering
***************************************************************************

gen capital = ppent + intan
gen net_invest = (capital - L.capital) / L.capital


drop if at < 10
drop if capital < 0.1 * at

gen debts    = dlc + dltt
gen leverage = debts / (debts + marcap)
gen Q        = (debts + marcap) / at
gen profit   = ni / at

*gen Q		  = (book_debt + marcap) / capital
*gen profit    = ni / capital
*gen leverage  = book_debt / (book_debt + marcap)

*summarize net_invest, detail
*summarize Q, detail


_pctile Q, p(99)
drop if Q > r(r1)

foreach var of varlist net_invest profit leverage {
	_pctile `var', p(1 99)
	replace `var' = . if `var' < r(r1)
	replace `var' = . if `var' > r(r2)
}

drop if net_invest == .
drop if profit == .
drop if leverage == .

keep  permno gvkey year net_invest Q profit leverage
order permno gvkey year

tsset permno year

summarize



***************************************************************************
* regress net investments
***************************************************************************

reg F.net_invest Q
outreg2 using "reg_invest_on_Q_profit_lev.txt", `options'

reg F.net_invest Q profit
outreg2 using "reg_invest_on_Q_profit_lev.txt", `options'

reg F.net_invest Q leverage
outreg2 using "reg_invest_on_Q_profit_lev.txt", `options'

reg F.net_invest Q profit leverage
outreg2 using "reg_invest_on_Q_profit_lev.txt", `options'





***************************************************************************
* clear temporary files
***************************************************************************

!rm temp*.dta

