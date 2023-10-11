cls
**==========================================
** Program Name: Construct GINI index
** Author: Yilin Chen
** Date: 2023-10-01
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta

* Data files created as final product:
*===========================================
*cd "/Users/yilinchen/Documents/PhD/thesis/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

** 2. Import county level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta", clear

summarize
describe

*Set panel	
xtset county_id year
xi i.year
xi i.county_id
set matsize 11000

gen pred_gdppc_county=exp(lg_totalgdp_predicted)/total_population*1000
gen totallightpc_county=total_sol/total_population*1000
gen county_gdppc=county_rgdp/total_population*1000

label variable pred_gdppc_county "Predicted GDP per capita (county)"
label variable totallightpc_county "Total sum of lights per capita (county)"
label variable county_gdppc "Real GDP per capita (constant, 2010)"

** 3. Calculations of regional inequality measures
*GINIW
gen GINIW_pred_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
qui ineqdeco pred_gdppc_county [aw=total_population]  if group == `i'
replace GINIW_pred_GDP_pc = r(gini) if group == `i'	
} 
foreach var of varlist _Icounty_id_* {
    drop `var'
}










