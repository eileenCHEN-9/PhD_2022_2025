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

*** Total ln non-agriculture GDP vs. lnNTL
  ****TWFE via xtreg 
  eststo m0C: xtreg lg_nonagri lg_totalsol i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m0D: twfem reg lg_nonagri lg_totalsol, absorb(city_id year) gen(icity_id1 year1) newv(r1_) vce(robust)
  label variable r1_lg_nonagri "Log non-agriculture GDP"
  label variable r1_lg_totalsol  "Log sum NTL"

aaplot r1_lg_nonagri r1_lg_totalsol, aformat(%9.2f) bformat(%9.2f) ylabel(, nolabel) name(fig1)

*** Total ln industry GDP vs. lnNTL
  ****TWFE via xtreg 
  eststo m0C: xtreg lg_ind lg_totalsol i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m0D: twfem reg lg_ind lg_totalsol, absorb(city_id year) gen(icity_id2 year2) newv(r2_) vce(robust)
  label variable r2_lg_ind "Log industry GDP"
  label variable r2_lg_totalsol  "Log sum NTL"

aaplot r2_lg_ind r2_lg_totalsol, aformat(%9.2f) bformat(%9.2f) ylabel(, nolabel) name(fig2)

*** Total ln services GDP vs. lnNTL
  ****TWFE via xtreg 
  eststo m0C: xtreg lg_ser lg_totalsol i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m0D: twfem reg lg_ser lg_totalsol, absorb(city_id year) gen(icity_id3 year3) newv(r3_) vce(robust)
  label variable r3_lg_ser "Log services GDP"
  label variable r3_lg_totalsol  "Log sum NTL"

aaplot r3_lg_ser r3_lg_totalsol, aformat(%9.2f) bformat(%9.2f) ylabel(, nolabel) name(fig3)

*** Total ln agriculture GDP vs. lnNTL
  ****TWFE via xtreg 
  eststo m0C: xtreg lg_agri lg_totalsol i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m0D: twfem reg lg_agri lg_totalsol, absorb(city_id year) gen(icity_id4 year4) newv(r4_) vce(robust)
  label variable r4_lg_agri "Log agriculture GDP"
  label variable r4_lg_totalsol  "Log sum NTL"

aaplot r4_lg_agri r4_lg_totalsol, aformat(%9.2f) bformat(%9.2f) ylabel(, nolabel) name(fig4)

*** Total ln agriculture GDP vs. lnNPP
  ****TWFE via xtreg 
  eststo m0C: xtreg lg_agri lg_ruralnpp i.year, fe vce(robust)
  **** TWFE via FWL
  eststo m0D: twfem reg lg_agri lg_ruralnpp, absorb(city_id year) gen(icity_id5 year5) newv(r5_) vce(robust)
  label variable r5_lg_agri "Log agriculture GDP"
  label variable r5_lg_ruralnpp  "Log average NPP"

aaplot r5_lg_agri r5_lg_ruralnpp, aformat(%9.2f) bformat(%9.2f) ylabel(, nolabel) name(fig5)

** Combine graphs
graph combine fig1 fig2 fig3, col(3) ycommon xcommon iscale(0.8)

graph combine fig4 fig5, col(2) ycommon xcommon iscale(0.8)

***Add individual graphs
**Predict sectoral GDP

xtreg lg_ind lg_totalsol i.year,fe robust
predict y_predicted1, xbu
rename y_predicted1 lg_ind_predicted

xtreg lg_ser lg_totalsol i.year,fe robust
predict y_predicted2, xbu
rename y_predicted2 lg_ser_predicted

xtreg lg_agri lg_totalsol i.year,fe robust
predict y_predicted3, xbu
rename y_predicted3 lg_agri_predicted1

xtreg lg_nonagri lg_totalsol i.year,fe robust
predict y_predicted4, xbu
rename y_predicted4 lg_nonagri_predicted1

**Non-agriculture
*Beijing(110000)
keep if city_id == 110000
twoway (scatter lg_nonagri_predicted1 year) (lfit lg_nonagri year), legend(off) ytitle("Log GDP (non-agriculture)") xtitle("Year") title("Beijing") name(fig6)

twoway (scatter lg_agri_predicted1 year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Beijing") name(fig66)

twoway (scatter lg_ind_predicted year) (lfit lg_ind year), legend(off) ytitle("Log GDP (industry)") xtitle("Year") title("Beijing") name (fig7)

twoway (scatter lg_ser_predicted year) (lfit lg_ser year), legend(off) ytitle("Log GDP (services)") xtitle("Year") title("Beijing") name (fig8)

graph combine fig7 fig8 fig6, col(3) ycommon xcommon iscale(0.8)

*Shanghai(310000)
keep if city_id == 310000
twoway (scatter lg_nonagri_predicted year) (lfit lg_nonagri year), legend(off) ytitle("Log GDP (non-agriculture)") xtitle("Year") title("Shanghai") name(fig9)

twoway (scatter lg_agri_predicted1 year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Shanghai") name(fig99)

twoway (scatter lg_ind_predicted year) (lfit lg_ind year), legend(off) ytitle("Log GDP (industry)") xtitle("Year") title("Shanghai") name(fig10)

twoway (scatter lg_ser_predicted year) (lfit lg_ser year), legend(off) ytitle("Log GDP (services)") xtitle("Year") title("Shanghai") name(fig11)

graph combine fig10 fig11 fig9, col(3) ycommon xcommon iscale(0.8)

*Shenzhen(440300)
keep if city_id == 440300
twoway (scatter lg_nonagri_predicted1 year) (lfit lg_nonagri year), legend(off) ytitle("Log GDP (non-agriculture)") xtitle("Year") title("Shenzhen") name(fig12)

twoway (scatter lg_agri_predicted1 year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Shenzhen") name(fig13)

twoway (scatter lg_ind_predicted year) (lfit lg_ind year), legend(off) ytitle("Log GDP (industry)") xtitle("Year") title("Shenzhen") name(fig14)

twoway (scatter lg_ser_predicted year) (lfit lg_ser year), legend(off) ytitle("Log GDP (services)") xtitle("Year") title("Shenzhen") name(fig15)

graph combine fig14 fig15 fig12, col(3) ycommon xcommon iscale(0.8)

**Agriculture
*Qitaihe(230900)
keep if city_id == 230900
twoway (scatter lg_agri_predicted year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Qitaihe") name(fig15)
 
*Ya an(511800)
keep if city_id == 511800
twoway (scatter lg_agri_predicted year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Ya'an") name(fig16)

*Kashi(653100)
keep if city_id == 653100
twoway (scatter lg_agri_predicted year) (lfit lg_agri year), legend(off) ytitle("Log GDP (agriculture)") xtitle("Year") title("Kashi") name(fig17)


