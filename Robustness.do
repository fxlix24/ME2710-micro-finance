********************************************************************************
********** Table 1A: Baseline Summary Statistics (Excluding Outliers) ***********
********************************************************************************

* DATA DIRECTORY
global datadir "/Users/felix/KTH/AppliedEconometrics/Project/DATA"

*OUTPUT DIRECTORY
global outputdir "/Users/felix/KTH/AppliedEconometrics/Project/Replication"

cd "$outputdir"

* Load baseline dataset
use "$datadir/2013-0533_data_baseline.dta", clear

* Define key variables for summary statistics
local hh_composition "hh_size adult children male_head head_age head_noeduc"
local credit_access "spandana othermfi bank informal anyloan"
local loan_amt "spandana_amt othermfi_amt bank_amt informal_amt anyloan_amt"

* Exclude outliers (1st and 99th percentiles for numeric variables)
foreach var of varlist `hh_composition' `credit_access' `loan_amt' {
    quietly summarize `var', detail
    local p1 = r(p1)
    local p99 = r(p99)
    drop if `var' < `p1' | `var' > `p99'
}

* Recalculate summary statistics
summarize `hh_composition' `credit_access' `loan_amt'

* Store summary statistics
estpost summarize `hh_composition' `credit_access' `loan_amt'

* Export summary statistics to a text file
esttab using table1a_nooutliers.txt, replace cells("mean sd min max") label title("Excluding Outliers")

********************************************************************************
********** Regression Robustness: Drop One Control at a Time ********************
********************************************************************************

* Load dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Define baseline regression variables
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
local outcome bizrev*

* Loop through controls, excluding one at a time
foreach var of varlist `baseline_controls' {
    display "Running regression without control: `var'"

    * Build the list of controls excluding `var`
    local controls_removed ""
    foreach control of varlist `baseline_controls' {
        if "`control'" != "`var'" {
            local controls_removed "`controls_removed' `control'"
        }
    }
    
    * Run regression with remaining controls
    regress `outcome' `controls_removed'

    * Export results
    outreg2 using regression_robustness.txt, append ctitle("Excluding `var'")
}

********************************************************************************
********** Regression Robustness: Add Additional Controls ***********************
********************************************************************************

* Load endline dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Baseline and additional control variables
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
local additional_controls "adult* children* male_head* hhsize*"
local outcome bizrev*

* Run regression with baseline + additional controls
regress `outcome' `baseline_controls' `additional_controls'

* Export results
outreg2 using regression_addcontrols.txt, replace ctitle("With Additional Controls")
