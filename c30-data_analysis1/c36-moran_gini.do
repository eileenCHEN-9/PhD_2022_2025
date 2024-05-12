cls
**==========================================
** Program Name: Relationship between moran's I and GINI index (city level)
** Author: Yilin Chen
** Date: 2023-11-22
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * /Users/yilinchen/Documents/PhD/thesis/data
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
use "moran_gini.dta", clear

label variable I "Moran's I"
label variable Gini_Predicted_GDP "GINI coefficient based on light density"

describe
summarize

** 3. set time series
destring year, replace
tsset year

aaplot Gini_Predicted_GDP I

tsline Gini_Predicted_GDP I

**Co-integration
*Checking stationary
gen rI=d.I/l.I
gen rGINI=d.Gini_Predicted_GDP/l.Gini_Predicted_GDP
dfuller rI
dfuller rGINI
dfuller d.I
dfuller d.Gini_Predicted_GDP

reg Gini_Predicted_GDP I
eststo long_term

predict r, resid
tsline r
dfuller r, noconstant

reg rGINI rI l.r

*Engle Granger co-integration
egranger Gini_Predicted_GDP I

*Variables are co-integrated, then estimate the error correction model
reg d.Gini_Predicted_GDP d.I l.r
eststo short_term
esttab long_term short_term using "tab_IG.tex", replace


