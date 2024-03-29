#' Retrieve Covid19 Data
#' 
#' This functions hits the Johns Hopkins Covid Data Repository
#' and filters down to North Carolina Data. Alternatively, it can
#' retrieve any state.
#' 
#' @param state with a default of North Carolina
#' @param select_county the county, if desired
#' @param data_source which data source you would like to use
#'     one of "cone" or "hopkins"
#' @param reporting_adj a boolean, default of \code{FALSE} which adjust
#'     for two known issues with North Carolina Report occurring on 
#'     2020-09-25 when all antigen tests were added and on 2020-11-13
#'     where only 10 hours of data were reported and the remaining cases
#'     were rolled into 2020-11-14. Also corrects for reporting lapses on 
#'     Thanksgiving and Christmas Eve/ Christmas Day. On 2021-02-28 the dashboard 
#'     was taken down for maintenance and thus unavailable on that day.
#'     Additionally note that on 2021-03-13 NCDHHS elected to not report data 
#'     on Sundays. On 2021-03-19 NCDHHS notified users that on 2021-03-26 data 
#'     would be updated Monday - Friday. Updated for Good Friday in which no results
#'     were posted.
#' @examples \dontrun{
#' # To get all counties
#' get_covid_state()
#' 
#' # To get a single county
#' get_covid_state(select_county = "Guilford")
#' }
#' 
#' 
#' @export
#' 
get_covid_state <- function(state = "North Carolina", 
														select_county = NULL, 
														data_source = c("cone", "hopkins"),
														reporting_adj = FALSE){
	url_cases <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
	url_deaths <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
	
	data_source <- match.arg(data_source)
	
	message(sprintf("Using: %s as the data source", data_source))
	
	if(data_source == "hopkins"){
	
	# HAndle Daily Cases
	dat_cases <- data.table::fread(url_cases)
	
	dat_cases <- dat_cases[Province_State==state]
	
	dat_cases <- dat_cases[, .SD, .SDcols = patterns("20$|Admin2|Province_State")]
	
	dat_cases <- data.table::melt(dat_cases, id.vars = c("Province_State", "Admin2"),
																variable.name = c("date"), 
																value.name = "confirmed_cases")
	names(dat_cases) <- c("state", "county", "date", "cases_confirmed_cum")
	
	dat_cases <- dat_cases[,cases_daily := cases_confirmed_cum - dplyr::lag(cases_confirmed_cum,1,0), by = "county"]
	
	# Deaths
	
	dat_death <- data.table::fread(url_deaths)
	
	dat_death <- dat_death[Province_State==state]
	
	dat_death <- dat_death[, .SD, .SDcols = patterns("20$|Admin2|Province_State")]
	
	dat_death <- data.table::melt(dat_death, id.vars = c("Province_State", "Admin2"),
																variable.name = c("date"), 
																value.name = "deaths_confirmed_cum")
	names(dat_death) <- c("state", "county", "date", "deaths_confirmed_cum")
	
	dat_death <- dat_death[,deaths_daily := deaths_confirmed_cum - dplyr::lag(deaths_confirmed_cum,1,0), by = "county"]
	
	out_data <- data.table::merge.data.table(dat_cases,dat_death, by = c("state", "county", "date"))
	
	out_data <- out_data[,date := as.Date(date, "%m/%d/%y")]
	
	out_data <- out_data[,cases_daily := ifelse(cases_daily<0,0,cases_daily)]
	out_data <- out_data[,deaths_daily := ifelse(deaths_daily<0,0,deaths_daily)]
	}else{
		out_data <- data.table::fread("https://raw.githubusercontent.com/conedatascience/covid-data/master/data/timeseries/nc-cases-by-county.csv", 
																			 colClasses = c("character", "character", "Date", "integer", "integer", "double","integer", "integer"), verbose = F)
		fix_variable <- c("cases_daily", "deaths_daily", "cases_confirmed_cum", "deaths_confirmed_cum")
		na_to_zero <- function(x) ifelse(is.na(x),0,x)
		out_data <- out_data[, `:=`(cases_daily = na_to_zero(cases_daily),
																deaths_daily = na_to_zero(deaths_daily),
																cases_confirmed_cum = na_to_zero(cases_confirmed_cum),
																deaths_confirmed_cum = na_to_zero(deaths_confirmed_cum))]
	}
	
	if(!is.null(select_county)){
		out_data <- out_data[county%chin%select_county]
	}
	
	if(reporting_adj){
		# Add Lag for 2020-09-25
		out_data <- out_data[,cases_daily:=data.table::fifelse(date==as.Date("2020-09-25"),
																							 data.table::shift(cases_daily,1),
																							 cases_daily), by = "county"]
		out_data <- out_data[,deaths_daily:=data.table::fifelse(date==as.Date("2020-09-25"),
																													 data.table::shift(deaths_daily,1),
																														deaths_daily), by = "county"]
		# Smooth Correction on 2020-11-13
		target_dates <- c(as.Date("2020-11-13"),
											as.Date("2020-11-14"))
		
		out_data <- out_data[date%in%target_dates,
						 `:=`(
						 	cases_daily = round(sum(cases_daily)/2),
						 	deaths_daily = round(sum(deaths_daily)/2)
						 ), by = "county"]
		# Smooth Correction on 2020-12-24-2020-12-26
		target_dates <- c(as.Date("2020-12-24"),
											as.Date("2020-12-25"),
											as.Date("2020-12-26"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/3),
												 	deaths_daily = round(sum(deaths_daily)/3)
												 ), by = "county"]
		
		# Smooth Correction on 2020-12-24-2020-12-26
		target_dates <- c(as.Date("2021-01-01"),
											as.Date("2021-01-02"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		# Smoothed for MLK
		
		target_dates <- c(as.Date("2021-01-18"),
											as.Date("2021-01-19"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-02-28"),
											as.Date("2021-03-01"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-03-07"),
											as.Date("2021-03-08"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-03-17"),
											as.Date("2021-03-18"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-03-13"),
											as.Date("2021-03-14"),
											as.Date("2021-03-15"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/3),
												 	deaths_daily = round(sum(deaths_daily)/3)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-03-21"),
											as.Date("2021-03-22"))
		
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/2),
												 	deaths_daily = round(sum(deaths_daily)/2)
												 ), by = "county"]
		
		dat_range_saturday = seq.Date(from = as.Date("2021-03-27"), length.out = 300, by = "week")
		dat_range_monday = seq.Date(from = as.Date("2021-03-29"), length.out = 300, by = "week")
		
		for(i in seq_along(dat_range_saturday)){
			target_dates = seq.Date(dat_range_saturday[i], dat_range_monday[i], by = "day")
			out_data <- out_data[date%in%target_dates,
													 `:=`(
													 	cases_daily = round(sum(cases_daily)/3),
													 	deaths_daily = round(sum(deaths_daily)/3)
													 ), by = "county"]
		}
		
		target_dates <- c(as.Date("2021-04-02"),
											as.Date("2021-04-03"),
											as.Date("2021-04-04"),
											as.Date("2021-04-05")
		)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/4),
												 	deaths_daily = round(sum(deaths_daily)/4)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-05-29"),
											as.Date("2021-05-30"),
											as.Date("2021-05-31"),
											as.Date("2021-06-01")
		)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/4),
												 	deaths_daily = round(sum(deaths_daily)/4)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-07-03"),
											as.Date("2021-07-04"),
											as.Date("2021-07-05"),
											as.Date("2021-07-06")
		)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/4),
												 	deaths_daily = round(sum(deaths_daily)/4)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-09-04"),
											as.Date("2021-09-05"),
											as.Date("2021-09-06"),
											as.Date("2021-09-07")
		)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/4),
												 	deaths_daily = round(sum(deaths_daily)/4)
												 ), by = "county"]
		
		target_dates <- c(as.Date("2021-11-11"),
											as.Date("2021-11-12")
		)
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2021-11-25"),
											as.Date("2021-11-29"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2021-12-23"),
														 as.Date("2021-12-28"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2022-01-15"),
														 as.Date("2022-01-18"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2022-02-19"),
														 as.Date("2022-02-22"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2022-05-28"),
														 as.Date("2022-05-31"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		
		target_dates <- seq.Date(as.Date("2022-07-02"),
														 as.Date("2022-07-05"), by = "day")
		
		wf <- length(target_dates)
		out_data <- out_data[date%in%target_dates,
												 `:=`(
												 	cases_daily = round(sum(cases_daily)/wf),
												 	deaths_daily = round(sum(deaths_daily)/wf)
												 ), by = "county"]
		 
		out_data <- out_data[,`:=`(cases_daily_roll = round(data.table::frollmean(cases_daily, 14))), 
												 by = "county"]
		
		out_data <- out_data[,`:=`(cases_daily_roll_sum = round(data.table::frollsum(cases_daily, 7))), 
												 by = "county"]
		
		# Due to a reporting issue the state started to put many cases from months prior
		# into the dailies.
		
		start_smooth <- as.Date("2021-05-01")
		end_smooth <- as.Date("2021-05-21")
		
		out_data <- out_data[,cases_daily := ifelse(county %in% c("Alamance", "Guilford") & date %in% seq.Date(start_smooth,
																																																					 end_smooth, by = "day"),
																								cases_daily_roll, cases_daily)][,cases_daily_roll:=NULL]
		
		
	}
	
	while(out_data[,.SD[.N], by = "county"][,sum(cases_daily)]<1){
		out_data= out_data[out_data[, if (.N > 1) head(.I, -1) else .I, by = "county"]$V1]
	}
	
	message("Last date available: ", max(out_data$date))
	out_data
}
