***Replication Study 'The Miracle of Microfinance' - Tables***
cap log close
clear all
set more off
set mem 100m
pause on

*DATA DIRECTORY
global datadir "/Users/floorjespers/Library/CloudStorage/OneDrive-KULeuven/Erasmus/Applied Econometrics/Folders Applied Econometrics/Data"

*OUTPUT DIRECTORY
global outputdir "/Users/floorjespers/Library/CloudStorage/OneDrive-KULeuven/Erasmus/Applied Econometrics/Folders Applied Econometrics/Replication"

*LOG FILE
log using replication_logfile_tables.smcl, replace 

*CONTROLS FOR BASELINE VARIABLES
global area_controls "area_pop_base area_debt_total_base area_business_total_base area_exp_pc_mean_base area_literate_head_base area_literate_base"

cd "$outputdir"

***Table 1A: Baseline summary statistics***
*******************************************
use "$datadir/2013-0533_data_baseline.dta", clear

local hh_composition "hh_size adult children male_head head_age head_noeduc"
local credit_access "spandana othermfi bank informal anyloan"
local loan_amt "spandana_amt othermfi_amt bank_amt informal_amt anyloan_amt"
local self_emp_activ "total_biz female_biz female_biz_pct"
local businesses "bizrev bizexpense bizinvestment bizemployees hours_weekbiz"
local businesses_allHH "bizrev_allHH bizexpense_allHH bizinvestment_allHH bizemployees_allHH hours_weekbiz_allHH"
local consumption "total_exp_mo nondurable_exp_mo durables_exp_mo home_durable_index"

local allvars "`hh_composition' `credit_access' `loan_amt' `self_emp_activ' `businesses' `businesses_allHH' `consumption'"

*Correct dataset for households without businesses --> put variables to 0 to make sure that they are also taken into consideration when summarizing data about businesses for all households*

gen bizrev_allHH = bizrev
replace bizrev = 0 if total_biz == 0

gen bizexpense_allHH = bizexpense
replace bizexpense = 0 if total_biz == 0

gen bizinvestment_allHH = bizinvestment
replace bizinvestment = 0 if total_biz == 0

gen bizemployees_allHH = bizemployees
replace bizemployees = 0 if total_biz == 0

gen hours_weekbiz_allHH = hours_weekbiz
replace hours_weekbiz = 0 if total_biz == 0

* Summary statistics for control group (treatment == 0)

summarize hh_size adult children male_head head_age head_noeduc if treatment == 0
summarize spandana othermfi bank informal anyloan if treatment == 0
summarize spandana_amt othermfi_amt bank_amt informal_amt anyloan_amt if treatment == 0
summarize total_biz female_biz female_biz_pct if treatment == 0
summarize bizrev bizexpense bizinvestment bizemployees hours_weekbiz if treatment == 0		
summarize bizrev_allHH bizexpense_allHH bizinvestment_allHH bizemployees_allHH hours_weekbiz_allHH if treatment == 0
summarize total_exp_mo nondurable_exp_mo durables_exp_mo home_durable_index if treatment == 0

***Table 1B: Endline summary statistics***
******************************************
use "$datadir/2013-0533_data_endlines1and2.dta", clear

local hh_composition "hhsize_1 hhsize_2 adults_1 adults_2 children_1 children_2 male_head_1 male_head_2 head_age_1 head_age_2 head_noeduc_1 head_noeduc_2"
display "`hh_composition'"
local credit_access "spandana_1 spandana_2 othermfi_1 othermfi_2 anybank_1 anybank_2 anyinformal_1 anyinformal_2 anyloan_1 anyloan_2"
display "`credit_access'"
local loan_amt "spandana_amt_1 spandana_amt_2 othermfi_amt_1 othermfi_amt_2 bank_amt_1 bank_amt_2 informal_amt_1 informal_amt_2 anyloan_amt_1 anyloan_amt_2"
display "`loan_amt'"
local self_emp_activ "total_biz_1 total_biz_2 female_biz_new_1 female_biz_new_2 female_biz_pct_1 female_biz_pct_2"
display "`self_emp_activ'"
local businesses "bizrev_1 bizrev_2 bizexpense_1 bizexpense_2 bizinvestment_1 bizinvestment_2 bizemployees_1 bizemployees_2 hours_week_biz_1 hours_week_biz_2"
display "`businesses'"
local businesses_allHH "bizrev_allHH_1 bizrev_allHH_2 bizexpense_allHH_1 bizexpense_allHH_2 bizinvestment_allHH_1 bizinvestment_allHH_2 bizemployees_allHH_1 bizemployees_allHH_2 hours_week_biz_allHH_1 hours_week_biz_allHH_2"
display "`businesses_allHH'"
local consumption "total_exp_mo_1 total_exp_mo_2 nondurable_exp_mo_1 nondurable_exp_mo_2 durables_exp_mo_1 durables_exp_mo_2 home_durable_index_1 home_durable_index_2"
display "`consumption'"

