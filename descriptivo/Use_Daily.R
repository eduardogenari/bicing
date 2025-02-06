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

############### PERFILES DE USO POR DIA ######################
library(dplyr)
library(lubridate)
library(ggplot2)

timestamps_intervals <- dbGetQuery(con, "SELECT * FROM timestamps_intervals")
stations_intervals <- dbGetQuery(con, "SELECT * FROM vw_stations_intervals")
stations_days <- dbGetQuery(con, "SELECT * FROM calc_stations_minmaxlastreported")

summary(stations_intervals)
# combined_timestamps_stations <- timestamps_hours %>%
#   left_join(stations_intervals, by = c("id" = "interval_id"))

############### EN INTERVALOS DE 1 HORA ######################

stations_intervals_1 <- stations_intervals %>%
  filter(interval_value == "1")

# Extract the day of the week
stations_intervals_1 <- stations_intervals_1 %>%
  mutate(
    day_of_week = wday(interval_from, label = TRUE, abbr = FALSE, week_start = 1, locale = 'English'),
    date = as.Date(interval_from)  
  )

summary(stations_intervals_1)

# stations_intervals_1 <- stations_intervals_1 %>%
#   mutate(uso = input_num_bikes_available + output_num_bikes_available)

# daily_bike_usage_1h <- stations_intervals_1 %>%
#   group_by(day_of_week) %>%
#   summarise(total_net_bikes = sum(uso, na.rm = TRUE))   #### CALCULAR TOTALES

days_count <- stations_intervals_1 %>%
  group_by(day_of_week) %>%
  summarise(num_days = n_distinct(date))

daily_bike_usage_1h_avg <- stations_intervals_1 %>%
  group_by(day_of_week) %>%
  summarise(total_net_bikes = sum(output_num_bikes_available, na.rm = TRUE)) %>%
  left_join(days_count, by = "day_of_week") %>%
  mutate(avg_net_bikes = total_net_bikes / num_days)  

print(daily_bike_usage_1h_avg)

ggplot(daily_bike_usage_1h_avg, aes(x = factor(day_of_week), y = avg_net_bikes, group = 1)) +
  geom_line(color = "pink2", size = 1) +  
  geom_point(color = "darkred", size = 3) +  
  labs(
    title = "Daily Bike Usage - Average",
    x = "Day of the week",
    y = "Bikes used per day",
  ) +
  scale_y_continuous(limits = c(0, 50000)) +  # Set Y-axis from 0 to max
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

############### EN INTERVALOS DE 30 MINUTOS ######################

stations_intervals_30 <- stations_intervals %>%
  filter(interval_value == "30")

stations_intervals_30 <- stations_intervals_30 %>%
  mutate(day_of_week = wday(interval_from, label = TRUE, abbr = FALSE, week_start = 1, locale = 'English'))  # Full weekday names

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


