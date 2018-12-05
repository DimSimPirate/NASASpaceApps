df_earthquakes   <- read.csv(
			"earthquake_data/earthquakes.csv",
			sep='\t',
			header = TRUE)

df_earthquakes$date <- paste(df_earthquakes$month,df_earthquakes$day,df_earthquakes$year, sep='/') %>% as.Date("%m/%d/%Y")

df_earthquakes$tsunami_ind <- df_earthquakes$apps_sydney_2017.data.country_data.br

df_earthquakes$latitude <- df_earthquakes$latitude %>% as.numeric()
df_earthquakes$longitude <- df_earthquakes$longitude %>% as.numeric()

df_earthquakes$hazard_type <- "earthquake"

df_earthquakes$magnitude <- df_earthquakes$magnitute
df_earthquakes$fatalaties <- df_earthquakes$total_deaths
df_earthquakes$houses_damaged <- df_earthquakes$total_houses_damaged
df_earthquakes$damage_range <- df_earthquakes$total_damage_range


df_earthquakes$country <- df_earthquakes$country %>% str_to_title()

df_earthquakes <- select(df_earthquakes
, date
, country
, hazard_type
, magnitude
, tsunami_ind
, fatalaties
, injuries
, damage_range
, houses_damaged
, longitude
, latitude
) %>% distinct()


#save JSON object to file
write(JSON_output, file="disaster_main.JSON")
write.csv(union_data, file="disaster_main.csv")