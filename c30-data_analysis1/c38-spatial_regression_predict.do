cls
**==========================================
** Program Name: Generate main dataset
** Author: Yilin Chen
** Date: 2023-11-12
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_edited_thiessen_fullpanel.dta
* Data files created as final product:
*===========================================
cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 15

** 2. Import city level dataset
*use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_edited_thiessen_fullpanel.dta", clear
sysuse city_edited_thiessen_fullpanel
describe

*** 3. Run regressions
*Set panel	
xtset city_id year

*Create queen contiguity weight matrix
spwmatrix import using "city_edited_thiessen.gal", wname(Wa) rowstand

** Include spatial lags based on the within estimator
xsmle city_lggdppc lg_totalmol, fe type(both) emat(Wa) mod(sem) effects nsim(999) nolog
estimate store sem
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle city_lggdppc lg_totalmol, fe type(both) wmat(Wa) mod(sar) effects nsim(999) nolog
estimate store sar
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle city_lggdppc lg_totalmol, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

#delimit;
    esttab sdm4 sdm5,
    keep(lg_totalmol rho lamda)
    se
    label 
    stats(N N_g r2 aic bic FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Cities" "R-squared" "AIC" "BIC" "City FE" "Year FE"))
    mtitles(" " " " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
						"All models include a constant"
            "* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    compress
    replace;
#delimit cr

#delimit;
    esttab sdm4 sdm5 using "../results/result2/table/tab22-2.tex",
    keep(lg_totalmol rho lamda)
    se
    label 
    stats(N N_g r2 FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Countries" "R-squared" "City FE" "Year FE"))
    mtitles(" " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
            "All models include a constant"
            "$* p<0.10, ** p<0.05, *** p<0.01$")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    replace;
#delimit cr






