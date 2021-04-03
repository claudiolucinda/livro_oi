* This program calculates all of the results for "Vertical Arrangements, Market Structure, and Competition: An Analysis of Restructured U.S. Electricity Markets." This do file includes detailed descriptions of the variables and the contents of each data file.

clear
program drop _all
set more off
set matsize 800
set memory 100m 

* enter today's date here
global date 20080110

* enter your directory here
chdir C:\data\3market\AER\200507_data\Stata_data

program define DO
* This program runs each component of the results for the paper. To see the results of just one part, add a star to the front of the others. Note that readdata must be run once before any of the other programs will work.
fringesup
readdata 
SUMUP
FIGURES
PERTURB
QUANTITIES
WELFARE 
NONNEST
end

program define fringesup
* This program calculates the elasticity of fringe supply from net imports. It draws on the program regs that is described below. We estimate the fringe price response for several functional forms.
capture log close
log using fringesup_$date.log, replace
disp "Main Results: Linear-Log Model"
regs 1
disp "Alternative Results: Linear Model"
regs 2
disp "Alternative Results: Square Root Model"
regs 3
disp "Alternative Results: Cubic Root Model"
regs 4
log close
end

program define regs
* This program estimates the price elasticity of net import supply for each market. This program uses the mkvars program defined below.
qui use california.dta, clear
* This dataset includes price, load, fringe quantity supplied, and weather data for California.
keep if DATE>19990600 & DATE<19991000
global weather TUE-SUN HR* MY* hight1* lowt1* hight3* lowt3* hight4* lowt4* lhight1* llowt1* lhight3* llowt3* lhight4* llowt4*
qui g byte peak = 0
qui replace peak = 1 if HOUR > 10 & HOUR < 21
qui replace peak = 0 if SAT | SUN
qui rename Q_frg fringe
qui rename lnp price
qui rename lnI load
mkvars `1' 1
qui use newengland.dta, clear
* This dataset includes price, load, fringe quantity supplied, and weather data for New England.
keep if DATE>19990600 & DATE<19991000
qui sort DATE HOUR
qui g T = _n
global weather MON-SAT MY199907-MY199909 HR* lowt8* higt8* 
qui g byte peak = 0
qui replace peak = 1 if (HOUR > 10 & HOUR < 21) & (MON | TUE | WED | THU | FRI)
qui rename lnactp price
qui rename lnqdem load
mkvars `1' 2
qui use pjm.dta, clear
* This dataset includes price, load, fringe quantity supplied, and weather data for PJM.
keep if DATE>19990600 & DATE<19991000
qui global weather _IMOYR* _IHOUR* MON-SAT COOL5-HEATSQ8
qui g byte peak = 0
qui replace peak = 1 if (HOUR > 10 & HOUR < 21) & (MON | TUE | WED | THU | FRI)
qui rename IMPORT fringe
qui rename LNP price
qui rename LNL load
mkvars `1' 3
end

program define mkvars
* This program calculates the variables and runs 2SLS for each of the four functional form specifications.
if `1' == 2 {
qui replace price = exp(price)
qui replace load = exp(load)
}
if `1' == 3 {
qui replace price = (exp(price))^(1/2)
qui replace load = (exp(load))^(1/2)
}
if `1' == 4 {
qui replace price = (exp(price))^(1/3)
qui replace load = (exp(load))^(1/3)
}
qui ivreg fringe (price = load) $weather
qui predict E, resid
qui sort T
qui g E1 = E[_n-1]
qui reg E E1, noc
qui g RHO = _b[E1]
global VARS fringe price load $weather 
qui for var $VARS: sort T \ g temp = X - RHO*X[_n-1] \ g DX = temp \ drop temp
if `2' == 1 {
global Dweather DTUE-Dllowt419 
disp "California " `1' "." `2'
}
if `2' == 2 {
global Dweather DMON-Dhigt84s
disp "New England " `1' "." `2'
}
if `2' == 3 {
global Dweather D_IMOYR* D_IHOUR* DMON-DSAT DCOOL5-DHEATSQ8
disp "PJM " `1' "." `2'
}
ivreg Dfringe (Dprice = Dload) $Dweather, rob 
end

program define readdata
* This program draws on many input files to collect data for the summary statistics program and the figures programs.
use quantities.dta, clear
* This dataset includes information on the month and year, the hour of the month (time), and the ratio of current hourly demand to summer peak demand.
sort moyr time 
save kernels_$date.dta, replace

use neout99compboot.dta, clear 
* This dataset includes information on actual prices in New England.
duplicates drop
drop if boot == .
keep if boot == 1
keep moyr time p_act
rename p_act p_act_ne
sort moyr time
merge moyr time using kernels_$date.dta 
drop _merge
replace p_act_ne = 1000 if p_act_ne > 1000
sort moyr time 
save kernels_$date.dta, replace

use neout99log_full.dta, clear
* This dataset includes information on the Cournot price (accounting for vertical arrangements), as well as other variables for calculating the standard errors in the non-nested tests, and the confidence intervals in New England.
duplicates drop
keep moyr time boot p_sim
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim 
reshape wide sim, i(moyr time) j(run)
rename simp1 courn_ne
rename simp2 courng1_ne
rename simp3 courng2_ne
rename simp4 pmax_ne
rename simp5 pmin_ne
sort moyr time
merge moyr time using kernels_$date.dta
drop _merge
sort moyr time
save kernels_$date.dta, replace
use neout99log_nc_full.dta, clear
* This dataset includes information on the Cournot price (assuming no vertical arrangements) in New England.
keep if boot == 1
duplicates drop
keep moyr time p_sim
rename p_sim p_nc_ne
replace p_nc_ne = 1000 if p_nc_ne > 1000
sort moyr time 
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace

