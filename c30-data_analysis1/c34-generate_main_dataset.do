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
use city_predicted.dta, clear

*Drop Hongkong, Macau, Taiwan and Sansha city in South China Sea (no population)
drop if province_id == 810000 | province_id == 820000 | province_id == 710000
drop if city_id == 460300

summarize
describe

** 3. Merge with the inequality dataset
sort city_id year				
merge city_id year using "City_Inequality_Data.dta", unique
keep if _merge==3				
drop _merge				
sort city_id year

** 4. Generate necessary variables
gen pred_gdppc_city=exp(lg_gdppc_predicted)
gen nonagri_gdp=exp(lg_nonagri_predicted)/exp(lg_totalgdp_predicted)
gen Emp_nonagri=100-Emp_agri

label variable pred_gdppc_city "Predicted GDP per capita using NTL (mean)"
label variable agri_gdp "Ratio Of agriculture production To Gdp (%) (predicted)"
label variable nonagri_gdp "Ratio Of non-agriculture production To Gdp (%) (predicted)"
label variable ind_gdp "Ratio Of industry production To Gdp (%) (predicted)"
label variable ser_gdp "Ratio Of service production To Gdp (%) (predicted)"
label variable Emp_ind "Ratio Of industry employment To total (%)"
label variable Emp_ser "Ratio Of service employment To total (%)"
label variable Emp_agri "Ratio Of agriculture employment To total (%)"
label variable Emp_nonagri "Ratio Of non-agriculture employment To total (%)"
label variable Emp_num "Employed Persons"

save "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data/Main_Dataset.dta", replace


