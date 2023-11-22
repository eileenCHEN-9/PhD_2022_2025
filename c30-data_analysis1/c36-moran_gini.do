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
cd "/Users/yilinchen/Documents/PhD/thesis/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 15

** 2. Import city level dataset
use "moran_gini.dta", clear

label variable I "Moran's I"
label variable Gini_Light "GINI coefficient based on light density"

describe
summarize

aaplot Gini_Light I

tsline Gini_Light I

*set time series
destring year, replace
tsset year

**Co-integration
*Checking stationary
gen rI=d.I/l.I
gen rGINI=d.Gini_Light/l.Gini_Light
dfuller rI
dfuller rGINI
dfuller d.I
dfuller d.Gini_Light

reg Gini_Light I
predict r, resid
tsline r
dfuller r, noconstant

reg rGINI rI l.r

*Engle Granger co-integration
egranger Gini_Light I

*Variables are co-integrated, then estimate the error correction model
reg d.Gini_Light d.I l.r
eststo ecm_result
esttab ecm_result using "tab_IG.tex", replace


