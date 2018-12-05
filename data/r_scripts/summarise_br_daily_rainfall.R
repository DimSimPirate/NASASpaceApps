rainfall_br_data <- read.csv('analysis/rainfall_daily_br.csv')

rainfall_br_data$date <- as.Date(str_sub(rainfall_br_data$date,1,10), "%Y-%d-%m")
rainfall_br_agg <- rainfall_br_data %>% group_by(date) %>% summarise(mean(value))

rainfall_br_agg$country <- "BR"
rainfall_br_agg$rainfall_mm <- rainfall_br_agg$`mean(value)`
rainfall_br_agg$countrycode <- rainfall_br_agg$country

select(rainfall_br_agg
, date
, rainfall_mm
, countrycode
)

write.csv(rainfall_br_agg, file="/home/ryan/nasa_space_apps/space_apps_sydney_2017/data/rainfall_daily_br.csv")



disaster_data <- read.csv('/home/ryan/nasa_space_apps/space_apps_sydney_2017/data/disaster_full.csv', stringsAsFactors = FALSE)
rainfall_data <- read.csv("/home/ryan/nasa_space_apps/space_apps_sydney_2017/data/rainfall_daily_br.csv", stringsAsFactors = FALSE)

disaster_brazil_data <- disaster_data %>% filter(countrycode == "BR")
disaster_brazil_data$date <- as_date(disaster_brazil_data$date)
rainfall_data$date <- as_date(rainfall_data$date)

rainfall_data$year <- year(rainfall_data$date)
rainfall_data$month <- month(rainfall_data$date)
disaster_brazil_data$year <- year(disaster_brazil_data$date)
disaster_brazil_data$month <- month(disaster_brazil_data$date)


joined_data <- left_join(
  disaster_brazil_data,
  rainfall_data,
  by = c("date"),
  suffix = c(".rf", ".br")
)

joined_data <- joined_data %>% tbl_df()

joined_select <- select(joined_data
, date
, countrycode.br
, rainfall_mm
, id
) %>% distinct()

write.csv(joined_data, file="/home/ryan/nasa_space_apps/space_apps_sydney_2017/data/disaster_br_rainfall.csv")
