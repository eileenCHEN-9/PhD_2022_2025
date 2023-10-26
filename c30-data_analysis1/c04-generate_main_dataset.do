cls
**==========================================
** Program Name: Generate main dataset
** Author: Yilin Chen
** Date: 2023-10-14
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_predicted.dta
  * "City_Inequality_Data.dta"
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
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_predicted.dta", clear

summarize
describe

** 3. Merge with the inequality dataset
sort city_id year				
merge city_id year using "City_Inequality_Data.dta", unique
keep if _merge==3				
drop _merge				
sort city_id year

** 4. Generate necessary variables
gen pred_gdppc_city=exp(lg_totalgdp_predicted)/total_population*1000
gen agri_gdp=exp(lg_agri_predicted)/exp(lg_totalgdp_predicted)
gen nonagri_gdp=exp(lg_nonagri_predicted)/exp(lg_totalgdp_predicted)

label variable pred_gdppc_city "Predicted GDP per capita (city)"
label variable agri_gdp "Share of agriculture production in total GDP (predicted)"
label variable nonagri_gdp "Share of non-agriculture production in total GDP (predicted)"

save "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data/Main_Dataset.dta", replace


