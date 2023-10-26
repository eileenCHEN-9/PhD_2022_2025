cls
**==========================================
** Program Name: Construct GINI index
** Author: Yilin Chen
** Date: 2023-10-01
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta

* Data files created as intermediate product:
*===========================================
* cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"
* ssc install ineqdeco, replace


** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 15

** 2. Import county level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta", clear

drop areaid ctnm_en cityname province
keep if year>2011
keep if year<2014 

summarize
describe

gen pred_gdppc_county=exp(lg_totalgdp_predicted)/total_population
gen totallightpc_county=total_sol/total_population
gen county_gdppc=county_rgdp/total_population

*drop if missing(pred_gdppc_county)

label variable pred_gdppc_county "Predicted GDP per capita (county)"
label variable totallightpc_county "Total sum of lights per capita (county)"
label variable county_gdppc "Real GDP per capita (constant, 2010)"

** 3. Calculations of regional inequality measures using predicted GDP
*GINIW
gen GINIW_pred_GDP_pc = .
egen group = group(city_id year)  

su group, meanonly
qui forval i = 1/`r(max)' {
  qui count if group == `i' & !missing(pred_gdppc_county)
  if r(N) > 0 {
    qui ineqdeco pred_gdppc_county [aw=total_population] if group == `i' & !missing(pred_gdppc_county)
    replace GINIW_pred_GDP_pc = r(gini) if group == `i'
  }
}

drop group

*Generalized Entropy class -1 
gen GE_m1W_pred_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
  qui count if group == `i' & !missing(pred_gdppc_county)
  if r(N) > 0 {
  qui ineqdeco pred_gdppc_county [aw=total_population]  if group == `i'
replace GE_m1W_pred_GDP_pc = r(gem1) if group == `i'	
}
}

drop group

*Generalized Entropy class  0 (mean logarithmic deviation)
gen GE_0W_pred_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(pred_gdppc_county)
  if r(N) > 0 {
qui ineqdeco pred_gdppc_county [aw=total_population]  if group == `i'
replace GE_0W_pred_GDP_pc = r(ge0) if group == `i'	
  }
} 

drop group

*Generalized Entropy class  1 (Theil index)
gen GE_1W_pred_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(pred_gdppc_county)
  if r(N) > 0 {
qui ineqdeco pred_gdppc_county [aw=total_population]  if group == `i'
replace GE_1W_pred_GDP_pc = r(ge1) if group == `i'	
  }
} 

drop group

*COVW GE(2) is half the square of the coefficient of variation.
gen GE_2w_pred_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(pred_gdppc_county)
  if r(N) > 0 {
qui ineqdeco pred_gdppc_county [aw=total_population]  if group == `i'
replace GE_2w_pred_GDP_pc = r(ge2) if group == `i'	
  }
} 
*foreach var of varlist _Icounty_id_* {
 *   drop `var'
*}
drop group
gen COVW_pred_GDP_pc=sqrt(GE_2w_pred_GDP_pc*2)
drop GE_2w_pred_GDP_pc		

** 4. Calculations of regional inequality measures using lights
*GINIW
gen GINIW_light_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(totallightpc_county)
  if r(N) > 0 {
qui ineqdeco totallightpc_county [aw=total_population]  if group == `i'
replace GINIW_light_pc = r(gini) if group == `i'
  }	
} 

drop group

*Generalized Entropy class -1 
gen GE_m1W_light_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(totallightpc_county)
  if r(N) > 0 {
qui ineqdeco totallightpc_county [aw=total_population]  if group == `i'
replace GE_m1W_light_pc = r(gem1) if group == `i'	
  }
}

drop group

*Generalized Entropy class  0 (mean logarithmic deviation)
gen GE_0W_light_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(totallightpc_county)
  if r(N) > 0 {
qui ineqdeco totallightpc_county [aw=total_population]  if group == `i'
replace GE_0W_light_pc = r(ge0) if group == `i'	
  }
} 

drop group

*Generalized Entropy class  1 (Theil index)
gen GE_1W_light_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(totallightpc_county)
  if r(N) > 0 {
qui ineqdeco totallightpc_county [aw=total_population]  if group == `i'
replace GE_1W_light_pc = r(ge1) if group == `i'	
  }
} 

drop group

*COVW GE(2) is half the square of the coefficient of variation.
gen GE_2w_light_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(totallightpc_county)
  if r(N) > 0 {
qui ineqdeco totallightpc_county [aw=total_population]  if group == `i'
replace GE_2w_light_pc = r(ge2) if group == `i'	
  }
} 

drop group
gen COVW_light_pc=sqrt(GE_2w_light_pc*2)
drop GE_2w_light_pc		

** 5. Calculations of regional inequality measures using observed GDP
*GINIW
gen GINIW_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(county_gdppc)
  if r(N) > 0 {
qui ineqdeco county_gdppc [aw=total_population]  if group == `i'
replace GINIW_GDP_pc = r(gini) if group == `i'	
  }
} 

drop group

*Generalized Entropy class -1 
gen GE_m1W_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(county_gdppc)
  if r(N) > 0 {
qui ineqdeco county_gdppc [aw=total_population]  if group == `i'
replace GE_m1W_GDP_pc = r(gem1) if group == `i'	
  }
}

drop group

*Generalized Entropy class  0 (mean logarithmic deviation)
gen GE_0W_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(county_gdppc)
  if r(N) > 0 {
qui ineqdeco county_gdppc [aw=total_population]  if group == `i'
replace GE_0W_GDP_pc = r(ge0) if group == `i'	
  }
} 

drop group

*Generalized Entropy class  1 (Theil index)
gen GE_1W_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(county_gdppc)
  if r(N) > 0 {
qui ineqdeco county_gdppc [aw=total_population]  if group == `i'
replace GE_1W_GDP_pc = r(ge1) if group == `i'	
  }
} 

drop group

*COVW GE(2) is half the square of the coefficient of variation.
gen GE_2w_GDP_pc=.
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(county_gdppc)
  if r(N) > 0 {
qui ineqdeco county_gdppc [aw=total_population]  if group == `i'
replace GE_2w_GDP_pc = r(ge2) if group == `i'	
  }
} 
*foreach var of varlist _Icounty_id_* {
 *   drop `var'
*}
drop group
gen COVW_GDP_pc=sqrt(GE_2w_GDP_pc*2)
drop GE_2w_GDP_pc		

*Aggregate city-level GINI index
collapse (first)  city city_id year GINIW_pred_GDP_pc - COVW_pred_GDP_pc, by(id_t_j)
sort city_id year
drop id_t_j
					
save "City_Inequality_Data.dta", replace

*Collapse to cross section 	
collapse (mean)    GINIW_pred_GDP_pc - COVW_GDP_pc, by(city_id_ntl)						
describe
summarize

*Correlations		
pwcorr  GINIW_pred_GDP_pc 		GINIW_GDP_pc 		GINIW_light_pc			
pwcorr  GE_m1W_pred_GDP_pc 		GE_m1W_GDP_pc 		GE_m1W_light_pc
pwcorr  GE_0W_pred_GDP_pc 		GE_0W_GDP_pc 		GE_0W_light_pc
pwcorr  GE_1W_pred_GDP_pc 		GE_1W_GDP_pc 		GE_1W_light_pc
pwcorr  COVW_pred_GDP_pc 		COVW_GDP_pc 		COVW_light_pc	




