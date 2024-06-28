cls
**==========================================
** Program Name: Validation visualisation
** Author: Yilin Chen
** Date: 2024-06-25
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
import delimited "Main_Dataset_withlags.csv", clear 

*** 3. Run regressions
*Set panel	
xtset city_id year

**Spatial Kuznets: agriculture
xtreg giniw_pred_gdp_pc w_giniw_pred_gdp_pc lg_agri_predicted lg_agri_predicted_2 w_lg_agri_predicted_2 urban_pop_percent w_urban_pop_percent i.year, fe robust
predict y_resfe, e

xtreg w_lg_agri_predicted w_giniw_pred_gdp_pc lg_agri_predicted lg_agri_predicted_2 w_lg_agri_predicted_2 urban_pop_percent w_urban_pop_percent i.year, fe robust
predict x_resfe, e

*aaplot y_resfe x_resfe
twoway (scatter y_resfe x_resfe, mcolor(gs8) msymbol(o) msize(small)) ///
       (qfit y_resfe x_resfe, lcolor(maroon) lwidth(medium)), ///
       title("GINI index vs Predicted agriculture GDP (log) in neighboring regions") ///
       ytitle("GINI index") xtitle("Neighboring Predicted agriculture GDP (log)") ///
	   xlabel(, grid) ylabel(, grid) legend(off)
	   
**Spatial Kuznets: non-agriculture
xtreg giniw_pred_gdp_pc w_giniw_pred_gdp_pc lg_nonagri_predicted lg_nonagri_predicted_2 w_lg_nonagri_predicted_2 urban_pop_percent w_urban_pop_percent i.year, fe robust
predict y_resfe1, e

xtreg w_lg_nonagri_predicted w_giniw_pred_gdp_pc lg_nonagri_predicted lg_nonagri_predicted_2 w_lg_nonagri_predicted_2 urban_pop_percent w_urban_pop_percent i.year, fe robust
predict x_resfe1, e

*aaplot y_resfe x_resfe
twoway (scatter y_resfe1 x_resfe1, mcolor(gs8) msymbol(o) msize(small)) ///
       (qfit y_resfe1 x_resfe1, lcolor(stc2) lwidth(medium)), ///
       title("GINI index vs Predicted non-agriculture GDP (log) in neighboring regions") ///
       ytitle("GINI index") xtitle("Neighboring Predicted non-agriculture GDP (log)") ///
	   xlabel(, grid) ylabel(, grid) legend(off)

	   
