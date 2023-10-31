cls
**==========================================
** Program Name: Regression of satellite data (daytime & NTL) and sectoral GDP (city)
** Author: Yilin Chen
** Date: 2023-09-30
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_longpanel.dta

* Data files created as intermediate product:
*===========================================
*cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

*** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

*** 2. Import county level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_longpanel.dta", clear

gen lg101214 = ln(0.01 + v21 + v23 + v25)
label variable lg101214 "Log (croplands)"

summarize
describe

*** 3. Run regressions
*Set panel	
xtset city_id year
xi i.year
xi i.city_id
set matsize 11000

** 3.1 NTL and sectoral GDP
*Pooled OLS
reg city_lggdp lg_totalsol
outreg2 using "../results/result1/tab03-1.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_nonagri lg_totalsol
outreg2 using "../results/result1/tab03-1.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ind lg_totalsol
outreg2 using "../results/result1/tab03-1.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ser lg_totalsol
outreg2 using "../results/result1/tab03-1.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_agri lg_totalsol
outreg2 using "../results/result1/tab03-1.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

*Between estimator
xtreg city_lggdp lg_totalsol,be
outreg2 using "../results/result1/tab03-2.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) dec(3) label

xtreg lg_nonagri lg_totalsol,be
outreg2 using "../results/result1/tab03-2.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) dec(3) label

xtreg lg_ind lg_totalsol,be
outreg2 using "../results/result1/tab03-2.tex", append keep(lg_totalsol) ctitle(Log (industry)) dec(3) label

xtreg lg_ser lg_totalsol,be
outreg2 using "../results/result1/tab03-2.tex", append keep(lg_totalsol) ctitle(Log (services)) dec(3) label

xtreg lg_agri lg_totalsol,be
outreg2 using "../results/result1/tab03-2.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) dec(3) label

*TWFE
xtreg city_lggdp lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab03-3.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_nonagri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab03-3.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ind lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab03-3.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ser lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab03-3.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_agri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab03-3.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

**3.2 landcover/NPP and sectoral GDP
*TWFE-landcover area
xtreg lg_agri lg101214 i.year,fe robust
outreg2 using "../results/result1/tab03-4.tex", replace keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
*TWFE-NPP
xtreg lg_agri lg_ruralnpp i.year,fe robust
outreg2 using "../results/result1/tab03-4.tex", append keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

** 3.3 NTL_mean and GDP per capita
xtreg city_lggdppc lg_totalmol i.year,fe robust
outreg2 using "../results/result1/tab04-1.tex", replace keep(lg_totalmol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

*** 4. Predict GDP

**Non-agriculture GDP
xtreg lg_nonagri lg_totalsol i.year,fe robust
predict y_predicted1, xb
rename y_predicted1 lg_nonagri_predicted
*Drop useless columns 
foreach var of varlist _Icity_id_* {
    drop `var'
}

**Agriculture GDP
xtreg lg_agri lg_ruralnpp i.year,fe robust
predict y_predicted2, xb
rename  y_predicted2 lg_agri_predicted

**GDP per capita
xtreg city_lggdppc lg_totalmol i.year,fe robust
predict y_predicted3, xb
rename y_predicted3 lg_gdppc_predicted

gen lg_totalgdp_predicted= ln(exp(lg_agri_predicted) + exp(lg_nonagri_predicted))

label variable lg_nonagri_predicted "Predicted non-agriculture GDP (log) using NTL"
label variable lg_agri_predicted "Predicted agriculture GDP (log) using NPP"
label variable lg_totalgdp_predicted "Predicted total GDP (log) using NTL and NPP"
label variable lg_gdppc_predicted "Predicted per capita GDP (log) using NTL"

summarize
describe

*** 5. Save dta file
save "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data/city_predicted.dta", replace




