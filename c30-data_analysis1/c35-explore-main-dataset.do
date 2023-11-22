cls
**==========================================
** Program Name: Explore main dataset
** Author: Yilin Chen
** Date: 2023-10-14
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta
* Data files created as final product:
*===========================================
** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 15

** 2. Import city level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta", clear

** 3. Set panel data structure	
xtset city_id year
xi i.year
xi i.city_id
set matsize 11000

*Drop useless columns 
foreach var of varlist _Icity_id_* {
    drop `var'
}

describe
summarize

**Visualisation
replace gdpct02 = gdpct02/100
eststo m1a: xtreg GINIW_GDP_pc gdpct02 i.year, fe
eststo m0b: twfem reg GINIW_GDP_pc gdpct02, absorb(city_id year) gen(icity_id02 year02) newv(r2_) vce(robust)
  label variable r2_GINIW_GDP_pc   "Residualized GINI coefficient"
  label variable r2_gdpct02   "Residualized agriculture output share"
aaplot r2_GINIW_GDP_pc r2_gdpct02, aformat(%9.2f) bformat(%9.2f) name(fig123)


xtreg GINIW_GDP_pc agri, be

  eststo m0c: xtreg GINIW_light_pc lg_agri, be
  preserve
  sort city_id year
  collapse (mean) GINIW_light_pc lg_agri, by(city_id)
  label variable GINIW_light_pc "Cross-sectional GINI coefficient"
  label variable lg_agri "Cross-sectional Log agriculture GDP"
aaplot GINIW_light_pc lg_agri, aformat(%9.2f) bformat(%9.2f) name(fig250)










