#!/usr/bin/Rscript

#Initialise
#setwd("C:/Users/Alec/Documents/NASA/space_apps_sydney_2017/data")
#setwd("/home/ryan/nasa_space_apps/space_apps_sydney_2017/data")
#install.packages('dplyer')
#install.packages('lubridate')
#install.packages('stringr')
#install.packages('jsonlite')
library(dplyr, quietly=TRUE)
library(lubridate, quietly=TRUE)
library(stringr, quietly=TRUE)
library(jsonlite, quietly=TRUE)



#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
#------------------------------MAIN-DATA-FILE------------------------------------
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------

#Read Data
df_landslide <- read.csv(
			"Global_Landslide_Catalog_Export.csv",
			header = TRUE)

#head(df_landslide)

df_landslide$date   <- str_pad(df_landslide$date, 10, side = c("left"), pad = "0")
df_landslide$date   <- as.Date(df_landslide$date, "%m/%d/%Y")

df_landslide$hazard_subtype <- df_landslide$landslide_type
df_landslide$trigger_name <- df_landslide$storm_name
df_landslide$hazard_size <- df_landslide$landslide_size

df_landslide$location_accuracy <- str_replace(df_landslide$location_accuracy, "Known_within_", "")
df_landslide$location_accuracy <- str_replace(df_landslide$location_accuracy, "_km", "")
df_landslide$location_accuracy <- str_replace(df_landslide$location_accuracy, "Unknown", "")
df_landslide$location_accuracy <- as.numeric(df_landslide$location_accuracy)

df_landslide$distance   <- as.numeric(df_landslide$distance)
df_landslide$population <- as.numeric(df_landslide$population)
df_landslide$latitude   <- as.numeric(df_landslide$latitude)
df_landslide$longitude  <- as.numeric(df_landslide$longitude)




#Remove useless columns
df_landslide <-
select(df_landslide,
  id
, date
, country
, hazard_type
, hazard_subtype
, trigger
, trigger_name
, fatalities
, injuries
, source_name
, source_link
, location_description
, location_accuracy
, hazard_size
, distance
, population
, countrycode
, continentcode
, tstamp
, latitude
, longitude
)



df_earthquakes   <- read.csv(
			"earthquake_data/earthquakes.csv",
			sep='\t',
			header = TRUE)

df_earthquakes$date <- paste(df_earthquakes$month,df_earthquakes$day,df_earthquakes$year, sep='/') %>% as.Date("%m/%d/%Y")

df_earthquakes$tsunami_ind <- df_earthquakes$apps_sydney_2017.data.country_data.br

df_earthquakes$latitude <- df_earthquakes$latitude %>% as.numeric()
df_earthquakes$longitude <- df_earthquakes$longitude %>% as.numeric()

df_earthquakes$hazard_type <- "earthquake"
df_earthquakes$id <- seq_len(nrow(df_earthquakes))+20000

df_earthquakes$magnitude <- df_earthquakes$magnitute
df_earthquakes$fatalities <- df_earthquakes$total_deaths
df_earthquakes$houses_damaged <- df_earthquakes$total_houses_damaged
df_earthquakes$damage_range <- df_earthquakes$total_damage_range

df_earthquakes$country <- df_earthquakes$country %>% str_to_title()

df_earthquakes <- select(df_earthquakes
, id
, date
, country
, hazard_type
, magnitude
, tsunami_ind
, fatalities
, injuries
, damage_range
, houses_damaged
, longitude
, latitude
) %>% distinct()

union_data <- bind_rows(df_landslide,df_earthquakes)


#Output to JSON
JSON_output <-
toJSON(union_data, dataframe = c("rows"), matrix = c("rowmajor"),
Date = c("ISO8601"), POSIXt = c("ISO8601"), factor = c("string"),
complex = c("string"), raw = c("base64"),
null = c("null"), na = c("null"), auto_unbox = FALSE,
digits = 6, pretty = FALSE)

#save JSON object to file
write(JSON_output, file="disaster_main.JSON")
write.csv(union_data, file="disaster_main.csv")



