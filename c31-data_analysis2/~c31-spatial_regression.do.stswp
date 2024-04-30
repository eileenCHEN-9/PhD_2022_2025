cls
**==========================================
** Program Name: Generate main dataset
** Author: Yilin Chen
** Date: 2023-11-12
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

gen lg_gdppc_predicted_2 = lg_gdppc_predicted*lg_gdppc_predicted
*replace agri_gdp = agri_gdp / 100
*replace ind_gdp = ind_gdp / 100
*replace ser_gdp = ser_gdp / 100
*gen nonagri_predicted = exp(lg_nonagri_predicted)
gen lg_nonagri_predicted_2 = lg_nonagri_predicted*lg_nonagri_predicted
*gen agri_predicted = exp(lg_agri_predicted)
gen lg_agri_predicted_2 = lg_agri_predicted*lg_agri_predicted
*gen ser_gdp_2 = ser_gdp*ser_gdp
gen urban_pop_percent = urban_pop/total_population

*label variable nonagri_predicted "Share of non-agricultural GDP"
label variable lg_nonagri_predicted_2 "Square of share of non-agricultural GDP"
label variable lg_agri_predicted_2 "Square of share of agricultural GDP"
label variable lg_gdppc_predicted_2 "Square of per capita GDP (predicted)"
label variable urban_pop_percent "Urbanisation"

describe
summarize

*** 3. Run regressions
*Set panel	
xtset city_id year
*xi i.year
*xi i.city_id
*set matsize 11000

