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

** 4. Visualisation of TWFE regressions
*Log total GDP vs. Log sum NTL
eststo m1a: xtreg city_lggdp lg_totalsol i.year, fe vce(robust)
**** TWFE via FWL ****
eststo m1b: twfem reg city_lggdp lg_totalsol, absorb(city_id year) gen(city_id1 year1) newv(r1_) vce(robust)
label variable r1_city_lggdp   "Residualized total GDP (log)"
label variable r1_lg_totalsol   "Residualized sum NTL (log)"
aaplot r1_city_lggdp r1_lg_totalsol, aformat(%9.2f) bformat(%9.2f) name(fig1)

