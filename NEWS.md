# nccovid 0.0.8

* Fix Veteran's Day reporting lag
* Added a basic herd immunity calculation function in the form of `hit`

# nccovid 0.0.7

* Updated `get_covid_state` to reflect the reporting irregularity around September 4th.
* Updated functions to ensure correct field names were used (hospitalization details)
* Updated functions around converting growth rates to reproduction numbers

# nccovid 0.0.6

* Added `calculate_community_immunity` in order to estimate the level of community immunity

# nccovid 0.0.4

* Added `get_cdc_vax` and `get_cdc_detail` to more easily retrieve information from the CDC on the spread of SARS-CoV-2 by county


# nccovid 0.0.3
* Added a smoother for reporting delays for Alamance and Guilford counties between 1 May and 21 May for the adjusted case metrics.
* `pull_vaccine_census` now available to pull vaccination rates at the Census Tract


# nccovid 0.0.2

* Added logic to account for data dumps from North Carolina with an optional argument in  `get_covid_state` called `report_adj` with a default of `FALSE` to account for two points
  * 2020-09-25 when all antigen tests were added 
  * 2020-11-13/2020-11-14 when data collection times changed and only 10 hours of data were collect.
* Added `get_hospitalizations` to retrieve hospitalisation data 
* Added North Carolina Healthcare Preparation Coalitions as a data set 
The current method just imputes the previous days value for September for the death and case incidence on 25 September. 
For the November reporting change the 13/14 days are averaged across the two days. 
This should smooth out any reporting irregularity. 
This is important for calculating R or any other metrics that rely on daily data.