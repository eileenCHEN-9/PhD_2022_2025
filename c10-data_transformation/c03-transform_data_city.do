cls
**==========================================
** Program Name: Data transformation for city-level dataset
** Author: Yilin Chen
** Date: 2023-09-30
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://github.com/eileenCHEN-9/PhD_2022_2025/blob/main/data/city_longpanel.dta

* Data files created as intermediate product:
*===========================================
** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

import delimited using "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/city_longpanel.csv", clear

summarize
describe

** 2. Generate variables
gen city_lggdp = log(city_rgdp)
gen city_lggdppc = log(city_rgdppc)
gen lg_nonagri = log(city_rgdp*(gdpct03 + gdpct04)/100)
gen lg_agri = log(city_rgdp*gdpct02/100)
gen lg_ind = log(city_rgdp*gdpct03/100)
gen lg_ser = log(city_rgdp*gdpct04/100)

gen lg_totalsol = log(total_sol)
gen lg_urbansol = log(urban_sol)
gen lg_ruralsol = log(agriculture_sol)
gen lg_ruralnpp = log(agriculture_anpp)

** 3. Label variables
label variable ctnm_en "Name Of City"
label variable gdpct01 "City nominal GDP"
label variable gdpct02 "Ratio Of Primary Industry To Gdp (%)"
label variable gdpct03 "Ratio Of Secondary Industry To Gdp (%)"
label variable gdpct04 "Ratio Of Tertiary Industry To Gdp (%)"
label variable gdp_percapita "Regional GDP per Capita"
label variable rel_cpi_2010 "CPI (base year: 2010)"
label variable city_rgdp "City real GDP (base year: 2010)"
label variable city_rgdppc "City real GDP per capita (base year: 2010)"
label variable city_lggdp "Log real GDP"
label variable city_lggdppc "Log real GDP per capita"
label variable lg_nonagri "Log non-agriculture GDP"
label variable lg_agri "Log agriculture GDP"
label variable lg_ind "Log industrial GDP"
label variable lg_ser "Log service GDP"
label variable lg_totalsol "Log total sum of lights"
label variable lg_urbansol "Log urban sum of lights"
label variable lg_ruralsol "Log rural sum of lights"
label variable lg_ruralnpp "Log average NPP (net primary productivity) in the rural area"
label variable pi0101 "CPI (last year = 100)"
label variable gdp_primind "Primary industry GDP (nominal)"
label variable gdp_secind "Secondary industry GDP (nominal)"
label variable gdp_terind "Tertiary industry GDP (nominal)"

** 4. Save dta file
save "/Users/yilinchen/Documents/PhD/thesis/data/city_longpanel.dta"













