cls
**==========================================
** Program Name: Inequality analysis using GDP, luminosity-based GDP and pure light
** Author: Yilin Chen
** Date: 2024-05-08
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta
* Data files created as final product:
*===========================================
cd "/Users/yilinchen/Documents/PhD/thesis/PhD_2022_2025/data"

cd "/Users/yilinchen/Downloads/Data_fixed"

** Setup
clear all
macro drop _all
capture log close
set more off
version 15

** Import data
use  county_gini_edited.dta, clear
sort county_id year

*gen gdppc_predicted = exp(lg_gdppc_predicted)

** Describe data
describe
summarize
xtset county_id year
xtsum pred_gdppc_county total_meanlight county_rgdppc total_population

** Compute gini over time
ineqdeco pred_gdppc_county  [w= total_population], by(year)
ineqdeco total_meanlight       [w= total_population], by(year)
ineqdeco county_rgdppc      [w= total_population], by(year)

** Colapse data by taking the mean over the years
preserve

  collapse (mean) pred_gdppc_county total_meanlight county_rgdppc total_population, by(county_id)
  summarize

  ** Simplify labels
  label variable pred_gdppc_county   "NTL-based GDP"
  label variable total_meanlight        "NTL(VIIRS-like)"
  label variable county_rgdppc      "GDP"

  ** Compute inequality measures
  ineqerr pred_gdppc_county [w= total_population] 
  ineqerr total_meanlight      [w= total_population] 
  ineqerr county_rgdppc    [w= total_population]

  ** Compare lorentz curves
  lorenz estimate pred_gdppc_county total_meanlight county_rgdppc [iw= total_population], gini 
  lorenz graph,  overlay proportion  ytitle("Cumulative share of GDP, NTL and NTL-based GDP") xtitle("Cumulative share of total population") legend(pos(11) ring(0)) ysize(5) xsize(5) name(all, replace)
  *graph export "../results/results1/county_gini.png", replace as(png)

restore




