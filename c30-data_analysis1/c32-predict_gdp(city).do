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
cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

*** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

*** 2. Import county level dataset
use "city_longpanel.dta", clear

gen lg101214 = ln(0.01 + v24 + v26 + v28)
label variable lg101214 "Log (croplands)"

*Drop Hongkong, Macau, Taiwan and Sansha city in South China Sea (no population)
drop if province_id == 810000 | province_id == 820000 | province_id == 710000
drop if city_id == 460300

summarize
describe

*** 3. Run regressions
*Set panel	
egen new_city_id = group(city_id)

xtset new_city_id year
xi i.year
xi i.new_city_id
set matsize 11000

** 3.1 NTL and sectoral GDP
*Pooled OLS
reg city_lggdp lg_totalsol
outreg2 using "../results/result1/tab02-1.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_nonagri lg_totalsol
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ind lg_totalsol
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ser lg_totalsol
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_agri lg_totalsol
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

*Between estimator
xtreg city_lggdp lg_totalsol,be
outreg2 using "../results/result1/tab02-2.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) dec(3) label

xtreg lg_nonagri lg_totalsol,be
outreg2 using "../results/result1/tab02-2.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) dec(3) label

xtreg lg_ind lg_totalsol,be
outreg2 using "../results/result1/tab02-2.tex", append keep(lg_totalsol) ctitle(Log (industry)) dec(3) label

xtreg lg_ser lg_totalsol,be
outreg2 using "../results/result1/tab02-2.tex", append keep(lg_totalsol) ctitle(Log (services)) dec(3) label

xtreg lg_agri lg_totalsol,be
outreg2 using "../results/result1/tab02-2.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) dec(3) label

*TWFE
xtreg city_lggdp lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab02-3.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_nonagri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab02-3.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ind lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab02-3.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ser lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab02-3.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_agri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab02-3.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

**3.2 landcover/NPP and sectoral GDP
*TWFE-landcover area
xtreg lg_agri lg101214 i.year,fe robust
outreg2 using "../results/result1/tab02-4.tex", replace keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
*TWFE-NPP
xtreg lg_agri lg_ruralnpp i.year,fe robust
outreg2 using "../results/result1/tab02-4.tex", append keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

** 3.3 NTL_mean/median and GDP per capita
xtreg city_lggdppc lg_totalmol i.year,fe robust
outreg2 using "../results/result1/tab02-5.tex", replace keep(lg_totalmol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg city_lggdppc lg_urbanmol i.year,fe robust
outreg2 using "../results/result1/tab02-5.tex", append keep(lg_urbanmol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg city_lggdppc lg_totalmidol i.year,fe robust
outreg2 using "../results/result1/tab02-5.tex", append keep(lg_totalmidol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg city_lggdppc lg_urbanmidol i.year,fe robust
outreg2 using "../results/result1/tab02-5.tex", append keep(lg_urbanmidol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label


eststo m0a: xtreg city_lggdppc lg_totalmol i.year,fe robust
eststo m0b: twfem reg city_lggdppc lg_totalmol, absorb(city_id year) gen(icity_id1 year1) newv(r_) vce(robust)
label variable r_city_lggdppc   "Residualized GDP per capita (log)"
label variable r_lg_totalmol   "Residualized mean NTL (log)"
aaplot r_city_lggdppc r_lg_totalmol, aformat(%9.2f) bformat(%9.2f) name(fig0)


*** 4. Predict GDP

**Non-agriculture GDP
xtreg lg_nonagri lg_totalsol _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)
	
predict lg_nonagri_linear, xb						
gen beta_1=_b[lg_totalsol]			
forvalues i = 2/367 {
    gen beta_`i' = _b[_Inew_city__`i']
}					
gen const_1=_b[_cons]	

gen lg_nonagri_predicted = const_1

qui replace lg_nonagri_predicted = lg_nonagri_predicted + beta_1*lg_totalsol

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_nonagri_predicted = lg_nonagri_predicted + temp_beta
    qui drop temp_beta
}

foreach var of varlist beta_* {
    drop `var'
}	

drop const_1

**Agriculture GDP
xtreg lg_agri lg_ruralnpp _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)

predict lg_agri_linear, xb						
gen beta_1=_b[lg_ruralnpp]			
forvalues i = 2/367 {
    gen beta_`i' = _b[_Inew_city__`i']
}					
gen const_1=_b[_cons]	

gen lg_agri_predicted = const_1

qui replace lg_agri_predicted = lg_agri_predicted + beta_1*lg_ruralnpp

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_agri_predicted = lg_agri_predicted + temp_beta
    qui drop temp_beta
}

foreach var of varlist beta_* {
    drop `var'
}

drop const_1

**GDP per capita
xtreg city_lggdppc lg_totalmol _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)
	
predict lg_gdppc_linear, xb						
gen beta_1=_b[lg_totalmol]			
forvalues i = 2/367 {
    gen beta_`i' = _b[_Inew_city__`i']
}					
gen const_1=_b[_cons]	

gen lg_gdppc_predicted = const_1

qui replace lg_gdppc_predicted = lg_gdppc_predicted + beta_1*lg_totalmol

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_gdppc_predicted = lg_gdppc_predicted + temp_beta
    qui drop temp_beta
}

drop const_1

*Generate new variables
gen lg_totalgdp_predicted= ln(exp(lg_agri_predicted) + exp(lg_nonagri_predicted))
gen agri_gdp = exp(lg_agri_predicted)/exp(lg_totalgdp_predicted)
gen nonagri_gdp = exp(lg_nonagri_predicted)/exp(lg_totalgdp_predicted)

label variable lg_nonagri_predicted "Predicted non-agriculture GDP (log) using NTL"
label variable lg_agri_predicted "Predicted agriculture GDP (log) using NPP"
label variable lg_totalgdp_predicted "Predicted total GDP (log) using NTL and NPP"
label variable lg_gdppc_predicted "Predicted per capita GDP (log) using NTL"

summarize
describe

*Drop useless columns 
foreach var of varlist _Inew_city__* {
    drop `var'
}		

foreach var of varlist beta_* {
    drop `var'
}	

*** 5. Save dta file
save "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data/city_predicted.dta", replace


