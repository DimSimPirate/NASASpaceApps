#!/usr/bin/Rscript


#Initialise
setwd("C:/Users/Alec/Documents/NASA/space_apps_sydney_2017/data")
#setwd("/home/ryan/nasa_space_apps/space_apps_sydney_2017/data")
#install.packages('dplyer')
#install.packages('lubridate')
#install.packages('stringr')
#install.packages('jsonlite')
library(dplyr, quietly=TRUE)
library(lubridate, quietly=TRUE)
library(stringr, quietly=TRUE)
library(jsonlite, quietly=TRUE)




#Read Data
df_cities      <- read.csv(
			"cities_data/cities1000.csv",
			sep="\t",
			stringsAsFactors = FALSE,
			header = TRUE)


#Join info
df_full_info <- left_join(
		union_data,
		df_cities,
		by = c("countrycode" = "country_code"),
		suffix = c(".dis",".cit")
)
df_full_info$latitude.dis <- as.double(df_full_info$latitude.dis)
df_full_info$latitude.cit <- as.double(df_full_info$latitude.cit)
df_full_info$longitude.dis <- as.double(df_full_info$longitude.dis)
df_full_info$longitude.cit <- as.double(df_full_info$longitude.cit)



#Get distances
earth_radius <- 6371
df_full_info$distance_between <-
	earth_radius * 2 *
	atan2(
		sqrt(
(
sin((df_full_info$latitude.dis - df_full_info$latitude.cit)/2) * sin((df_full_info$latitude.dis - df_full_info$latitude.cit)/2)
+
sin((df_full_info$longitude.dis - df_full_info$longitude.cit)/2) * sin((df_full_info$longitude.dis - df_full_info$longitude.cit)/2)
* cos(df_full_info$latitude.dis) * cos(df_full_info$latitude.cit)
)
		),
		sqrt(
1 -
(
sin((df_full_info$latitude.dis - df_full_info$latitude.cit)/2) * sin((df_full_info$latitude.dis - df_full_info$latitude.cit)/2)
+
sin((df_full_info$longitude.dis - df_full_info$longitude.cit)/2) * sin((df_full_info$longitude.dis - df_full_info$longitude.cit)/2)
* cos(df_full_info$latitude.dis) * cos(df_full_info$latitude.cit)
)
		)
	)




#Take minimum distance
df_full_info <- arrange(df_full_info, id, distance_between)
df_full_info <- df_full_info[!duplicated(df_full_info$id),]


#Output to JSON
JSON_output <-
toJSON(df_full_info, dataframe = c("rows"), matrix = c("rowmajor"),
Date = c("ISO8601"), POSIXt = c("ISO8601"), factor = c("string"),
complex = c("string"), raw = c("base64"),
null = c("null"), na = c("null"), auto_unbox = FALSE,
digits = 6, pretty = FALSE)

#save JSON object to file
write(JSON_output, file="disaster_full.JSON")
write.csv(df_full_info, file="disaster_full.csv")







