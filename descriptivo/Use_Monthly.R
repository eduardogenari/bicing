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

timestamps_intervals <- dbGetQuery(con, "SELECT * FROM timestamps_intervals")
stations_intervals <- dbGetQuery(con, "SELECT * FROM stations_intervals")

combined_timestamps <- timestamps_intervals %>%
  left_join(stations_intervals, by = c("id" = "interval_id"))

combined_timestamps <- combined_timestamps %>%
  mutate(uso = input_num_bikes_available + output_num_bikes_available)

head(combined_timestamps)

monthly_bike_usage <- combined_timestamps %>%
  group_by(month) %>%
  summarise(total_net_bikes_available = sum(uso, na.rm = TRUE))

ggplot(monthly_bike_usage, aes(x = factor(month), y = total_net_bikes_available, group = 1)) +
  geom_line(color = "skyblue", size = 1) +  
  geom_point(color = "blue", size = 3) +  
  labs(
    title = "Monthly Bike Usage",
    x = "Month",
    y = "Station interactions (use)",
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

### OCTUBRE 2024 ####

combined_timestamps <- combined_timestamps %>%
  filter(year == "2024")
combined_timestamps <- combined_timestamps %>%
  filter(interval_type == "hours")
summary(combined_timestamps)
monthly_bike_usage <- combined_timestamps %>%
  group_by(month) %>%
  summarise(total_net_bikes_available = sum(input_num_bikes_available, na.rm = TRUE))
summary(monthly_bike_usage)
head(monthly_bike_usage)



combined_timestamps <- combined_timestamps %>%
  mutate(uso = input_num_bikes_available + output_num_bikes_available)
monthly_bike_usage <- combined_timestamps %>%
  group_by(month) %>%
  summarise(total_net_bikes_available = sum(uso, na.rm = TRUE))
summary(monthly_bike_usage)
head(monthly_bike_usage)

### OCTUBRE 2024 ####


