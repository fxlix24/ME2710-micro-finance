
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
log using sensitivity_analysis_log.smcl, replace
cd "$outputdir"

********************************************************************************
******* Sensitivity Analysis: Quantile Treatment Effect Regressions ************
********************************************************************************

* Load the dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* 1. Sensitivity to Quantile Levels
local quantiles 0.10 0.25 0.50 0.75 0.90
foreach q of local quantiles {
    local qname = subinstr("`q'", ".", "_", .)   // Replace "." with "_"
    quietly qreg bizprofit_1 treatment, quantile(`q')
    estimates store quantile_`qname'
    estimates table quantile_`qname', stats(rmse) title("Quantile: `q'")
    
    * Generate a simple scatter plot for treatment effect (example graph)
    predict yhat_`qname' if e(sample), xb
    twoway scatter yhat_`qname' treatment, ///
        title("Quantile Regression: `q'") ///
        ytitle("Predicted Outcome") xtitle("Treatment")
    
    graph export "quantile_sensitivity_`qname'.png", replace
}

* 2. Sensitivity to Subsamples
* Old Businesses Only
preserve
    keep if any_old_biz == 1
    qreg bizprofit_1 treatment, quantile(50)
    estimates store old_biz
    graph export "quantile_old_biz.png", replace
restore

* New Businesses Only
preserve
    keep if any_old_biz == 0
    qreg bizprofit_1 treatment, quantile(50)
    estimates store new_biz
    graph export "quantile_new_biz.png", replace
restore

* 3. Sensitivity to Outliers (Winsorize)
summarize bizprofit_1, detail
local p0_5 = r(p1)  // Lower percentile
local p99_5 = r(p99)  // Upper percentile
gen bizprofit_1_wins = bizprofit_1
replace bizprofit_1_wins = `p0_5' if bizprofit_1 < `p0_5' & !missing(bizprofit_1)
replace bizprofit_1_wins = `p99_5' if bizprofit_1 > `p99_5' & !missing(bizprofit_1)
qreg bizprofit_1_wins treatment, quantile(50)
graph export "quantile_winsorized.png", replace

* 4. Bootstrapped Standard Errors
set seed 123  // Set the seed for reproducibility
bootstrap _b, reps(500): qreg bizprofit_1 treatment, quantile(50)
graph export "bootstrap_ci.png", replace

* 5. Alternative Specifications
* Log Transformation
gen log_bizprofit = log(bizprofit_1 + 1)   // Adding 1 to avoid log(0)
qreg log_bizprofit treatment, quantile(50)
graph export "quantile_log_transformation.png", replace

log close
