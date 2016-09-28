* freq_recessions

clear
set more off
graph drop _all

local options = "stats(coef tstat) bdec(3) tdec(2)"

cd "/Users/dioscuroi/Dropbox/Research/dynamic capital structure/codes/empirical/"


use "/Users/dioscuroi/Research Data/Macroeconomics/Business Cycles/Business_Cycles"

gen year = year(dofm(date))

bysort year: egen rec_sum = sum(recession)

keep year rec_sum

duplicates drop

rename rec_sum recession

replace recession = 1 if recession > 0



summarize recession
summarize recession if year >= 1929
summarize recession if year >= 1945
summarize recession if year >= 1970
summarize recession if year >= 1980


