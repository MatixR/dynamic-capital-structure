* earnings_growth_rate

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"

!rm earnings_growth_rate*.txt



***************************************************************************
* data loading
***************************************************************************

/*
use "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/cstat_ann", clear

drop if fyear == .
drop if at == .
drop if at == 0

duplicates drop gvkey fyear, force

rename fyear year

destring sic,   replace
destring gvkey, replace

drop if floor(sic / 1000) == 6
drop if floor(sic / 1000) == 9

keep gvkey year at ebitda ebit

drop if ebit == .
drop if ebitda == .
drop if ebitda < 0


tsset gvkey year

save temp_ebitda, replace
*/


/*
use "/Users/dioscuroi/Research Data/Macroeconomics/Business Cycles/Business_Cycles"

merge 1:1 date using "/Users/dioscuroi/Research Data/Macroeconomics/Inflation/Consumer Price Index", keep(match) nogen

keep date recession qe CPIAUCNS


gen year = year(dofm(date))

bysort year: egen rec_sum = sum(recession)
bysort year: egen cpi_avg = mean(CPIAUCNS)

keep year rec_sum cpi_avg

duplicates drop

rename cpi_avg cpi
rename rec_sum recession

replace recession = 1 if recession > 0

save temp_recessions, replace
*/



use "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/sprate", clear

drop if splticrm == ""

keep gvkey datadate splticrm

destring gvkey, replace

rename splticrm rating

merge m:1 rating using "/Users/dioscuroi/Research Data/Corporate Finance/Compustat/spcodelist", nogen keep(match)

gen year = year(datadate)

bysort gvkey year: egen rate_avg = mean(code)

keep gvkey year rate_avg

duplicates drop



merge 1:1 gvkey year using temp_ebitda, keep(match using) nogen
merge m:1 year using temp_recessions, keep(match) nogen

tsset gvkey year

* convert the amounts to 2000 dollars
replace at 		= at 	 / cpi * 172.2
replace ebitda 	= ebitda / cpi * 172.2
replace ebit 	= ebit 	 / cpi * 172.2

drop if at < 10
drop if ebitda < 10
drop if ebit < 1


gen ebitda_gr 	= ln(ebitda / L.ebitda)
gen ebit_gr		= ln(ebit   / L.ebit)

*_pctile ebitda_gr, p(1 99)
*
*replace ebitda_gr = . if ebitda_gr < r(r1)
*replace ebitda_gr = . if ebitda_gr > r(r2)


_pctile ebit_gr, p(5 95)

replace ebit_gr = . if ebit_gr < r(r1)
replace ebit_gr = . if ebit_gr > r(r2)


save temp_merged, replace





********************************************************
*         Individual Firms                             *
********************************************************

foreach cond in ///
	"(L.rate_avg != .) & (L.rate_avg >= 10) & (L.rate_avg <= 12)" {

	disp ""
	disp ""
	disp "********************************************************"
	disp " Condition: `cond'"
	disp "********************************************************"

	use temp_merged, clear
	
	keep if `cond'

*	summarize ebitda_gr, detail
*	summarize ebitda_gr if (recession == 0), detail
*	summarize ebitda_gr if (recession == 1), detail

	summarize ebit_gr, detail
	summarize ebit_gr if (recession == 0), detail
	summarize ebit_gr if (recession == 1), detail
}





********************************************************
*         Average Firms                                *
********************************************************


foreach cond in ///
	"(L.rate_avg != .) & (L.rate_avg >= 10) & (L.rate_avg <= 12)" {

	disp ""
	disp ""
	disp "********************************************************"
	disp " Condition: `cond'"
	disp "********************************************************"

	use temp_merged, clear

	keep if `cond'

*	bysort year: egen ebitda_gr_avg = mean(ebitda_gr)
	bysort year: egen ebit_gr_avg   = mean(ebit_gr)

	keep year ebit_gr_avg recession
	duplicates drop

*	summarize ebitda_gr_avg, detail
*	summarize ebitda_gr_avg if (recession == 0), detail
*	summarize ebitda_gr_avg if (recession == 1), detail
	
	summarize ebit_gr_avg, detail
	summarize ebit_gr_avg if (recession == 0), detail
	summarize ebit_gr_avg if (recession == 1), detail
}










***************************************************************************
* clear temporary files
***************************************************************************

*!rm temp*.dta

