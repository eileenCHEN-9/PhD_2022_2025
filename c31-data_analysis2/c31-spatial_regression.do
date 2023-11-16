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
replace agri_gdp = agri_gdp / 100
replace ind_gdp = ind_gdp / 100
replace ser_gdp = ser_gdp / 100
gen agri_gdp_2 = agri_gdp*agri_gdp
gen ind_gdp_2 = ind_gdp*ind_gdp
gen ser_gdp_2 = ser_gdp*ser_gdp
gen nonagri_gdp_2 = nonagri_gdp*nonagri_gdp

label variable lg_gdppc_predicted_2 "Square of log predicted GDP per capita"
label variable agri_gdp_2 "Square of share of agricultural GDP"
label variable nonagri_gdp_2 "Square of share of non-agricultural GDP"

describe
summarize

*** 3. Run regressions
*Set panel	
xtset city_id year
xi i.year
xi i.city_id
set matsize 11000

**Non-spatial
*TWFE kuznets curve
xtreg GINIW_light_pc lg_gdppc_predicted i.year,fe robust
outreg2 using "../results/result2/tab21-1.tex", replace keep(lg_gdppc_predicted lg_gdppc_predicted_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

xtreg GINIW_light_pc lg_gdppc_predicted lg_gdppc_predicted_2 i.year,fe robust
outreg2 using "../results/result2/tab21-1.tex", append keep(lg_gdppc_predicted lg_gdppc_predicted_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

***Structural change
xtreg GINIW_light_pc agri_gdp i.year,fe robust
outreg2 using "../results/result2/tab21-2.tex", replace keep(agri_gdp agri_gdp_2 nonagri_gdp nonagri_gdp_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
xtreg GINIW_light_pc agri_gdp agri_gdp_2 i.year,fe robust
outreg2 using "../results/result2/tab21-2.tex", append keep(agri_gdp agri_gdp_2 nonagri_gdp nonagri_gdp_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
xtreg GINIW_light_pc nonagri_gdp i.year,fe robust
outreg2 using "../results/result2/tab21-2.tex", append keep(agri_gdp agri_gdp_2 nonagri_gdp nonagri_gdp_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label
xtreg GINIW_light_pc nonagri_gdp nonagri_gdp_2 i.year,fe robust
outreg2 using "../results/result2/tab21-2.tex", append keep(agri_gdp agri_gdp_2 nonagri_gdp nonagri_gdp_2) ctitle(Regional inequality) addtext(Regional FE, Yes, Year FE, Yes) dec(3) label

**Spatial model
*save my panel data
sysuse Main_Dataset
save, replace

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

**OLS: Non spatial model
**OLS Fixed Effect
sysuse city_edited_thiessen_fullpanel
xtset _ID year

*agriculture
eststo mod1: quietly xtreg GINIW_light_pc agri_gdp agri_gdp_2 i.year,fe robust cluster(ID)
quietly estadd local FE_city "Yes", replace
quietly estadd local FE_year "Yes", replace

*non-agriculture
eststo mod2: quietly xtreg GINIW_light_pc nonagri_gdp nonagri_gdp_2 i.year,fe robust cluster(ID)
quietly estadd local FE_city "Yes", replace
quietly estadd local FE_year "Yes", replace

* Compile professional regression table
#delimit;
    esttab mod1 mod2,
    keep(agri_gdp agri_gdp_2 nonagri_gdp nonagri_gdp_2)
    se
    label 
    stats(N N_g r2_a FE_country FE_year, 
        fmt(0 0 2)
        label("Observations" "N Cities" "R-squared" "City FE" "Year FE"))
    mtitles(" " " " " ") 
    nonotes
    addnote("Notes: The dependent variable is the populuation weighted regional Gini index." 
            "Robusts standard errors are adjusted for clustering at the country level"
						"All models include a constant"
            "* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    compress
    replace;
#delimit cr

**The spatial model: SDM
*SDM Fixed Effect Model 
sysuse city_edited_thiessen_fullpanel

*spmat import Wi using Wa

quietly xsmle GINIW_light_pc agri_gdp agri_gdp_2, wmat (Wi) model (sdm) fe type (both) effects
quietly estat ic
eststo model3

quietly xsmle GINIW_light_pc nonagri_gdp nonagri_gdp_2, wmat (Wi) model (sdm) fe type (both) effects
quietly estat ic
eststo model4

esttab, r2 aic bic

estimates store sdm_fe

**Wald test
quietly xsmle GINIW_light_pc agri_gdp agri_gdp_2, fe type(both) leeyu wmat(Wi) mod(sdm) effects
*Reduce to SAR? (NO if p < 0.05)
test ([Wx]agri_gdp = 0) ([Wx]agri_gdp_2 = 0)
*Reduce to SLX? (NO if p < 0.05)
test ([Spatial]rho = 0)
*Reduce to SEM? (NO if p < 0.05)
testnl ([Wx]agri_gdp = -[Spatial]rho*[Main]agri_gdp) ([Wx]agri_gdp_2 = -[Spatial]rho*[Main]agri_gdp_2)










