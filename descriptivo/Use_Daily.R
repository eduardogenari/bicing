library(sf)
library(DBI)
library(RPostgres)

############# CONEXÓN A BASE DE DATOS ###########
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "proyecto_12",
  host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
  port = 5432,
  user = "postgres",
  password = "proyecto12upc"
)
dbListTables(con)

############### PERFILES DE USO POR ESTACION ######################
library(dplyr)
library(lubridate)
library(ggplot2)

timestamps_intervals <- dbGetQuery(con, "SELECT * FROM timestamps_intervals")
stations_intervals <- dbGetQuery(con, "SELECT * FROM vw_stations_intervals")

# combined_timestamps_stations <- timestamps_hours %>%
#   left_join(stations_intervals, by = c("id" = "interval_id"))

############### EN INTERVALOS DE 1 HORA ######################

stations_intervals_1 <- stations_intervals %>%
  filter(interval_value == "1")

stations_intervals_1 <- stations_intervals_1 %>%
  mutate(day_of_week = wday(timestamp, label = TRUE, abbr = FALSE, week_start = 1, locale = 'English'))  # Full weekday names

summary(stations_intervals_1)

stations_intervals_1 <- stations_intervals_1 %>%
  mutate(uso = input_num_bikes_available + output_num_bikes_available)

daily_bike_usage_1h <- stations_intervals_1 %>%
  group_by(day_of_week) %>%
  summarise(total_net_bikes = sum(uso, na.rm = TRUE))

ggplot(daily_bike_usage_1h, aes(x = factor(day_of_week), y = total_net_bikes, group = 1)) +
  geom_line(color = "skyblue", size = 1) +  
  geom_point(color = "blue", size = 3) +  
  labs(
    title = "Daily Bike Usage - 1h intervals",
    x = "Day",
    y = "Station interactions (use)",
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

############### EN INTERVALOS DE 30 MINUTOS ######################

stations_intervals_30 <- stations_intervals %>%
  filter(interval_value == "30")

stations_intervals_30 <- stations_intervals_30 %>%
  mutate(day_of_week = wday(timestamp, label = TRUE, abbr = FALSE, week_start = 1, locale = 'English'))  # Full weekday names

summary(stations_intervals_30)

stations_intervals_30 <- stations_intervals_30 %>%
  mutate(uso = input_num_bikes_available + output_num_bikes_available)

daily_bike_usage_30h <- stations_intervals_30 %>%
  group_by(day_of_week) %>%
  summarise(total_net_bikes = sum(uso, na.rm = TRUE))

ggplot(daily_bike_usage_30h, aes(x = factor(day_of_week), y = total_net_bikes, group = 1)) +
  geom_line(color = "skyblue", size = 1) +  
  geom_point(color = "blue", size = 3) +  
  labs(
    title = "Daily Bike Usage - 30min intervals",
    x = "Day",
    y = "Station interactions (use)",
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


