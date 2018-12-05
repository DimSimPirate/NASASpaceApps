



#take just BR
disaster_br <- 
	df_full_info %>%
		filter(countrycode == "BR")







#cross join to earthquakes
disaster_br$join <- 1
disaster_br$join <- 1
analysis_1 <-
		left_join(
			disaster_br,
			df_earthquakes,
			by = (c("join" = "join")),
			suffix = c(".a",".e")
		)

#get distance to each earthquake from each landslide
analysis_1$latitude.dis <- as.double(analysis_1$latitude.dis)
analysis_1$latitude<- as.double(analysis_1$latitude)
analysis_1$longitude.dis <- as.double(analysis_1$longitude.dis)
analysis_1$longitude<- as.double(analysis_1$longitude)
analysis_1$distance_between_l_e <-
	earth_radius * 2 *
	atan2(
		sqrt(
(
sin((analysis_1$latitude.dis - analysis_1$latitude)/2) * sin((analysis_1$latitude.dis - analysis_1$latitude)/2)
+
sin((analysis_1$longitude.dis - analysis_1$longitude)/2) * sin((analysis_1$longitude.dis - analysis_1$longitude)/2)
* cos(analysis_1$latitude.dis) * cos(analysis_1$latitude)
)
		),
		sqrt(
1 -
(
sin((analysis_1$latitude.dis - analysis_1$latitude)/2) * sin((analysis_1$latitude.dis - analysis_1$latitude)/2)
+
sin((analysis_1$longitude.dis - analysis_1$longitude)/2) * sin((analysis_1$longitude.dis - analysis_1$longitude)/2)
* cos(analysis_1$latitude.dis) * cos(analysis_1$latitude)
)
		)
	)

#order by distance to earthquakes to
analysis_2 <-
	analysis_1 %>%
	arrange(id.a,distance_between_l_e)

#Take minimum distance, and count within 2500km
analysis_3 <-
analysis_2 %>% 
  mutate(
      within_2500 = ifelse( distance_between_l_e <= 2500 , 1, 0 )
  ) %>%
  group_by(
	id.a, date.a, country.a, hazard_type.a, trigger, fatalities.a, injuries.a,
	hazard_size, distance, population.dis, countrycode, tstamp, latitude.dis, longitude.dis
  ) %>%
  summarise(
	count_nearby_earthquakes = sum(within_2500),
	closest_earthquake = min(distance_between_l_e)
  )







#add rainfall data
rainfall_br_data <- read.csv('analysis/disaster_br_rainfall.csv')

analysis_final <-
		left_join(
			analysis_3,
			rainfall_br_data,
			by = (c("id.a" = "id"))
		)



analysis_really_final_i_think <-
analysis_final[,c(
		"id.a",
		"date.a",
		"country.a",
		"hazard_type.a",
		"fatalities.a",
		"injuries.a",
		"population.dis.x",
		"countrycode",
		"latitude.dis.x",
		"longitude.dis.x",
		"count_nearby_earthquakes",
		"closest_earthquake",
		"average_elevation",
		"rainfall_mm",
		"city_name",
		"latitude.cit",
		"longitude.cit"
)]
colnames(analysis_really_final_i_think) <-
	c(
		"id",
		"date",
		"country",
		"hazard_type",
		"fatalities",
		"injuries",
		"population_affected",
		"country_code",
		"latitude",
		"longitude",
		"count_nearby_earthquakes",
		"closest_earthquake",
		"average_elevation",
		"country_recent_rainfall_mm",
		"city",
		"latitude_city",
		"longitude_city"
)


names(analysis_really_final_i_think)

#output
write.csv(analysis_really_final_i_think,'analysis/analysis_data.csv')


#summarise per city
summary_city <-
analysis_really_final_i_think %>% 
  mutate(
      landslide = ifelse( hazard_type == "landslide", 1, 0 )
  ) %>%
  group_by(city) %>%
  summarise(
		count_events = sum(landslide),
		fatalities = sum(fatalities),
		injuries = sum(injuries),
		avg_pop_affected = mean(population_affected),
		avg_recent_rainfall = mean(country_recent_rainfall_mm),
		average_elevation = mean(average_elevation),
		count_nearby_earthquakes = max(count_nearby_earthquakes),
		closest_earthquake = min(closest_earthquake)
		)



names(summary_city)

#pairs



pairs(summary_city[,
		c(
		"count_events",
		"fatalities",
		"injuries",
		"avg_pop_affected",
		"avg_recent_rainfall",
		"average_elevation",
		"count_nearby_earthquakes",
		"closest_earthquake"
		)
	])








#summarise per city
summary_graphing <-
analysis_really_final_i_think %>% 
  mutate(
      landslide = ifelse( hazard_type == "landslide", 1, 0 )
  ) %>%
  group_by(year = year(analysis_really_final_i_think$date)) %>%
  summarise(
		count_events = sum(landslide),
		fatalities = sum(fatalities),
		injuries = sum(injuries),
		avg_pop_affected = mean(population_affected),
		avg_recent_rainfall = mean(country_recent_rainfall_mm)
		)
plot(analysis_really_final_i_think$date,analysis_really_final_i_think$fatalities)



library(ggmap)
library(ggplot2)

library(ggmap, quietly=TRUE)

map = get_map(location = c(-77.08597,38.7),source="google",maptype="roadmap",zoom=12)
ggmap(map)+geom_point(data = dat2,aes(x=longitude,y=latitude,size=Magnitude))






