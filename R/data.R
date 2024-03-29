#' Mortality Estimates from Verity Et Al for Covid
#' 
#' @format data frame
#' 
"covid_mortality_data"

#' Mortality and Hospitalization Estimates
#' 
#' @format data.frame

"nc_fatality_estimates"

#' Italy Estimates
#' @format a data.frame
"italy_rates"

#' List of Triad Counties
#' @format a vector
"triad_counties"

#' Regions in Cone Region of Service
#' @format a vector
"cone_region"

#' North Carolina Population by County
#' @source Source: North Carolina OSBM, Standard Population Estimates, 
#'     Vintage 2018 and Population Projections, Vintage 2019
#'     <https://www.osbm.nc.gov/demog/county-estimates>
#'@format a data.frame
"nc_population"

#' CDC Social Vulnerability for North Carolina by County
#' @source [U.S. Centers for Disease Prevention and Control (CDC) Social Vulnerability Index (SVI)](https://svi.cdc.gov/)
#' @format a data.frame
"nc_svi_county"

#' North Carolina Population by County by Age
#' @source ACS2020 Metrics
#'@format a data.frame
"nc_pop_age"

#' Key North Carolina Events
#' @source various and https://www.nc.gov/covid-19/staying-ahead-curve
#' @format a data.frame
"nc_events"

#' NC Population by NCDHHS Age Band
#' @source 2020 ACS Survey
#' @format a data.frame

"nc_pop_dhhs"

#' NC Fips by County
#' @source https://www.lib.ncsu.edu/gis/countyfips
#' @format a data.frame
"nc_county_fips"

#' NC Biological Sex Information by County
#' @source American Community Survey (2020 Vintage)
#' @format a data.frame, with NC DHHS county level demographic metrics
"nc_county_demos"

#' NC Hospital Preparedness Coalitions
#' @source https://easternhpc.com/state-coalition-map/
#' @format a data.frame, with NC county name and associated coalition
"nc_hc_coalitions"

#' NCDHHS Reported Delay Distribution
#' 
#' Reported testing and reporting delays were fit using the EpiNow2 
#' boostrapped gamma fit. The reported delays were manually collected from
#' the NCDHHS website.
#' 
#' @source https://covid19.ncdhhs.gov/dashboard/testing
#' @format a list, with parameters for a gamma distribution fit to delays
"nc_delay"