use neout99log_comp_full.dta, clear
* This dataset includes information on the perfectly competitive price in New England.
keep if boot == 1
duplicates drop
keep moyr time p_sim 
rename p_sim pcomp_ne 
replace pcomp_ne = 1000 if pcomp_ne > 1000
sort moyr time
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace
use pjmout99_boot.dta, clear
* This dataset includes information on the actual price, the Cournot price (accounting for vertical arrangements), as well as other variables for calculating the standard errors in the non-nested tests, and the confidence intervals in PJM.
duplicates drop
keep moyr time boot p_sim p_act
rename p_sim simp
rename p_act actp
replace simp = 1000 if simp > 1000
replace actp = 1000 if actp > 1000
rename boot run
sort moyr time run
order moyr time run sim act
reshape wide sim act, i(moyr time) j(run)
drop actp2 actp3 actp4 actp5
rename actp1 p_act_pjm
rename simp1 courn_pjm
rename simp2 courng1_pjm
rename simp3 courng2_pjm
rename simp4 pmax_pjm
rename simp5 pmin_pjm
sort moyr time
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace
use pjmout99_log_nc_full.dta, clear
* This dataset includes information on the Cournot price (assuming no vertical arrangements) in PJM.
duplicates drop
keep if boot == 1
keep moyr time p_sim
rename p_sim p_nc_pjm
replace p_nc_pjm = 1000 if p_nc_pjm > 1000
sort moyr time 
merge moyr time using kernels_$date.dta
drop _
replace p_nc_pjm = 1000 if p_nc_pjm == .
sort moyr time
save kernels_$date.dta, replace
use pjmout99comp_boot.dta, clear
* This dataset includes information on the perfectly competitive price in PJM.
keep if boot == 1
duplicates drop
keep moyr time p_sim 
rename p_sim pcomp_pjm 
replace pcomp_pjm = 1000 if pcomp_pjm > 1000
sort moyr time
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace
use calout99_boot.dta, clear
* This dataset includes information on the actual price, the Cournot price (accounting for vertical arrangements), as well as other variables for calculating the standard errors in the non-nested tests, and the confidence intervals in California.
duplicates drop
keep moyr time boot p_sim p_act
rename p_sim simp
rename p_act actp
replace simp = 250 if simp > 250
replace actp = 250 if actp > 250
rename boot run
sort moyr time run
order moyr time run sim act
reshape wide sim act, i(moyr time) j(run)
drop actp2 actp3 actp4 actp5
rename actp1 p_act_cal
rename simp1 courn_cal
rename simp2 courng1_cal
rename simp3 courng2_cal
rename simp4 pmax_cal
rename simp5 pmin_cal
sort moyr time
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace
use calout99comp_boot.dta, clear
* This dataset includes information on the perfectly competitive price in PJM.
keep if boot == 1
duplicates drop
keep moyr time p_sim 
rename p_sim pcomp_cal 
replace pcomp_cal = 250 if pcomp_cal > 250
sort moyr time
merge moyr time using kernels_$date.dta
drop _
sort moyr time
save kernels_$date.dta, replace
kernels
labels
end

program define kernels
* This program estimates the nearest neighbors kernel regression for each of the main prices that we report in the figures.
use kernels_$date.dta, clear
qui knnreg courn_ne demrat_ne, k(100) g(ckern_ne) nograph
qui knnreg p_act_ne demrat_ne, k(100) g(pkern_ne) nograph 
qui knnreg pcomp_ne demrat_ne, k(100) g(mckern_ne) nograph 
qui knnreg pmin_ne demrat_ne, k(100) g(minkern_ne) nograph 
qui knnreg pmax_ne demrat_ne, k(100) g(maxkern_ne) nograph 
qui knnreg p_nc_ne demrat_ne, k(100) g(ckern_nc_ne) nograph 
qui knnreg courn_pjm demrat_pjm, k(100) g(ckern_pjm) nograph
qui knnreg p_act_pjm demrat_pjm, k(100) g(pkern_pjm) nograph 
qui knnreg pcomp_pjm demrat_pjm, k(100) g(mckern_pjm) nograph 
qui knnreg pmin_pjm demrat_pjm, k(100) g(minkern_pjm) nograph 
qui knnreg pmax_pjm demrat_pjm, k(100) g(maxkern_pjm) nograph 
qui knnreg p_nc_pjm demrat_pjm, k(100) g(ckern_nc_pjm) nograph 
qui knnreg courn_cal demrat_cal, k(100) g(ckern_cal) nograph
qui knnreg p_act_cal demrat_cal, k(100) g(pkern_cal) nograph 
qui knnreg pcomp_cal demrat_cal, k(100) g(mckern_cal) nograph 
qui knnreg pmin_cal demrat_cal, k(100) g(minkern_cal) nograph 
qui knnreg pmax_cal demrat_cal, k(100) g(maxkern_cal) nograph 
order moyr time p_act_ne demrat_ne pcomp_ne courn_ne pmin_ne pmax_ne ckern_ne pkern_ne mckern_ne minkern_ne maxkern_ne ckern_nc_ne p_act_pjm demrat_pjm pcomp_pjm courn_pjm pmin_pjm pmax_pjm ckern_pjm pkern_pjm mckern_pjm minkern_pjm maxkern_pjm ckern_nc_pjm p_act_cal demrat_cal pcomp_cal courn_cal pmin_cal pmax_cal ckern_cal pkern_cal mckern_cal minkern_cal maxkern_cal 
sort moyr time
g T = _n
order moyr time T
tsset T
sort moyr time
save kernels_$date.dta, replace
end

