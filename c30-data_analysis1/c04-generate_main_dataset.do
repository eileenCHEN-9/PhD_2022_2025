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

** 2. Import county level dataset
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_predicted.dta", clear

summarize
describe

** 3. Merge with the inequality dataset
sort city_id year				
merge city_id year using "City_Inequality_Data.dta", unique
keep if _merge==3				
drop _merge				
sort city_id year
