********************************************************************************
********** Table 1A: Baseline Summary Statistics (Excluding Outliers) ***********
********************************************************************************

* DATA DIRECTORY
global datadir "/Users/felix/KTH/AppliedEconometrics/Project/DATA"

*OUTPUT DIRECTORY
global outputdir "/Users/felix/KTH/AppliedEconometrics/Project/Replication"

*LOGFILE*
capture log close
log using robustness_log, replace
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
*************         Table 1B: Endline Summary Statistics        **************
********************************************************************************
* ENDLINE 1 *
* Load baseline dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Define key variables for summary statistics
local hh_composition_1 "hhsize_1 adults_1 children_1 male_head_1 head_age_1 head_noeduc_1"
local credit_access_1 "spandana_1 othermfi_1 anybank_1 anyinformal_1 anyloan_1"
local loan_amt_1 "spandana_amt_1 othermfi_amt_1 bank_amt_1 informal_amt_1 anyloan_amt_1"


* Exclude outliers (1st and 99th percentiles for numeric variables)

foreach var of varlist `hh_composition_1' `credit_access_1' `loan_amt_1' {
    quietly summarize `var', detail
    local p1 = r(p1)
    local p99 = r(p99)
    drop if `var' < `p1' | `var' > `p99'
}

* Recalculate summary statistics
summarize `hh_composition_1' `credit_access_1' `loan_amt_1'

* Store summary statistics
estpost summarize `hh_composition_1' `credit_access_1' `loan_amt_1'

* Export summary statistics to a text file
esttab using table1b_nooutliers1.txt, replace cells("mean sd min max") label title("Excluding Outliers Endline 1")


* ENDLINE 2 *
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Define key variables for summary statistics
local hh_composition_2 "hhsize_2 adults_2 children_2 male_head_2 head_age_2 head_noeduc_2"
local credit_access_2 "spandana_2 othermfi_2 anybank_2 anyinformal_2 anyloan_2"
local loan_amt_2 "spandana_amt_2 othermfi_amt_2 bank_amt_2 informal_amt_2 anyloan_amt_2"

* Exclude outliers (1st and 99th percentiles for numeric variables)

foreach var of varlist `hh_composition_2' `credit_access_2' `loan_amt_2' {
    quietly summarize `var', detail
    local p1 = r(p1)
    local p99 = r(p99)
    drop if `var' < `p1' | `var' > `p99'
}

* Recalculate summary statistics
summarize `hh_composition_2' `credit_access_2' `loan_amt_2'

* Store summary statistics
estpost summarize `hh_composition_2' `credit_access_2' `loan_amt_2'

* Export summary statistics to a text file
esttab using table1b_nooutliers2.txt, replace cells("mean sd min max") label title("Excluding Outliers Endline 2")


********************************************************************************
********** Regression Robustness: Drop One Control at a Time ********************
********************************************************************************

* Load dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Define baseline regression variables 
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
*local outcome bizrev* *

*** Treatment effect on business revenue ***
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
	
	* Run regression with remaining controls: but regressing on treatment
    regress bizrev_1 treatment `controls_removed'
	outreg2 using regression_robustness.txt, append ctitle("Effect of treatment on revenue of old businesses EL1: Excluding `var'")
	
	regress bizrev_2 treatment `controls_removed'
	outreg2 using regression_robustness.txt, append ctitle("Effect of treatment on revenue of old businesses EL2: Excluding `var'")

}
*** Treatment effect on business revenue ***
* Define baseline regression variables 
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
foreach var of varlist `baseline_controls' {
    display "Running regression without control: `var'"

    * Build the list of controls excluding `var`
    local controls_removed ""
    foreach control of varlist `baseline_controls' {
        if "`control'" != "`var'" {
            local controls_removed "`controls_removed' `control'"
        }
    }	
	* Run regression with remaining controls: but regressing on treatment
    regress spandana_1 treatment `controls_removed'
	outreg2 using regression_robustness.txt, append ctitle("Effect of treatment on credit EL1: Excluding `var'")
	
	regress spandana_2 treatment `controls_removed'
	outreg2 using regression_robustness.txt, append ctitle("Effect of treatment on credit EL2: Excluding `var'")
}
********************************************************************************
********** Regression Robustness: Add Additional Controls ***********************
********************************************************************************

* Load endline dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear

* Baseline and additional control variables
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
local additional_controls "adult* children* male_head* hhsize*"
*local outcome bizrev* *

* Run regression with baseline + additional controls: treatment effect on business revenue*
*regress `outcome' `baseline_controls' `additional_controls'*

regress bizrev_1 treatment `baseline_controls' `additional_controls'
* Export results
outreg2 using regression_addcontrols.txt, append ctitle("With Additional Controls")
regress bizrev_2 treatment `baseline_controls' `additional_controls'
* Export results
outreg2 using regression_addcontrols.txt, append ctitle("With Additional Controls")

* Baseline and additional control variables
local baseline_controls "area_pop_base area_debt_total_base area_business_total_base"
local additional_controls "adult* children* male_head* hhsize*"
*local outcome bizrev* *

* Run regression with baseline + additional controls: treatment effect on credit*
*regress `outcome' `baseline_controls' `additional_controls'*

regress spandana_1 treatment `baseline_controls' `additional_controls'
* Export results
outreg2 using regression_addcontrols.txt, append ctitle("With Additional Controls")
regress spandana_2 treatment `baseline_controls' `additional_controls'
* Export results
outreg2 using regression_addcontrols.txt, append ctitle("With Additional Controls")
