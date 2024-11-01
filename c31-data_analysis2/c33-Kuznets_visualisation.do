cls
**==========================================
** Program Name: Validation visualisation
** Author: Yilin Chen
** Date: 2024-04-12
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta
* Data files created as final product:
*===========================================
cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 18

** 2. Import city level dataset
*use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta", clear
sysuse Main_Dataset

describe
summarize

*** 3. Run regressions
*Set panel	
xtset city_id year

*xtreg GINIW_pred_GDP_pc lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent i.year, fe robust
*predict GINI_hat, xbu
*twoway (scatter GINIW_pred_GDP_pc lg_gdppc_predicted, mcolor(gs8) msymbol(o)) (qfit GINI_hat lg_gdppc_predicted, sort lcolor(maroon) lwidth(medium)), legend(label(1 "GINI index based on lights") label(2 "Fitted values")) title("Relationship between GINI index and Predicted per capita GDP (log)") ytitle("GINI index") xtitle("Predicted per capita GDP (log) using NTL")

**Kuznets
xtreg GINIW_pred_GDP_pc lg_gdppc_predicted_2 urban_pop_percent i.year, fe robust
predict y_resfe, e

xtreg lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent i.year, fe robust
predict x_resfe, e

*aaplot y_resfe x_resfe
twoway (scatter y_resfe x_resfe, mcolor(gs8) msymbol(o) msize(small)) ///
       (qfit y_resfe x_resfe, lcolor(maroon) lwidth(medium)), ///
       legend(label(1 "Residuals") label(2 "Quadratic fitted values")) ///
       title("Residuals Plot: GINI index vs Predicted GDP (log)") ///
       ytitle("Residuals of GINI index") xtitle("Residuals of Predicted per capita GDP (log)")

*Kuznets using GINI lights
xtreg GINIW_pred_GDP_pc lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent i.year, fe robust
twoway scatter GINIW_pred_GDP_pc lg_gdppc_predicted || qfit GINIW_pred_GDP_pc lg_gdppc_predicted, ///
       title("GINI index vs Predicted GDP (log)") ///
       ytitle("GINI index based on lights") xtitle("Predicted per capita GDP (log)") ///
	   xlabel(, grid) ylabel(, grid) legend(off)
 
	   
**Agri Kuznets
xtreg GINIW_pred_GDP_pc lg_agri_predicted_2 urban_pop_percent i.year,fe robust
predict y_resfe1, e

xtreg lg_agri_predicted lg_agri_predicted_2 urban_pop_percent i.year,fe robust
predict x_resfe1, e

*aaplot y_resfe x_resfe
twoway (scatter y_resfe1 x_resfe1, mcolor(gs8) msymbol(o) msize(small)) ///
       (qfit y_resfe1 x_resfe1, lcolor(stc2) lwidth(medium)), ///
       title("Residuals Plot: GINI index vs Predicted agriculture GDP (log)") ///
       ytitle("Residualized GINI index") xtitle("Residualized Predicted agritulture GDP (log)") ///
	   xlabel(, grid) ylabel(, grid) legend(off)

*Non-agri Kuznets
xtreg GINIW_pred_GDP_pc lg_nonagri_predicted_2 urban_pop_percent i.year,fe robust
predict y_resfe2, e

xtreg lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent i.year,fe robust
predict x_resfe2, e

*aaplot y_resfe x_resfe
twoway (scatter y_resfe2 x_resfe2, mcolor(gs8) msymbol(o) msize(small)) ///
       (qfit y_resfe2 x_resfe2, lcolor(stc2) lwidth(medium)), ///
       legend(label(1 "Residualized values") label(2 "Quadratic fitted values")) ///
       title("Residuals Plot: GINI index vs Predicted non-agriculture GDP (log)") ///
       ytitle("Residualized GINI index") xtitle("Residualized Predicted non-agritulture GDP (log)") ///
	   xlabel(, grid) ylabel(, grid) legend(off)

* Spatial Kuznets
spshape2dta "city_edited_thiessen", replace

use city_edited_thiessen

describe
summarize

spset _ID, modify replace

spset, modify coordsys(latlong, miles)

spset

sysuse Main_Dataset
xtset city_id year 
spbalance 
merge m:1 city_id using city_edited_thiessen
keep if _merge==3 
drop _merge
tset

save city_edited_thiessen_fullpanel,replace 
sysuse city_edited_thiessen_fullpanel
describe

spwmatrix import using "city_edited_thiessen.gal", wname(Wa) rowstand

xsmle GINIW_pred_GDP_pc lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog

twoway scatter GINIW_pred_GDP_pc lg_nonagri_predicted || qfit GINIW_pred_GDP_pc lg_nonagri_predicted, ///
    title("Quadratic Fit of GINIW_pred_GDP_pc on lg_nonagri_predicted") ///
    *legend(label(1 "Residualized values") label(2 "Quadratic fitted values")) ///
    ytitle("Residualized GINI index") xtitle("Residualized Predicted non-agritulture GDP (log)")














 
 
 
 
 