local allvars "`hh_composition' `credit_access' `loan_amt' `self_emp_activ' `businesses' `businesses_allHH' `consumption'"
display "`allvars'"


*1) Generate business variables for all households --> put variables to . (missing) for households without a business
forval i = 1/2 {
		gen bizrev_allHH_`i'= bizrev_`i'
		replace bizrev_`i'=. if total_biz_`i'==0
			}
forval i = 1/2 {
		gen bizexpense_allHH_`i'= bizexpense_`i'
		replace bizexpense_`i'=. if total_biz_`i'==0
			}
			
forval i = 1/2 {
		gen bizinvestment_allHH_`i'= bizinvestment_`i'
		replace bizinvestment_`i'=. if total_biz_`i'==0
			}

forval i = 1/2 {
		gen bizemployees_allHH_`i'= bizemployees_`i'
		replace bizemployees_`i'=. if total_biz_`i'==0
			}
			
forval i = 1/2 {
		gen hours_week_biz_allHH_`i'= hours_week_biz_`i'
		replace hours_week_biz_`i'=. if total_biz_`i'==0
			}
			
*2) Reshape to one observation per household per endline:

*Rename*

reshape long `allvars', i(hhid) j(endline)
keep hhid areaid endline treatment `allvars'
tab endline, gen(endline)

*3) Create summary statistics table:

forval i = 1/2 {
		summarize hh_size_`i' adult_`i' children_`i' male_head_`i' head_age_`i' head_noeduc_`i' if treatment == 1
			}


* Summary statistics for treatment group (treatment == 1)

summarize hh_size_`i' adult_`i' children_`i' male_head_`i' head_age_`i' head_noeduc_`i' if treatment == 1
summarize spandana othermfi bank informal anyloan if treatment == 1
summarize spandana_amt othermfi_amt bank_amt informal_amt anyloan_amt if treatment == 1
summarize total_biz female_biz female_biz_pct if treatment == 1
summarize bizrev bizexpense bizinvestment bizemployees hours_weekbiz if treatment == 1
summarize hh_size adult children male_head head_age head_noeduc if treatment == 1
summarize total_exp_mo nondurable_exp_mo durables_exp_mo home_durable_index if treatment == 1



***Table 2: Credit***
*********************
use "$datadir/2013-0533_data_endlines1and2.dta", clear

***PANEL A: ENDLINE 1***
est clear

*Loop through each variable, run regressions, and save key results
foreach var in spandana_1 othermfi_1 anymfi_1 anybank_1	anyinformal_1  anyloan_1 everlate_1 mfi_loan_cycles_1 ///
			   spandana_amt_1 othermfi_amt_1 anymfi_amt_1 bank_amt_1 informal_amt_1 anyloan_amt_1 credit_index_1 {
    * Run regression with treatment and area controls, weighted by w1
    reg `var' treatment $area_controls [pweight=w1], cluster(areaid)
    
    * p-value for treatment coefficients
    scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))
    
    * Summarize the variable for the control group at endline 1
    sum `var' if treatment == 0 & e(sample)
    scalar mean_control = r(mean)
    scalar sd_control = r(sd)
    
    est store `var'
}
* Export all stored results to a table
estout * using "table2r.txt", ///
    drop($area_controls _cons) ///   * Drop area controls and the constant from the table
    title("Table 2: Credit, Endline 1")
    cells(b(fmt(2)) se(fmt(2))) ///  * Include coefficients and standard errors, formatted with 2 decimal places
    s(r2 mean_control sd_control N pval) ///  * Add additional statistics (R2, mean, SD, observations, p-value)
    starlevels(* .1 ** .05 *** .01)
    legend   
    postfoot("Robust standard errors, clustered at the area level, in brackets.") 
    replace  
	
	
***PANEL B: ENDLINE 2***
est clear
*Loop through each variable, run regressions, and store results
foreach var in spandana_2 othermfi_2 anymfi_2 anybank_2 anyinformal_2 anyloan_2 everlate_2 mfi_loan_cycles_2 ///
           spandana_amt_2 othermfi_amt_2 anymfi_amt_2 bank_amt_2 informal_amt_2 anyloan_amt_2 credit_index_2 {
    * Step 3a: Run regression with treatment and area controls, weighted by w2
    reg `var' treatment $area_controls [pweight=w2], cluster(areaid)

    * Step 3b: Calculate p-value for the treatment coefficient
    scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))

    * Step 3c: Summarize the variable for the control group at endline 2
    sum `var' if treatment == 0 & e(sample)
    scalar mean_control = r(mean)
    scalar sd_control = r(sd)

    * Step 3d: Store the regression results for this variable
    est store `var'
}
*Export all stored results to a table
estout * using "table2r.txt", ///
    drop($area_controls _cons) ///  * Drop area controls and the constant from the table
    title("Table 2: Credit, Endline 2") 
    cells(b(fmt(2)) se(fmt(2))) ///  * Include coefficients and standard errors, formatted with 2 decimal places
    s(r2 mean_control sd_control N pval) ///  * Add additional statistics (R2, mean, SD, observations, p-value)
    starlevels(* .1 ** .05 *** .01) 
    legend 
    postfoot("Robust standard errors, clustered at the area level, in brackets.")
    append 

