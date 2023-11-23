cls
**==========================================
** Program Name: Predicting sectoral GDP (county) using VIIRS-like NTL, MODIS landcover, and net primary productivity
** Author: Yilin Chen
** Date: 2023-09-30
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_longpanel.dta

* Data files created as intermediate product:
*===========================================
cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

** 2. Import county level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_longpanel.dta", clear

*calculte the area of croplands
gen lg101214 = ln(0.01 + v26 + v28 + v30)
label variable lg101214 "Log (croplands)"

*Drop Hongkong, Macau, Taiwan and Sansha city in South China Sea (no population)
drop if province_id == 810000 | province_id == 820000 | province_id == 710000
drop if city_id == 460300

summarize
describe

** 3. Run regressions
*Set panel	
xtset county_id year
xi i.year
xi i.county_id
set matsize 11000

** 3.1 NTL-GDP
*Pooled OLS
reg county_lggdp lg_totalsol
outreg2 using "../results/result1/tab01-1.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_nonagri lg_totalsol
outreg2 using "../results/result1/tab01-1.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ind lg_totalsol
outreg2 using "../results/result1/tab01-1.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_ser lg_totalsol
outreg2 using "../results/result1/tab01-1.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

reg lg_agri lg_totalsol
outreg2 using "../results/result1/tab01-1.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, NO, Year FE, NO) dec(3) label

*Between estimator
xtreg county_lggdp lg_totalsol,be
outreg2 using "../results/result1/tab01-2.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) dec(3) label

xtreg lg_nonagri lg_totalsol,be
outreg2 using "../results/result1/tab01-2.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) dec(3) label

xtreg lg_ind lg_totalsol,be
outreg2 using "../results/result1/tab01-2.tex", append keep(lg_totalsol) ctitle(Log (industry)) dec(3) label

xtreg lg_ser lg_totalsol,be
outreg2 using "../results/result1/tab01-2.tex", append keep(lg_totalsol) ctitle(Log (services)) dec(3) label

xtreg lg_agri lg_totalsol,be
outreg2 using "../results/result1/tab01-2.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) dec(3) label

*TWFE
xtreg county_lggdp lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab01-3.tex", replace keep(lg_totalsol) ctitle(Log (total GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_nonagri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab01-3.tex", append keep(lg_totalsol) ctitle(Log (non-agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ind lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab01-3.tex", append keep(lg_totalsol) ctitle(Log (industry)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_ser lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab01-3.tex", append keep(lg_totalsol) ctitle(Log (services)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg lg_agri lg_totalsol i.year,fe robust
outreg2 using "../results/result1/tab01-3.tex", append keep(lg_totalsol) ctitle(Log (agriculture)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

** 3.2 landcover/NPP and sectoral GDP
*TWFE-landcover area
xtreg lg_agri lg101214 i.year,fe robust
outreg2 using "../results/result1/tab01-4.tex", replace keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
*TWFE-NPP
xtreg lg_agri lg_ruralnpp i.year,fe robust
outreg2 using "../results/result1/tab01-4.tex", append keep(lg101214 lg_ruralnpp) ctitle(Log (agriculture GDP)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

** 3.3 NTL_mean/median and GDP per capita
xtreg county_lggdppc lg_totalmol i.year,fe robust
outreg2 using "../results/result1/tab02-1.tex", replace keep(lg_totalmol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg county_lggdppc lg_urbanmol i.year,fe robust
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_urbanmol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg county_lggdppc lg_totalmidol i.year,fe robust
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_totalmidol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg county_lggdppc lg_urbanmidol i.year,fe robust
outreg2 using "../results/result1/tab02-1.tex", append keep(lg_urbanmidol) ctitle(Log (GDP per capita)) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label



eststo m0a: xtreg county_lggdppc lg_totalmol i.year,fe robust
eststo m0b: twfem reg county_lggdppc lg_totalmol, absorb(county_id year) gen(icounty_id1 year1) newv(r_) vce(robust)
label variable r_county_lggdppc   "Residualized GDP per capita (log)"
label variable r_lg_totalmol   "Residualized mean NTL (log)"
aaplot r_county_lggdppc r_lg_totalmol, aformat(%9.2f) bformat(%9.2f) name(fig0)



*** 4. Predict GDP

**Non-agriculture GDP
xtreg lg_nonagri lg_totalsol i.year,fe robust
predict y_predicted1, xb
rename y_predicted1 lg_nonagri_predicted
*Drop useless columns 
foreach var of varlist _Icounty_id_* {
    drop `var'
}

**Agriculture GDP
xtreg lg_agri lg_ruralnpp i.year,fe robust
predict y_predicted2, xb
rename  y_predicted2 lg_agri_predicted

**GDP per capita
xtreg county_lggdppc lg_totalmol i.year,fe robust
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
save "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data/county_predicted.dta", replace



 
  ****TWFE via xtreg 
  eststo m01: xtreg county_lggdppc lg_totalmol i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m02: twfem reg county_lggdppc lg_totalmol, absorb(county_id year) gen(county_id01 year01) newv(r1_) vce(robust)
  label variable r1_county_lggdppc   "Residualized Log GDP per capita"
  label variable r1_lg_totalmol   "Residualized Log mean NTL"
aaplot r1_county_lggdppc r1_lg_totalmol, aformat(%9.2f) bformat(%9.2f) name(fig1)


*Log GDP per capita vs. Log mean NTL
eststo m1a: reg county_lggdppc lg_totalmol
aaplot county_lggdppc lg_totalmol, aformat(%9.2f) bformat(%9.2f) name(fig1)

reg county_lggdppc lg_totalmol
predict y_predicted4, xb
rename y_predicted4 lg_pregdppc_pooled

gen predgdppc_pool = exp(lg_pregdppc_pooled)

*GINIW
gen GINIW_predgdp_pool = .
egen group = group(city_id year)  

su group, meanonly
qui forval i = 1/`r(max)' {
  qui count if group == `i' & !missing(predgdppc_pool)
  if r(N) > 0 {
    qui ineqdeco predgdppc_pool [aw=total_population] if group == `i' & !missing(predgdppc_pool)
    replace GINIW_predgdp_pool = r(gini) if group == `i'
  }
}

drop group

*Generalized Entropy class  1 (Theil index)
gen GE_1W_predgdp_pool = .
egen group = group(city_id year)
su group, meanonly
qui forval i = 1/`r(max)' {
	qui count if group == `i' & !missing(predgdppc_pool)
  if r(N) > 0 {
qui ineqdeco predgdppc_pool [aw=total_population]  if group == `i'
replace GE_1W_predgdp_pool = r(ge1) if group == `i'	
  }
} 

drop group

*Create new id by city by year
gen id_t_j = string(year) + city

*Aggregate city-level GINI index
collapse (first) city_id year GINIW_predgdp_pool - GE_1W_predgdp_pool, by(id_t_j)
sort city_id year 		
drop id_t_j

*save "/Users/yilinchen/Downloads/Main_Dataset_pooled.dta"

cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

** 3. Merge with the inequality dataset
sort city_id year				
merge city_id year using "Main_Dataset.dta", unique
keep if _merge==3				
drop _merge				
sort city_id year

summarize

*Correlations		
pwcorr  GINIW_predgdp_pool 		GINIW_GDP_pc 		GINIW_pred_GDP_pc			
pwcorr  GE_1W_predgdp_pool 		GE_1W_GDP_pc 		GE_1W_pred_GDP_pc