program define labels
* This program adds labels to the main variables used in the figures.
use kernels_$date.dta, clear
label var moyr "Month and year"
label var time "Day of Month"
label var T "counter"
label var p_act_ne "Actual Price"
label var demrat_ne "Installed Capacity Share in New England"
label var pcomp_ne "Competitive Price"
label var courn_ne "Cournot Price w/ Contracts"
label var pmin_ne "Cournot Price Upper Bound"
label var pmax_ne "Cournot Price Lower Bound"
label var p_nc_ne "Cournot Price"
label var ckern_ne "Cournot Price Kernel"
label var pkern_ne "Actual Price Kernel"
label var mckern_ne "Competitive Price Kernel"
label var minkern_ne "Cournot Price Kernel Upper Bound"
label var maxkern_ne "Cournot Price Kernel Lower Bound"
label var ckern_nc_ne "Cournot Price Kernel"
label var demrat_pjm "Installed Capacity Share in PJM"
label var p_act_pjm "Actual Price"
label var pcomp_pjm "Competitive Price"
label var courn_pjm "Cournot Price w/ Contracts"
label var pmin_pjm "Cournot Price Upper Bound"
label var pmax_pjm "Cournot Price Lower Bound"
label var p_nc_pjm "Cournot Price"
label var ckern_pjm "Cournot Price Kernel"
label var pkern_pjm "Actual Price Kernel"
label var mckern_pjm "Competitive Price Kernel"
label var minkern_pjm "Cournot Price Kernel Upper Bound"
label var maxkern_pjm "Cournot Price Kernel Lower Bound"
label var ckern_nc_pjm "Cournot Price Kernel"
label var demrat_cal "Installed Capacity Share in California"
label var p_act_cal "Actual Price"
label var pcomp_cal "Competitive Price"
label var courn_cal "Cournot Price"
label var pmin_cal "Cournot Price Upper Bound"
label var pmax_cal "Cournot Price Lower Bound"
label var ckern_cal "Cournot Price Kernel"
label var pkern_cal "Actual Price Kernel"
label var mckern_cal "Competitive Price Kernel"
label var minkern_cal "Cournot Price Kernel Upper Bound"
label var maxkern_cal "Cournot Price Kernel Lower Bound"
format p_act_ne-maxkern_cal p_nc_ne p_nc_pjm  p_act_ne %9.2f
sort moyr time
save kernels_$date.dta, replace
end 

program define SUMUP
* This program provides summary statistics of the prices.
capture log close
log using results_$date.log, replace
use kernels_$date.dta, clear
sum p_act_cal pcomp_cal courn_cal , f
sum p_act_ne  pcomp_ne  courn_ne p_nc_ne, f
sum p_act_pjm pcomp_pjm courn_pjm p_nc_pjm, f
sum p_act_cal pcomp_cal courn_cal  if peak, f
sum p_act_ne  pcomp_ne  courn_ne p_nc_ne if peak, f
sum p_act_pjm pcomp_pjm courn_pjm p_nc_pjm if peak, f
sum p_act_cal pcomp_cal courn_cal  if peak==0, f
sum p_act_ne  pcomp_ne  courn_ne p_nc_ne if peak==0, f
sum p_act_pjm pcomp_pjm courn_pjm p_nc_pjm if peak==0, f
sum p_act_cal, f d
sum pcomp_cal, f d
sum courn_cal, f d
sum p_act_ne, f d
sum pcomp_ne, f d
sum courn_ne, f d
sum p_nc_ne , f d
sum p_act_pjm, f d
sum pcomp_pjm, f d
sum courn_pjm, f d
sum p_nc_pjm , f d
sum p_act_cal if peak, f d
sum pcomp_cal if peak, f d
sum courn_cal if peak, f d
sum p_act_ne if peak, f d
sum pcomp_ne if peak, f d
sum courn_ne if peak, f d
sum p_nc_ne  if peak, f d
sum p_act_pjm if peak, f d
sum pcomp_pjm if peak, f d
sum courn_pjm if peak, f d
sum p_nc_pjm  if peak, f d
sum p_act_cal if peak==0, f d
sum pcomp_cal if peak==0, f d
sum courn_cal if peak==0, f d
sum p_act_ne if peak==0, f d
sum pcomp_ne if peak==0, f d
sum courn_ne if peak==0, f d
sum p_nc_ne  if peak==0, f d
sum p_act_pjm if peak==0, f d
sum pcomp_pjm if peak==0, f d
sum courn_pjm if peak==0, f d
sum p_nc_pjm  if peak==0, f d
sum p_act_ne if peak==0 & moyr == 199909, f d
sum pcomp_ne if peak==0 & moyr == 199909, f d
sum courn_ne if peak==0 & moyr == 199909, f d
sum pcomp_ne if peak==0 & moyr == 199908, f d
sum courn_ne if peak==0 & moyr == 199908, f d
qui use kernels_$date.dta, clear
qui keep if peak 
R2
qui use kernels_$date.dta, clear
qui keep if peak == 0
R2
qui use kernels_$date.dta, clear
R2
log close
end

program define R2
* This program calculates the goodness of fit of the simulated prices.
table moyr, c(mean p_act_cal mean pcomp_cal mean courn_cal)
table moyr, c(mean p_act_ne mean pcomp_ne mean courn_ne)
table moyr, c(mean p_act_pjm mean pcomp_pjm mean courn_pjm)
g errcourcal = p_act_cal - courn_cal
g errcompcal = p_act_cal - pcomp_cal
egen esscourcal = sum(errcourcal^2)
egen esscompcal = sum(errcompcal^2)
egen rsscal = sum(p_act_cal^2)
g r2courcal = 1 - esscourcal/ rsscal
g r2compcal = 1 - esscompcal/ rsscal
g errcourne = p_act_ne - courn_ne
g errcompne = p_act_ne - pcomp_ne
egen esscourne = sum(errcourne^2)
egen esscompne = sum(errcompne^2)
egen rssne = sum(p_act_ne^2)
g r2courne = 1 - esscourne/ rssne
g r2compne = 1 - esscompne/ rssne
g errcourpjm = p_act_pjm - courn_pjm
g errcomppjm = p_act_pjm - pcomp_pjm
egen esscourpjm = sum(errcourpjm^2)
egen esscomppjm = sum(errcomppjm^2)
egen rsspjm = sum(p_act_pjm^2)
g r2courpjm = 1 - esscourpjm/ rsspjm
g r2comppjm = 1 - esscomppjm/ rsspjm
sum r2*
end

program define FIGURES
* This program runs other programs that graph figures 1-10.
FIG1
FIG2
FIG3
FIG4
FIG5
FIG6
FIG7
FIG8
FIG9
FIG10
end

