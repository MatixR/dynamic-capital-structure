* firm_characteristics

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"

!rm reg_invest_on_Q_profit_lev*.txt



***************************************************************************
* data loading
***************************************************************************


use "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/sprate", clear

gen month = month(datadate)
gen fyear = year(datadate)

keep if month == 12
keep if splticrm != ""

keep gvkey fyear splticrm

gen rating = regexr(splticrm, "[\+\-]", "")

keep if rating == "BBB"

keep gvkey fyear rating
sort gvkey fyear


merge 1:1 gvkey fyear using "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/cstat_ann", keep(match) nogen



drop if fyear == .

duplicates drop gvkey fyear, force

rename fyear year

destring sic, replace

drop if floor(sic / 1000) == 6
drop if floor(sic / 1000) == 9




merge 1:1 gvkey year using "/Users/dioscuroi/Research Data/Stocks/matched with Compustat/firm_characteristics", keep(match) nogen

tsset permno year

drop if prstkc > marcap


foreach var of var dv dvt prstkc sstk {
	replace `var' = 0 if `var' == .
}



***************************************************************************
* generate variables and do filtering
***************************************************************************

gen capital     = ppent + intan
gen Q		    = (book_debt + marcap) / capital
gen leverage    = book_debt / (book_debt + marcap)

summarize Q, detail
summarize leverage, detail







***************************************************************************
* clear temporary files
***************************************************************************

*!rm temp*.dta

