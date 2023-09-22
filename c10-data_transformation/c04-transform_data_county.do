cls
**==========================================
** Program Name: Data transformation for county-level dataset
** Author: Yilin Chen
** Date: 2023-09-30
**------------------------------------------
** Inputs/Ouputs:
* Data files used: 
  * https://github.com/eileenCHEN-9/PhD_2022_2025/blob/main/data/county_longpanel.csv

* Data files created as intermediate product:
*===========================================
cd "/Users/yilinchen/Documents/PhD/thesis/data"

** 1. Setup
clear all
macro drop _all
capture log close
set more off
version 17

** 2. Import county level dataset
import delimited "county_longpanel.csv", clear 

summarize
describe

** 3. Generate new columns
gen county_lggdp = log(county_rgdp)
gen county_lggdppc = log(county_rgdppc)
gen lg_totalsol = log(total_sol)
gen lg_urbansol = log(urban_sol)
gen lg_ruralsol = log(agriculture_sol)
gen lg_ruralnpp = log(agriculture_anpp)
gen lg_nonagri = log((cmect05+cmect06)/rel_cpi_2010*100)
gen lg_agri = log(cmect04/rel_cpi_2010*100)
gen lg_ind = log(cmect05/rel_cpi_2010*100)
gen lg_ser = log(cmect06/rel_cpi_2010*100)

** 4. Label variables
label variable total_population "Total population (Landscan)"
label variable ctnm_en "County Name"
label variable prvcnm_enx "Province Name"
label variable cmect01 "Land Area"
label variable cmect02 "Total Population (Year-End)"
label variable cmect03 "GRDP (nominal)"
label variable cmect04 "GRDP - Primary Industry (nominal)"
label variable cmect05 "GRDP - Secondary Industry (nominal)"
label variable cmect06 "GRDP - Tertiary Industry (nominal)"
label variable cmect07 "GRDP per Capita (nominal)"
label variable cmect08 "Urban Employed Persons"
label variable cmect09 "Rural Employed Persons"
label variable cmect10 "Employed Persons in Farming, Forestry, Husbandry and Fishery"
label variable cmect11 "Total Fixed Asset Investments"
label variable cmect12 "Regional Fiscal Revenue"
label variable cmect13 "Regional Fiscal Expenditure"
label variable cmect14 "Net Income Of Rural Residents Per Capita"
label variable cmect15 "Average Salary Of Urban Employees"
label variable cmect16 "Cultivated Area In Common Use"
label variable cmect17 "Gross Output Value in Farming, Forestry, Husbandry and Fishery"
label variable cmect18 "Total Retails Of Consumer Goods"

label variable pi0101 "CPI (last year = 100)"
label variable rel_cpi_2010 "CPI (base year: 2010)"
label variable county_rgdp "Real GDP"
label variable county_rgdppc "Real GDP per capita"
label variable county_lggdp "Log real GDP"
label variable county_lggdppc "Log real GDP per capita"
label variable lg_totalsol "Log total sum of lights"
label variable lg_urbansol "Log urban sum of lights"
label variable lg_ruralsol "Log rural sum of lights"
label variable lg_ruralnpp "Log NPP (net primary productivity) in rural"
label variable lg_nonagri "Log non agriculture GDP (real)"
label variable lg_agri "Log agriculture GDP (real)"
label variable lg_ind "Log industry GDP (real)"
label variable lg_ser "Log service GDP (real)"

** 5. Save dta file
save "/Users/yilinchen/Documents/PhD/thesis/data/county_longpanel.dta"





