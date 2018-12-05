
summary <-
df_full_info %>% 
  mutate(
      landslide = ifelse( hazard_type == "landslide", 1, 0 )
      , earthquake = ifelse( hazard_type == "earthquake", 1, 0 )
  ) %>%
  filter(country > "a") %>%
  group_by(country,year(date)) %>%
  summarise(
		landslides = sum(landslide),
		earthquakes = sum(earthquake),
		fatalities = sum(fatalities),
		injuries = sum(injuries),
		avg_affected_pop = mean(population.dis),
		avg_elevation = mean(average_elevation),
		avg_magnitude = mean(magnitude),
		max_magnitude = max(magnitude),
		mode_damage = mode(damage_range),
		earthquake_houses_damaged = sum(houses_damaged),
		avg_distance_to_city = mean(distance_between)
		)


#Output to JSON
JSON_output <-
toJSON(summary, dataframe = c("rows"), matrix = c("rowmajor"),
Date = c("ISO8601"), POSIXt = c("ISO8601"), factor = c("string"),
complex = c("string"), raw = c("base64"),
null = c("null"), na = c("null"), auto_unbox = FALSE,
digits = 6, pretty = FALSE)

#save JSON object to file
write(JSON_output, file="disaster_summary.JSON")
write.csv(summary, file="disaster_summary.csv")