program define FIG1
* This program plots the price paths.
use prices, clear
* This dataset includes information on the actual prices in all three markets.
rename mpj pjm
rename MP calpx
rename MI caliso
rename mpr ne
g cal = calpx
replace cal = caliso if moyr>200011
g year = int(moyr/100)
g month= moyr-year*100
g date = mdy(month,1,year)
format date %dm_Y 
keep date moyr cal ne pjm
order date moyr cal ne pjm 
label var date " "
label var cal "California Price"
label var ne "New England Price"
label var pjm "PJM Price"
line cal ne pjm date, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(#5) xlabel(#10, angle(45)) ytitle(Prices in $/MWh) legend(position(2) ring(0) col(1)) title("Price Path in All Markets") subtitle("California, New England, and PJM Monthly Averages") note("California price is the PX price before December, 2000, and the ISO price afterwards.") 
graph export all_prices_pub.eps, as(eps) replace
end

program define FIG2
* This program graphs a kernel density of the prices on the ratio of current demand to the summer peak demand.
use kernels_$date.dta, clear
keep T demrat_ne demrat_pjm demrat_cal
rename demrat_ne d1
rename demrat_pjm d2
rename demrat_cal d3
reshape long d, i(T) j(market)
g str12 Market = "New England" if market==1
replace Market = "PJM" if market ==2
replace Market = "California" if market ==3
rename d Demand_Share
label var De "Ratio of Current Demand to Summer Peak Demand"
sort Market
by Market: sum De
twoway (( kdensity De if m==3, clcolor(gs1)) (kdensity De if m==1, clcolor(gs6)) (kdensity De if m==2, clcolor(gs13) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) title("Kernel Density of Demand by Market") legend(order(- "                       Mean" 1 2 3) label(1 "California        0.627") label(2 "New England  0.671") label(3 "PJM                 0.635") position(6) ring(0) col(1)) xtitle(Ratio of Current Demand to Summer Peak Demand) ytitle("Kernel Density") ylabel(#4,format(%9.2f)) ))
graph export histograms_pub.eps, as(eps) replace
end

program define FIG3 
* This program graphs the Actual, Competitive, and Cournot Price Kernels for California.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 1000
replace p_act_pjm = . if p_act_pjm > 1000
scatter p_act_cal demrat_cal, msymbol(p) mcolor(gs12) || line pkern_cal ckern_cal mckern_cal demrat_cal, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(0 25 50 75 100, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("Prices by Quantity Demanded in California") subtitle("Actual, Competitive, and Cournot Price Kernels") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export cal_main_pub.eps, as(eps) replace
end

program define FIG4
* This program graphs the Actual, Competitive, and Cournot Price Kernels for New England.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 1000
replace p_act_pjm = . if p_act_pjm > 1000
scatter p_act_ne demrat_ne, msymbol(p) mcolor(gs12) || line pkern_ne ckern_nc_ne mckern_ne demrat_ne, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(0 250 500 750 1000, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("Prices by Quantity Demanded in New England") subtitle("Actual, Competitive, and Cournot Price Kernels") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export ne_main_pub.eps, as(eps) replace
end

program define FIG5
* This program graphs the Actual, Competitive, and Cournot Price Kernels for PJM.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 1000
replace p_act_pjm = . if p_act_pjm > 1000
scatter p_act_pjm demrat_pjm, msymbol(p) mcolor(gs12) || line pkern_pjm ckern_nc_pjm mckern_pjm demrat_pjm, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(0 250 500 750 1000, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) title("Prices by Quantity Demanded in PJM") subtitle("Actual, Competitive, and Cournot Price Kernels") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export pjm_main_pub.eps, as(eps) replace
end

program define FIG6
* This program graphs the Cournot Price Kernels (with and without vertical arrangements) for New England.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 250
replace p_act_pjm = . if p_act_pjm > 500
scatter p_act_ne demrat_ne, msymbol(p) mcolor(gs12) || line pkern_ne ckern_ne mckern_ne demrat_ne if demrat_ne < 0.9224679, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(0 50 100 150 200 250, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("Vertical Arrangements in New England") subtitle("Actual, Competitive, and Cournot Price Kernels") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export ne_nc_pub.eps, as(eps) replace
end

program define FIG7
* This program graphs the Cournot Price Kernels (with and without vertical arrangements) for PJM.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 250
replace p_act_pjm = . if p_act_pjm > 500
scatter p_act_pjm demrat_pjm, msymbol(p) mcolor(gs12) || line pkern_pjm ckern_pjm mckern_pjm demrat_pjm if demrat_pjm < 0.9285236, sort clcolor(gs1 gs10 gs3) clpattern(solid solid dash) ylabel(0 100 200 300 400 500, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("Vertical Arrangements in PJM") subtitle("Actual, Competitive, and Cournot Price Kernels") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export pjm_nc_pub.eps, as(eps) replace 
end

program define FIG8
* This program graphs the Cournot Price Kernels and confidence intervals for California.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 250
replace p_act_pjm = . if p_act_pjm > 500
line pkern_cal ckern_cal minkern_cal maxkern_cal demrat_cal if demrat_cal < .8845606, sort clcolor(gs1 gs8 gs3 gs6) clpattern(solid solid dash dash) ylabel(0 25 50 75 100, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("California Cournot Sensitivity") subtitle("Cournot with 95 Percent Confidence Interval") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export cal_bounds_pub.eps, as(eps) replace
end

program define FIG9
use kernels_$date.dta, clear
* This program graphs the Cournot Price Kernels and confidence intervals for New England.
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 250
replace p_act_pjm = . if p_act_pjm > 500
line pkern_ne ckern_ne minkern_ne maxkern_ne demrat_ne if demrat_ne < 0.9224679, sort clcolor(gs1 gs8 gs3 gs6) clpattern(solid solid dash dash) ylabel(0 50 100 150 200 250, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("New England Cournot Sensitivity") subtitle("Cournot with 95 Percent Confidence Interval") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export ne_bounds_pub.eps, as(eps) replace
end

program define FIG10
* This program graphs the Cournot Price Kernels and confidence intervals for PJM.
use kernels_$date.dta, clear
replace p_act_cal = . if p_act_cal > 100
replace p_act_ne = . if p_act_ne > 250
replace p_act_pjm = . if p_act_pjm > 500
line pkern_pjm ckern_pjm minkern_pjm maxkern_pjm demrat_pjm if demrat_pjm < 0.9285236, sort clcolor(gs1 gs8 gs3 gs6) clpattern(solid solid dash dash) ylabel(0 100 200 300 400 500, format(%9.0f)) xlabel(0.40 0.60 0.80 1.00, format(%9.2f)) ytitle(Prices in $/MWh) xtitle(Ratio of Current Demand to Summer Peak Demand) legend(position(11) ring(0) col(1)) title("PJM Cournot Sensitivity") subtitle("Cournot with 95 Percent Confidence Interval") note("We calculate nonparametric regressions using the k-Nearest Neighbor estimator.") 
graph export pjm_bounds_pub.eps, as(eps) replace
end

program define PERTURB
* This program calculates the change in profits from deviations in each major firm's vertical positions.
capture log close
log using perturb_$date.log, replace
use cal99_log_vert.dta, clear 
* This dataset includes information on the profits of each firm in California under various scenarios whereby a given firm's vertical position was slightly deviated (see paper for details).
keep COUNT FIRM pi
g firm = 0
replace firm = 1 if FIRM == "AES"
replace firm = 2 if FIRM == "DUKE"
replace firm = 3 if FIRM == "DYN"
replace firm = 4 if FIRM == "MIR"
replace firm = 5 if FIRM == "REL"
rename COUNT run
rename pi profit
collapse (sum) profit, by(firm run)
reshape wide profit, i(firm) j(run)
for num 1/5: replace profitX=(profitX-profit0)/ profit0
replace profit0=profit0/10^6
list
use ne99_log_vert.dta, clear
* This dataset includes information on the profits of each firm in New England under various scenarios whereby a given firm's vertical position was slightly deviated (see paper for details).
g firm = 0
replace firm = 1 if FIRM == "NU"
replace firm = 2 if FIRM == "MIR_ne"
replace firm = 3 if FIRM == "PGE_ne"
replace firm = 4 if FIRM == "SITH"
replace firm = 5 if FIRM == "FPL"
replace firm = 6 if FIRM == "DUKE_ne"
replace firm = 7 if FIRM == "WISV"
rename COUNT run
rename pi profit
collapse (sum) profit, by(firm run)
reshape wide profit, i(firm) j(run)
for num 1/7: replace profitX=(profitX-profit0)/ profit0
replace profit0=profit0/10^6
list firm-profit5, sep(0)
list firm profit6-profit7, sep(0)
use pjm99_log_vert.dta, clear
* This dataset includes information on the profits of each firm in PJM under various scenarios whereby a given firm's vertical position was slightly deviated (see paper for details).
g firm = 0
replace firm = 1 if FIRM == "GPU"
replace firm = 2 if FIRM == "PECO"
replace firm = 3 if FIRM == "PPL"
replace firm = 4 if FIRM == "PEPCO"
replace firm = 5 if FIRM == "PSEG"
replace firm = 6 if FIRM == "BGE"
replace firm = 7 if FIRM == "DPL"
replace firm = 8 if FIRM == "ACE"
replace firm = 9 if FIRM == "HOMER"
rename COUNT run
rename pi profit
collapse (sum) profit, by(firm run)
reshape wide profit, i(firm) j(run)
for num 1/9: replace profitX=(profitX-profit0)/ profit0
replace profit0=profit0/10^6
list firm-profit5, sep(0)
list firm profit6-profit9, sep(0)
log close
clear
end

program define QUANTITIES
* This program compares differences in quantity estimates for each model.
capture log close
log using quantities_$date.log, replace
use calout99comp_log_full.dta, clear
* This dataset includes information on the output of each firm assuming perfect competition in California.
su q* if boo==1, sep(0)
use calout99_log_full.dta, clear
* This dataset includes information on the output of each firm assuming Cournot competition in California.
su q* if boo==1, sep(0)
use neout99log_comp_full.dta, clear
* This dataset includes information on the output of each firm assuming perfect competition in New England.
su q* if boo==1, sep(0)
use neout99log_full.dta, clear
* This dataset includes information on the output of each firm assuming Cournot competition (and vertical arrangements) in New England.
su q* if boo==1, sep(0)
use neout99log_nc_full.dta, clear
* This dataset includes information on the output of each firm assuming Cournot competition (but no vertical arrangements) in New England.
su q* if boo==1, sep(0)
use pjmout99comp_log_full.dta, clear
* This dataset includes information on the output of each firm assuming perfect competition in PJM.
su q* if boo==1, sep(0)
use pjmout99_log_full.dta, clear 
* This dataset includes information on the output of each firm assuming Cournot competition (and vertical arrangements) in PJM.
su q* if boo==1, sep(0)
log close
clear
end

program define WELFARE
* This program calculates the welfare gains associated with vertical arrangements in New England and in PJM.
capture log close
log using welfare_$date.log, replace
use neout99log_comp_full.dta, clear
keep if boot == 1
egen tccomp = rowtotal(TC*)
egen qcomp = rowtotal(q*)
keep moyr time p_sim elas tccomp qcomp
rename p_sim pcomp
sort moyr time
save welfare, replace
use neout99log_full.dta, clear
keep if boot == 1
egen tccour = rowtotal(TC*)
egen qcour = rowtotal(q*) 
keep moyr time p_sim elas tccour qcour 
rename p_sim pcour
rename elas elas2
sort moyr time
merge moyr time using welfare
tab _m
drop _m
g test1 = elas-elas2
egen test2 = max(abs(test1))
if test2 > 0 {
disp "error"
stop
}
drop test* elas2
sort moyr time
save welfare, replace
use neout99log_nc_full.dta, clear
* This dataset includes information on the output and total operating costs of each firm assuming Cournot competition (but no vertical arrangements) in New England.
keep if boot == 1
egen tccnc = rowtotal(TC*)
egen qcnc = rowtotal(q*) 
keep moyr time p_sim elas tccnc qcnc
rename p_sim pcnc
rename elas elas2
sort moyr time
merge moyr time using welfare
tab _m
drop _m
g test1 = elas-elas2
egen test2 = max(abs(test1))
if test2 > 0 {
disp "error"
stop
}
drop test* elas2
sort moyr time
save welfare, replace
use neload.dta, clear
* This dataset includes information on load in New England.
merge moyr time using welfare
tab _m
drop _m
replace pcomp = 1000 if pcomp > 1000 | pcomp == .
replace pcour = 1000 if pcour > 1000 | pcour == .
replace pcnc = 1000 if pcnc > 1000 | pcnc == .
order time moyr elas pcomp pcour pcnc tccour tccomp tccnc qcour qcomp qcnc load
g delta = elas * ln(pcnc/pcour)
g impcost = elas * (pcnc-pcour)
g IMPORT = load - qcour
egen imax = max(IMPORT)
egen imin = min(IMPORT)
g ESTIMP = IMPORT + delta
g ALPHA = IMPORT - elas *ln(pcour) 
g IMPACTC = elas *exp(-ALPHA/ elas)*exp(IMPORT/ elas)
g IMPESTC = elas *exp(-ALPHA/ elas)*exp(ESTIMP/ elas)
g IMPCOST = IMPESTC - IMPACTC 
drop IMPORT ESTIMP 
sum IMPCOST impcost
replace tccnc = tccnc + IMPESTC
replace tccour = tccour + IMPACTC
g dwl = tccnc - tccour
replace dwl = 0 if dwl < 0
egen DWL = sum(dwl/10^6)
egen TCcour = sum(tccour/10^6)
egen TCcnc = sum(tccnc/10^6)
egen IMPdwl = sum(impcost/10^6)
g share = DWL/TCcnc
disp "NOTE: New England welfare"
sum, sep(0)
for var DWL TC* IMPdwl: replace X=X/_N
sum DWL TC* IMPdwl, sep(0)
* PJM DWL
use pjmout99comp_log_full.dta, clear
* This dataset includes information on the output and total operating costs of each firm assuming perfect competition in PJM.
keep if boot == 1
egen tccomp = rowtotal(TC*)
egen qcomp = rowtotal(q*)
keep moyr time p_sim elas tccomp qcomp
rename p_sim pcomp
sort moyr time
save welfare, replace
use pjmout99_log_full.dta, clear 
* This dataset includes information on the output and total operating costs of each firm assuming Cournot competition (and vertical arrangements) in PJM.
keep if boot == 1
egen tccour = rowtotal(TC*)
egen qcour = rowtotal(q*)
keep moyr time p_sim elas tccour qcour
rename p_sim pcour
rename elas elas2
sort moyr time
merge moyr time using welfare
tab _m
drop _m
g test1 = elas-elas2
egen test2 = max(abs(test1))
if test2 > 0 {
disp "error"
stop
}
drop test* elas2
sort moyr time
save welfare, replace
use pjmout99_log_nc_full.dta, clear
* This dataset includes information on the output and total operating costs of each firm assuming Cournot competition (but no vertical arrangements) in PJM.
keep if boot == 1
egen tccnc = rowtotal(TC*)
egen qcnc = rowtotal(q*)
keep moyr time p_sim elas tccnc qcnc
rename p_sim pcnc
rename elas elas2
sort moyr time
merge moyr time using welfare
tab _m
drop _m
g test1 = elas-elas2
egen test2 = max(abs(test1))
if test2 > 0 {
disp "error"
stop
}
drop test* elas2
sort moyr time
save welfare, replace
use pjmload.dta, clear
* This dataset includes information on load in PJM.
merge moyr time using welfare
tab _m
drop _m
replace pcomp = 1000 if pcomp > 1000 | pcomp == .
replace pcour = 1000 if pcour > 1000 | pcour == .
replace pcnc = 1000 if pcnc > 1000 | pcnc == .
order time moyr elas pcomp pcour pcnc tccour tccomp tccnc qcour qcomp qcnc load
g delta = elas * ln(pcnc/pcour)
g impcost = elas * (pcnc-pcour)
g IMPORT = load - qcour
egen imax = max(IMPORT)
egen imin = min(IMPORT)
g ESTIMP = IMPORT + delta
g ALPHA = IMPORT - elas *ln(pcour) 
g IMPACTC = elas *exp(-ALPHA/ elas)*exp(IMPORT/ elas)
g IMPESTC = elas *exp(-ALPHA/ elas)*exp(ESTIMP/ elas)
g IMPCOST = IMPESTC - IMPACTC 
drop ALPHA 
sum IMPCOST impcost
replace tccnc = tccnc + IMPESTC
replace tccour = tccour + IMPACTC
g dwl = tccnc - tccour
replace dwl = 0 if dwl < 0
egen DWL = sum(dwl/10^6) if pcnc < 1000
egen TCcour = sum(tccour/10^6) if pcnc < 1000
egen TCcourall = sum(tccour/10^6) 
egen TCcnc = sum(tccnc/10^6) if pcnc < 1000
egen IMPdwl = sum(impcost/10^6) if pcnc < 1000
g DWL2 = TCcnc - TCcour if pcnc < 1000
g share = DWL/TCcnc
g TCcncimply = TCcourall * (1/(1-share))
g DWLimplied = TCcourall * (share/(1-share))
g DWLimplie2 = TCcncimply  - TCcourall 
disp "NOTE: PJM welfare (no contract P < 1000)"
sum, sep(0)
sum if pcnc < 1000, sep(0)
qui for var DWL TC* IMPdwl: replace X=X/_N
sum DWL TC* IMPdwl, sep(0)
log close
end

program define NONNEST
* This program calculates the non-nested tests.
capture log close
log using nonnested_nc_$date.log, replace
* m is market: 1 California; 2 New England; 3 PJM
local m = 1
while `m' <= 3 {
qui readdata2 `m'
nonnest `m' 1
nonnest `m' 2
nonnest `m' 3
local m = `m' + 1
}
log close
erase temp.dta
clear
end 

program define readdata2
* This program reads in the data for the non-nested tests.
capture erase temp.dta
use quantities.dta, clear
* see above
sort moyr time
save temp.dta, replace
if `1' == 1 {
use calout99comp_boot.dta, clear
* This dataset includes information on the actual price, the competitive price, and the competitive price under a small deviation of elasticity in order to determine the standard errors on the competitive price in California.
keep if boot==1 | boot==3
replace boot = 2 if boot == 3
duplicates drop
drop if boot == .
keep moyr time boot p_sim p_act elas
rename elas elascomp
rename p_sim simp
rename p_act actp
replace simp = 250 if simp > 250
replace actp = 250 if actp > 250
rename boot run
sort moyr time run
order moyr time run sim act elascomp
reshape wide sim act elas, i(moyr time) j(run)
drop actp2 
rename actp1 p_act
rename simp1 comp
rename simp2 compg2 
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
use calout99_boot.dta, clear
* This dataset includes information on the Cournot price, and the Cournot price under a small deviation of elasticity in order to determine the standard errors on the Cournot price in California.
keep if boot==1 | boot==3
replace boot = 2 if boot == 3
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascour
rename p_sim simp
replace simp = 250 if simp > 250
rename boot run
sort moyr time run
drop if moyr == moyr[_n-1] & time == time[_n-1] & run == run[_n-1]
order moyr time run sim elascour
reshape wide sim elascour, i(moyr time) j(run)
rename simp1 courn
rename simp2 courng2 
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
}
if `1' == 2 {
use neout99compboot.dta, clear 
* This dataset includes information on the actual price in New England.
duplicates drop
drop if boot == .
keep if boot == 1
keep moyr time p_act
rename p_act actp
sort moyr time
merge moyr time using temp.dta
drop _merge
replace actp = 1000 if actp > 1000
rename actp p_act
sort moyr time
save temp.dta, replace
use neout99log_comp_full.dta, clear
* This dataset includes information on the competitive price, and the competitive price under a small deviation of elasticity in order to determine the standard errors on the competitive price in New England.
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascomp
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim elascomp
reshape wide sim elascomp, i(moyr time) j(run)
rename simp1 comp
rename simp2 compg2
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
use neout99log_full.dta, clear
* This dataset includes information on the Cournot price (with vertical arrangements), and the Cournot price under a small deviation of elasticity in order to determine the standard errors on the Cournot price in New England.
keep if boot==1 | boot==2
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascour
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim elascour
reshape wide sim elascour, i(moyr time) j(run)
rename simp1 courn
rename simp2 courng2
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
use neout99log_nc_full.dta, clear
* This dataset includes information on the Cournot price (without vertical arrangements), and the Cournot price under a small deviation of elasticity in order to determine the standard errors on the Cournot price in New England.
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascnc
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim elascnc
reshape wide sim elascnc, i(moyr time) j(run)
rename simp1 cnc
rename simp2 cncg2
sort moyr time
merge moyr time using temp.dta
drop _merge 
sort moyr time
save temp.dta, replace
}
if `1' == 3 {
use pjmout99comp_boot.dta, clear
* This dataset includes information on the actual price, the competitive price, and the competitive price under a small deviation of elasticity in order to determine the standard errors on the competitive price in PJM.
keep if boot==1 | boot==3
replace boot = 2 if boot == 3
duplicates drop
drop if boot == .
keep moyr time boot p_sim p_act elas
rename elas elascomp
rename p_sim simp
rename p_act actp
replace simp = 1000 if simp > 1000
replace actp = 1000 if actp > 1000
rename boot run
sort moyr time run
order moyr time run sim act elascomp
reshape wide sim act elascomp, i(moyr time) j(run)
drop actp2 
rename actp1 p_act
rename simp1 comp 
rename simp2 compg2 
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
use pjmout99_boot.dta, clear
* This dataset includes information on the Cournot price (with vertical arrangements), and the Cournot price under a small deviation of elasticity in order to determine the standard errors on the Cournot price in PJM.
keep if boot==1 | boot==3
replace boot = 2 if boot == 3
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascour
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim elascour
reshape wide sim elascour, i(moyr time) j(run)
rename simp1 courn
rename simp2 courng2
sort moyr time
merge moyr time using temp.dta
drop _merge
sort moyr time
save temp.dta, replace
use pjmout99_log_nc_full.dta, clear
* This dataset includes information on the Cournot price (without vertical arrangements), and the Cournot price under a small deviation of elasticity in order to determine the standard errors on the Cournot price in PJM.
duplicates drop
drop if boot == .
keep moyr time boot p_sim elas
rename elas elascnc
rename p_sim simp
replace simp = 1000 if simp > 1000
rename boot run
sort moyr time run
order moyr time run sim elascnc
reshape wide sim elascnc, i(moyr time) j(run)
rename simp1 cnc
rename simp2 cncg2
sort moyr time
merge moyr time using temp.dta
drop _merge 
sort moyr time
save temp.dta, replace
}
sort moyr time
merge moyr time using temp.dta
drop _merge 
sort moyr time
save temp.dta, replace
end

program define nonnest
* This program estimates the encompassing test to compare the actual, competitive, and Courot prices.
use temp.dta, clear
disp "**********************************************************"
scalar calbeta = 5392.4
scalar nebeta =1391.083   
scalar pjmbeta =860.7
scalar calse =704.2372
scalar nese =162.3466 
scalar pjmse =118.2885
if `1' == 1 {
disp "California"
scalar beta = calbeta
scalar se = calse
qui replace p_act = 250 if p_act == .
qui replace comp = 250 if comp == .
qui replace courn = 250 if courn == .
}
if `1' == 2 {
disp "New England"
scalar beta = nebeta
scalar se = nese
qui replace p_act = 1000 if p_act == .
qui replace comp = 1000 if comp == .
qui replace courn = 1000 if courn == .
qui replace cnc = 1000 if cnc == .
}
if `1' == 3 {
disp "PJM"
scalar beta = pjmbeta
scalar se = pjmse
qui replace p_act = 1000 if p_act == .
qui replace comp = 1000 if comp == .
qui replace courn = 1000 if courn == .
qui replace cnc = 1000 if cnc == .
}
if `2' == 1 {
disp "Full Sample"
}
if `2' == 2 {
qui keep if peak
disp "Peak Hours Sub-sample"
}
if `2' == 3 {
qui keep if peak==0
disp "Off-Peak Hours Sub-sample"
}
qui sort moyr time
qui g T = _n
qui sort T
qui tsset T
disp "Cournot vs. Competitive Prices: Non-nested Test"
qui g g1 = (courng2 - courn)/(beta/(1/((elascour2/elascour1)-1)))
qui g g2 = (compg2 - comp)/(beta/(1/((elascomp2/elascomp1)-1)))
qui newey p_act courn comp, force lag(24) nocon
mat b = e(b)
mat v = e(V)
qui g gamma1 = _b[courn]
qui g gamma2 = _b[comp]
qui g cournse = _se[courn]^2
qui g compse = _se[comp]^2
qui g fstar = gamma1*g1 + gamma2*g2
qui reg fstar courn comp 
qui g beta1 = _b[courn]
qui g beta2 = _b[comp]
qui replace cournse = sqrt(cournse + (se*beta1)^2)
qui replace compse = sqrt(compse + (se*beta2)^2)
mkmat cournse if _n==1, mat(se1)
mkmat compse if _n==1, mat(se2)
mat vv = (se1*se1, v[1,2] \ v[2,1], se2*se2)
mat input null = (1\0)
mat input R = (1,0\0,1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat1 = b0' * inv(z) * b0 / 2
mat input null = (0\1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat2 = b0' * inv(z) * b0 / 2
qui svmat fstat1, name(fstat1)
qui svmat fstat2, name(fstat2)
qui g tstat1 = gamma1 / cournse
qui g tstat2 = gamma2 / compse
qui g pval1 = tden(2928, abs(tstat1))
qui g pval2 = tden(2928, abs(tstat2))
qui g fval1 = Fden(2, 2925, fstat1) 
qui g fval2 = Fden(2, 2925, fstat2) 
qui g errcour = p_act - courn
qui g errcomp = p_act - comp 
qui egen esscour = sum(errcour^2)
qui egen esscomp = sum(errcomp^2)
qui egen rss = sum(p_act^2)
qui g r2cour = 1 - esscour/ rss
qui g r2comp = 1 - esscomp/ rss
table moyr, c(mean p_act mean courn mean comp)
sum p_act courn comp r2* gamma1 gamma2 cournse compse tstat1 tstat2 pval1 pval2 fstat1 fstat2 fval1 fval2, sep(0)
qui drop g1-r2comp
if `1' > 1 {
disp "Cournot vs. Cournot No Contracts Prices: Non-nested Test"
qui g g1 = (courng2 - courn)/(beta/(1/((elascour2/elascour1)-1)))
qui g g2 = (cncg2 - cnc)/(beta/(1/((elascnc2/elascnc1)-1)))
qui newey p_act courn cnc, force lag(24) nocon
mat b = e(b)
mat v = e(V)
qui g gamma1 = _b[courn]
qui g gamma2 = _b[cnc]
qui g cournse = _se[courn]^2
qui g cncse = _se[cnc]^2
qui g fstar = gamma1*g1 + gamma2*g2
qui reg fstar courn cnc 
qui g beta1 = _b[courn]
qui g beta2 = _b[cnc]
qui replace cournse = sqrt(cournse + (se*beta1)^2)
qui replace cncse = sqrt(cncse + (se*beta2)^2)
mkmat cournse if _n==1, mat(se1)
mkmat cncse if _n==1, mat(se2)
mat vv = (se1*se1, v[1,2] \ v[2,1], se2*se2)
mat input null = (1\0)
mat input R = (1,0\0,1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat1 = b0' * inv(z) * b0 / 2
mat input null = (0\1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat2 = b0' * inv(z) * b0 / 2
qui svmat fstat1, name(fstat1)
qui svmat fstat2, name(fstat2)
qui g tstat1 = gamma1 / cournse
qui g tstat2 = gamma2 / cncse
qui g pval1 = tden(2928, abs(tstat1))
qui g pval2 = tden(2928, abs(tstat2))
qui g fval1 = Fden(2, 2925, fstat1) 
qui g fval2 = Fden(2, 2925, fstat2) 
qui g errcour = p_act - courn
qui g errcnc = p_act - cnc 
qui egen esscour = sum(errcour^2)
qui egen esscnc = sum(errcnc^2)
qui egen rss = sum(p_act^2)
qui g r2cour = 1 - esscour/ rss
qui g r2cnc = 1 - esscnc/ rss
table moyr, c(mean p_act mean courn mean cnc)
sum p_act courn cnc r2* gamma1 gamma2 cournse cncse tstat1 tstat2 pval1 pval2 fstat1 fstat2 fval1 fval2, sep(0)
qui drop g1-r2cnc
disp "Competitive vs. Cournot No Contracts Prices: Non-nested Test"
qui g g1 = (compg2 - comp)/(beta/(1/((elascomp2/elascomp1)-1)))
qui g g2 = (cncg2 - cnc)/(beta/(1/((elascnc2/elascnc1)-1)))
qui newey p_act comp cnc, force lag(24) nocon
mat b = e(b)
mat v = e(V)
qui g gamma1 = _b[comp]
qui g gamma2 = _b[cnc]
qui g compse = _se[comp]^2
qui g cncse = _se[cnc]^2
qui g fstar = gamma1*g1 + gamma2*g2
qui reg fstar comp cnc 
qui g beta1 = _b[comp]
qui g beta2 = _b[cnc]
qui replace compse = sqrt(compse + (se*beta1)^2)
qui replace cncse = sqrt(cncse + (se*beta2)^2)
mkmat compse if _n==1, mat(se1)
mkmat cncse if _n==1, mat(se2)
mat vv = (se1*se1, v[1,2] \ v[2,1], se2*se2)
mat input null = (1\0)
mat input R = (1,0\0,1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat1 = b0' * inv(z) * b0 / 2
mat input null = (0\1)
mat b0 = R*b' - null
mat z = R*vv*R'
mat fstat2 = b0' * inv(z) * b0 / 2
qui svmat fstat1, name(fstat1)
qui svmat fstat2, name(fstat2)
qui g tstat1 = gamma1 / compse
qui g tstat2 = gamma2 / cncse
qui g pval1 = tden(2928, abs(tstat1))
qui g pval2 = tden(2928, abs(tstat2))
qui g fval1 = Fden(2, 2925, fstat1) 
qui g fval2 = Fden(2, 2925, fstat2) 
qui g errcour = p_act - comp
qui g errcnc = p_act - cnc 
qui egen esscour = sum(errcour^2)
qui egen esscnc = sum(errcnc^2)
qui egen rss = sum(p_act^2)
qui g r2cour = 1 - esscour/ rss
qui g r2cnc = 1 - esscnc/ rss
table moyr, c(mean p_act mean comp mean cnc)
sum p_act comp cnc r2* gamma1 gamma2 compse cncse tstat1 tstat2 pval1 pval2 fstat1 fstat2 fval1 fval2, sep(0)
}
end

DO

