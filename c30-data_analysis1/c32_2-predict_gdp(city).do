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

tsset new_city_id year
xtset new_city_id year
xi i.year i.new_city_id
set matsize 11000

*** 4. Predict GDP

**Non-agriculture GDP
xtreg lg_nonagri lg_totalsol _Iyear_* _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)
	
predict lg_nonagri_linear, xb
					
gen beta_1=_b[lg_totalsol]
	
forvalues i = 2/367 {
    gen beta_city_`i' = _b[_Inew_city__`i']
}

forvalues y = 2002/2020 {
    gen beta_year_`y' = _b[_Iyear_`y']
}

gen const_1=_b[_cons]	

gen lg_nonagri_predicted = const_1

qui replace lg_nonagri_predicted = lg_nonagri_predicted + beta_1*lg_totalsol

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_city_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_nonagri_predicted = lg_nonagri_predicted + temp_beta
    qui drop temp_beta
}

forvalues y = 2002/2020 {
    local year_var _Iyear_`y'
    qui gen temp_beta = beta_year_`y' if `year_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_nonagri_predicted = lg_nonagri_predicted + temp_beta
    qui drop temp_beta
}

foreach var of varlist beta_* {
    drop `var'
}	

drop const_1

**Agriculture GDP
xtreg lg_agri lg_ruralnpp _Iyear_* _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)

predict lg_agri_linear, xb	
					
gen beta_1=_b[lg_ruralnpp]	
		
forvalues i = 2/367 {
    gen beta_city_`i' = _b[_Inew_city__`i']
}	

forvalues y = 2002/2020 {
    gen beta_year_`y' = _b[_Iyear_`y']
}
				
gen const_1=_b[_cons]	

gen lg_agri_predicted = const_1

qui replace lg_agri_predicted = lg_agri_predicted + beta_1*lg_ruralnpp

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_city_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_agri_predicted = lg_agri_predicted + temp_beta
    qui drop temp_beta
}

forvalues y = 2002/2020 {
    local year_var _Iyear_`y'
    qui gen temp_beta = beta_year_`y' if `year_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_agri_predicted = lg_agri_predicted + temp_beta
    qui drop temp_beta
}

foreach var of varlist beta_* {
    drop `var'
}

drop const_1

**GDP per capita
xtreg city_lggdppc lg_totalmol _Iyear_* _Inew_city__2-_Inew_city__367, robust cluster(new_city_id)
	
predict lg_gdppc_linear, xb	
					
gen beta_1=_b[lg_totalmol]	
		
forvalues i = 2/367 {
    gen beta_city_`i' = _b[_Inew_city__`i']
}			

forvalues y = 2002/2020 {
    gen beta_year_`y' = _b[_Iyear_`y']
}
		
gen const_1=_b[_cons]	

gen lg_gdppc_predicted = const_1

qui replace lg_gdppc_predicted = lg_gdppc_predicted + beta_1*lg_totalmol

forvalues i = 2/367 {
    local city_var _Inew_city__`i'
    qui gen temp_beta = beta_city_`i' if `city_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_gdppc_predicted = lg_gdppc_predicted + temp_beta
    qui drop temp_beta
}

forvalues y = 2002/2020 {
    local year_var _Iyear_`y'
    qui gen temp_beta = beta_year_`y' if `year_var' == 1
    qui replace temp_beta = 0 if missing(temp_beta)
    qui replace lg_gdppc_predicted = lg_gdppc_predicted + temp_beta
    qui drop temp_beta
}

foreach var of varlist beta_* {
    drop `var'
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

foreach var of varlist _Iyear_* {
    drop `var'
}	

*** 5. Save dta file



















