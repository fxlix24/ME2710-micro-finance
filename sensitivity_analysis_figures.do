
/*******************************************************************************
Program Name:    sensitivity_analysis.do
Contact:         Felix (Created for further analysis)
Purpose:         Conducts sensitivity analysis on quantile treatment effect regressions
                 for "The miracle of microfinance?" replication project.
*******************************************************************************/

version 13.1
cap log close
clear all
set more off
set mem 100m
pause on

*DATA DIRECTORY
global datadir "/Users/felix/KTH/AppliedEconometrics/Project/DATA"

*OUTPUT DIRECTORY
global outputdir "/Users/felix/KTH/AppliedEconometrics/Project/Output"

*LOG FILE
capture log close
log using sensitivity_analysis_log, replace
cd "$outputdir"

********************************************************************************
******* Sensitivity Analysis: Quantile Treatment Effect Regressions ************
********************************************************************************

* Load the dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* 1. Sensitivity to Quantile Levels
* Define the quantiles to analyze
local quantiles 0.05 0.10 0.25 0.50 0.75 0.90 0.95

* Loop through quantiles to calculate results and print them
foreach q of local quantiles {
    * Run quantile regression
    quietly qreg bizprofit_2 treatment, quantile(`q')

    * Extract the treatment coefficient and standard error
    scalar coeff = _b[treatment]
    scalar stderr = _se[treatment]

    * Print the results to the console
    di "Quantile: `q'"
    di "  Coefficient: " coeff
    di "  Standard Error: " stderr
    di "---------------------------------"
}

* 2. Sensitivity to Subsamples
* Old Businesses Only
preserve
    keep if any_old_biz == 1
	drop if missing(bizprofit_2)
    reg bizprofit_2 treatment
    estimates store old_biz
	twoway scatter bizprofit_2 treatment
    graph export "quantile_old_biz.png", replace
restore

* New Businesses Only
preserve
    keep if any_old_biz == 0
	drop if missing(bizprofit_2)
    reg bizprofit_2 treatment
    estimates store new_biz
	twoway scatter bizprofit_2 treatment
    graph export "quantile_new_biz.png", replace
restore

* 3. Sensitivity to Outliers (Winsorize)
summarize bizprofit_2, detail
local p0_5 = r(p1)  // Lower percentile
local p99_5 = r(p99)  // Upper percentile
gen bizprofit_2_wins = bizprofit_2
replace bizprofit_2_wins = `p0_5' if bizprofit_2 < `p0_5' & !missing(bizprofit_2)
replace bizprofit_2_wins = `p99_5' if bizprofit_2 > `p99_5' & !missing(bizprofit_2)
reg bizprofit_2_wins treatment
*graph export "quantile_winsorized.png", replace


* 4. Bootstrapped Standard Errors
set seed 123  // Set the seed for reproducibility
*bootstrap _b, reps(500): qreg bizprofit_2 treatment, quantile(95)
bootstrap _b, reps(500) saving(boot_results, replace): qreg bizprofit_2 treatment, quantile(95)
use boot_results, clear
histogram _b_treatment, normal title("Bootstrap Coefficient Distribution")
graph export "bootstrap_ci.png", replace 

* 5. Alternative Specifications
* Log Transformation
gen log_bizprofit = log(bizprofit_2 + 1)   // Adding 1 to avoid log(0)
reg log_bizprofit treatment
twoway (histogram log_bizprofit, color(blue%50) bin(30)) ///
       (histogram bizprofit_2, color(red%50) bin(30)), ///
       title("Distributions of Log-Transformed and Original Profits") ///
       legend(label(1 "Log-Transformed") label(2 "Original"))
graph export "quantile_log_transformation.png", replace

log close
