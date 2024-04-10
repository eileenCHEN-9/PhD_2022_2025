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
version 15

** 2. Import city level dataset
*use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta", clear
sysuse Main_Dataset

describe
summarize

*** 3. Run regressions
*Set panel	
xtset city_id year