**Non-spatial
*Non-spatail TWFE kuznets curve
xtreg GINIW_light_pc lg_gdppc_predicted i.year,fe robust
outreg2 using "../results/result2/table/tab21-0.tex", replace keep(lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 i.year,fe robust
outreg2 using "../results/result2/table/tab21-0.tex", append keep(lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent i.year,fe robust
outreg2 using "../results/result2/table/tab21-0.tex", append keep(lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

***Non-spatial Structural change-1
xtreg GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp urban_pop_percent i.year,fe robust
outreg2 using "../results/result2/table/tab21-1.tex", replace keep(lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp nonagri_gdp urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 nonagri_gdp urban_pop_percent i.year,fe robust
outreg2 using "../results/result2/table/tab21-1.tex", append keep(lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp nonagri_gdp urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

***Non-spatial Structural change-2
xtreg GINIW_light_pc lg_agri_predicted i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", replace keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_agri_predicted lg_agri_predicted_2 i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", append keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_nonagri_predicted i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", append keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_nonagri_predicted lg_nonagri_predicted_2 i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", append keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_agri_predicted lg_agri_predicted_2 urban_pop_percent i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", append keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent i.year,fe robust
outreg2 using "../results/result2/table/tab21-2.tex", append keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

**Spatial model
*save my panel data
sysuse Main_Dataset
save, replace
*save Main_Dataset.dta, replace

*Import and translate to stata shape file
spshape2dta "city_edited_thiessen", replace

*Explore my spatial data: myMAP
use city_edited_thiessen

*Describe and summarize myMAP.dta
describe
summarize

*Change the spatial-unit id from _ID to fips
spset _ID, modify replace

*Modify the coordinate system from planar to latlong
spset, modify coordsys(latlong, miles)

*Check spatial ID and coordinate system
spset

**Merge with myPANEL data : data3.dta
sysuse Main_Dataset
xtset city_id year 
spbalance 
merge m:1 city_id using city_edited_thiessen
keep if _merge==3 
drop _merge
tset

**Save the merge of my map and panel data
save city_edited_thiessen_fullpanel,replace 

**Describe the new dataset
sysuse city_edited_thiessen_fullpanel
describe

*Create queen contiguity weight matrix
spwmatrix import using "city_edited_thiessen.gal", wname(Wa) rowstand

***Spatial regression model
sysuse city_edited_thiessen_fullpanel
*\\\\\spmat import Wi using Wa

**Wald test
quietly xsmle GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp urban_pop_percent, fe type(both) leeyu wmat(Wa) mod(sdm) effects
*Reduce to SAR? (NO if p < 0.05)
test ([Wx]lg_gdppc_predicted = 0) ([Wx]lg_gdppc_predicted_2 = 0) ([Wx]agri_gdp = 0) ([Wx]urban_pop_percent = 0) 
*Reduce to SLX? (NO if p < 0.05)
test ([Spatial]rho = 0)
*Reduce to SEM? (NO if p < 0.05)
testnl ([Wx]lg_gdppc_predicted = -[Spatial]rho*[Main]lg_gdppc_predicted) ([Wx]lg_gdppc_predicted_2 = -[Spatial]rho*[Main]lg_gdppc_predicted_2) ([Wx]agri_gdp = -[Spatial]rho*[Main]agri_gdp) ([Wx]urban_pop_percent = -[Spatial]rho*[Main]urban_pop_percent)

quietly xsmle GINIW_light_pc lg_agri_predicted lg_agri_predicted_2 urban_pop_percent, fe type(both) leeyu wmat(Wa) mod(sdm) effects
*Reduce to SAR? (NO if p < 0.05)
test ([Wx]lg_agri_predicted = 0) ([Wx]lg_agri_predicted_2 = 0) ([Wx]urban_pop_percent = 0) 
*Reduce to SLX? (NO if p < 0.05)
test ([Spatial]rho = 0)
*Reduce to SEM? (NO if p < 0.05)
testnl ([Wx]lg_agri_predicted = -[Spatial]rho*[Main]lg_agri_predicted) ([Wx]lg_agri_predicted_2 = -[Spatial]rho*[Main]lg_agri_predicted_2) ([Wx]urban_pop_percent = -[Spatial]rho*[Main]urban_pop_percent)

**Spatial Kuznets Curve & Spatial Structural change-1 (SDM)
xsmle GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm1
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace


xsmle GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm2
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 nonagri_gdp urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm3
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

#delimit;
    esttab sdm1 sdm2 sdm3,
    keep(lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp nonagri_gdp urban_pop_percent rho)
    se
    label 
    stats(N N_g r2 FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Cities" "R-squared" "City FE" "Year FE"))
    mtitles(" " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
						"All models include a constant"
            "* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    compress
    replace;
#delimit cr

#delimit;
    esttab sdm1 sdm2 sdm3 using "../results/result2/table/tab22-1.tex",
    keep(lg_gdppc_predicted lg_gdppc_predicted_2 agri_gdp nonagri_gdp urban_pop_percent rho)
    se
    label 
    stats(N N_g r2 FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Countries" "R-squared" "City FE" "Year FE"))
    mtitles(" " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
            "All models include a constant"
            "$* p<0.10, ** p<0.05, *** p<0.01$")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    replace;
#delimit cr

**Spatial structural change-2 (SDM & SAR)
xsmle GINIW_light_pc lg_agri_predicted lg_agri_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm4
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle GINIW_light_pc lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sdm) effects nsim(999) nolog
estimate store sdm5
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle GINIW_light_pc lg_agri_predicted lg_agri_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sar) effects nsim(999) nolog
estimate store sar4
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

xsmle GINIW_light_pc lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent, fe type(both) wmat(Wa) mod(sar) effects nsim(999) nolog
estimate store sar5
quietly estadd local FE_city   "Yes", replace
quietly estadd local FE_year   "Yes", replace

#delimit;
    esttab sdm4 sdm5 sar4 sar5,
    keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent rho)
    se
    label 
    stats(N N_g r2 aic bic FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Cities" "R-squared" "AIC" "BIC" "City FE" "Year FE"))
    mtitles(" " " " " " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
						"All models include a constant"
            "* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    compress
    replace;
#delimit cr

#delimit;
    esttab sar4 sar5 using "../results/result2/table/tab22-2.tex",
    keep(lg_agri_predicted lg_agri_predicted_2 lg_nonagri_predicted lg_nonagri_predicted_2 urban_pop_percent rho)
    se
    label 
    stats(N N_g r2 FE_city FE_year, 
        fmt(0 0 2)
        label("Observations" "N Countries" "R-squared" "City FE" "Year FE"))
    mtitles(" " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the GINI index in each city." 
            "All models include a constant"
            "$* p<0.10, ** p<0.05, *** p<0.01$")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    replace;
#delimit cr