***SENSITIVITY ANALYSIS***

*Compare results using robust standard errors*
*Endline 1
est clear
foreach var in spandana_1 othermfi_1 anymfi_1 anybank_1	anyinformal_1  anyloan_1 everlate_1 mfi_loan_cycles_1 ///
			   spandana_amt_1 othermfi_amt_1 anymfi_amt_1 bank_amt_1 informal_amt_1 anyloan_amt_1 credit_index_1 {
    * Run regression with treatment and area controls, weighted by w1
    reg `var' treatment $area_controls [pweight=w1], robust
    
    * p-value for treatment coefficients
    scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))
    
    * Summarize the variable for the control group at endline 1
    sum `var' if treatment == 0 & e(sample)
    scalar mean_control = r(mean)
    scalar sd_control = r(sd)
    
    est store `var'
}

*Endline 2
est clear
foreach var in spandana_2 othermfi_2 anymfi_2 anybank_2 anyinformal_2 anyloan_2 everlate_2 mfi_loan_cycles_2 ///
           spandana_amt_2 othermfi_amt_2 anymfi_amt_2 bank_amt_2 informal_amt_2 anyloan_amt_2 credit_index_2 {
    * Step 3a: Run regression with treatment and area controls, weighted by w2
    reg `var' treatment $area_controls [pweight=w2], robust

    * Step 3b: Calculate p-value for the treatment coefficient
    scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))

    * Step 3c: Summarize the variable for the control group at endline 2
    sum `var' if treatment == 0 & e(sample)
    scalar mean_control = r(mean)
    scalar sd_control = r(sd)

    * Step 3d: Store the regression results for this variable
    est store `var'
}
***Conclusion: Standard errors are notably less when using robust standard errors in the regression, compared to using the cluster standard error (taking into account within cluster correlation)
***This means that within-cluster correlation is likely and that clustering should be taken into account when running the regression. 

*Sensitivity to outliers and influential data point*


***Tabel 5: Household Labor Hours***
************************************
// Load the dataset
use "$datadir/2013-0533_data_endlines1and2.dta", clear


***PANEL A: ENDLINE 1***
est clear

foreach var in hours_week_1 hours_week_biz_1 hours_week_outside_1 ///
			   hours_girl1620_week_1 hours_boy1620_week_1 ///
               hours_headspouse_week_1 hours_headspouse_biz_1 hours_headspouse_outside_1 labor_index_1 {
   reg `var' treatment $area_controls [pweight=w1], cluster(areaid)
   scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))
   sum `var' if treatment == 0 & e(sample)
   scalar mn1 = r(mean)
   scalar sd1 = r(sd)
    
   est store `var'
}

estout * using "table5r.txt", drop($area_controls _cons) ///
    title("Table 5: Time worked by household members, Endline 1") ///
    prehead("" @title) cells(b(fmt(a3) s) se(fmt(a3) par("="("[" "]")))) ///
    replace s(r2 mn1 sd1 N pval) starlevels(* .1 ** .05 *** .01) legend ///
    postfoot("Robust standard errors, clustered at the area level, in brackets.")

***PANEL B: ENDLINE 2***
est clear

foreach var in hours_week_2 hours_week_biz_2 hours_week_outside_2 ///
			   hours_girl1620_week_2 hours_boy1620_week_2 ///
                hours_headspouse_week_2 hours_headspouse_biz_2 hours_headspouse_outside_2 labor_index_2 {
    reg `var' treatment $area_controls [pweight=w2], cluster(areaid)
    scalar pval = 2 * ttail(e(df_r), abs(_b[treatment] / _se[treatment]))
    sum `var' if treatment == 0 & e(sample)
    scalar mn2 = r(mean)
    scalar sd2 = r(sd)
    
    est store `var'
}

// Append the results for Endline 2 to the same table
estout * using "table5.txt", drop($area_controls _cons) ///
    title("Table 5: Time worked by household members, Endline 2") ///
    prehead("" @title) cells(b(fmt(a3) s) se(fmt(a3) par("="("[" "]")))) ///
    append s(r2 mn2 sd2 N pval) starlevels(* .1 ** .05 *** .01) legend ///
    postfoot("Robust standard errors, clustered at the area level, in brackets.")


