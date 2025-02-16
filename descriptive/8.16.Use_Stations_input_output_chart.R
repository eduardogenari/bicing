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
library(lubridate) #timstamps
library(ggplot2)

stations <- dbGetQuery(con, "
  SELECT DISTINCT
    s.station_id,
    s.address,
    ST_AsText(s.geom) AS geom_wkt  
  FROM stations s
")

stations_days <- dbGetQuery(con, "SELECT * FROM calc_stations_minmaxlastreported")
str(stations_days)

stations_days <- stations_days %>%
  filter(is.na(year))

str(stations)
stations_intervals <- dbGetQuery(con, "SELECT * FROM vw_stations_intervals")
str(stations_intervals)

summary(stations_intervals)

############### cÁLCULO DE USO DE ESTACIONES (MAÑANAS) ######################

stations_activity_1_morning <- stations_intervals %>%
  filter(interval_value == 1, hour(timestamp) < 12)  # Keep only morning data

stations_activity_1_morning <- stations_activity_1_morning %>%
  group_by(station_id) %>%
  summarise(
    total_input = sum(input_num_bikes_available, na.rm = TRUE),
    total_output = sum(output_num_bikes_available, na.rm = TRUE)
  )

stations_activity_1_morning <- stations_activity_1_morning %>%
  left_join(stations_days %>% select(station_id, numdays), by = "station_id") %>%
  mutate(
    total_input_avg = total_input / numdays,
    total_output_avg = total_output / numdays
  )

summary(stations_activity_1_morning)
head(stations_activity_1_morning)


############### TOP 10 FOR LABELLING ######################


library(dplyr)

# Top 10 by input
top_input_stations_morning <- stations_activity_1_morning %>%
  arrange(desc(total_input_avg)) %>%
  slice_head(n = 10)

# Top 10 by output
top_output_stations_morning <- stations_activity_1_morning %>%
  arrange(desc(total_output_avg)) %>%
  slice_head(n = 10)


############### CHART MORNING USE ######################

library(ggplot2)

ggplot(stations_activity_1_morning, aes(x = total_output_avg, y = total_input_avg)) +
  geom_point(color = "red", alpha = 0.6) +  # Red points with transparency
  geom_abline(slope = 1,  linetype = "dashed") +  # Reference line
  geom_text(data = top_input_stations_morning,aes(label = station_id), size = 3, vjust = -1, hjust = 0.5) + #input
  geom_text(data = top_output_stations_morning,aes(label = station_id), size = 3, vjust = -1, hjust = 0.5) +
  theme_minimal() +
  labs(
    title = "Bike Station Activity (Mornings - Before 12AM)",
    x = "Bike Output (Origen) - Daily average",
    y = "Bike Input (Destination) - Daily average"
  )

############### cÁLCULO DE USO DE ESTACIONES (TARDES) ######################

stations_activity_1_afternoon <- stations_intervals %>%
  filter(interval_value == 1, hour(timestamp) > 12)  # Keep only morning data

stations_activity_1_afternoon <- stations_activity_1_afternoon %>%
  group_by(station_id) %>%
  summarise(
    total_input = sum(input_num_bikes_available, na.rm = TRUE),
    total_output = sum(output_num_bikes_available, na.rm = TRUE)
  )

stations_activity_1_afternoon <- stations_activity_1_afternoon %>%
  left_join(stations_days %>% select(station_id, numdays), by = "station_id") %>%
  mutate(
    total_input_avg = total_input / numdays,
    total_output_avg = total_output / numdays
  )

summary(stations_activity_1_afternoon)
head(stations_activity_1_afternoon)


############### TOP 10 FOR LABELLING ######################


library(dplyr)

# Top 10 by input
top_input_stations_afternoon <- stations_activity_1_afternoon %>%
  arrange(desc(total_input_avg)) %>%
  slice_head(n = 10)

# Top 10 by output
top_output_stations_afternoon <- stations_activity_1_afternoon %>%
  arrange(desc(total_output_avg)) %>%
  slice_head(n = 10)


############### CHART TARDES USE ######################

library(ggplot2)

ggplot(stations_activity_1_afternoon, aes(x = total_output_avg, y = total_input_avg)) +
  geom_point(color = "red", alpha = 0.6) +  # Red points with transparency
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +  # Reference line
  geom_text(data = top_input_stations_afternoon,aes(label = station_id), size = 3, vjust = -1, hjust = 0.5) + #input
  geom_text(data = top_output_stations_afternoon,aes(label = station_id), size = 3, vjust = -1, hjust = 0.5) +
  theme_minimal() +
  labs(
    title = "Bike Station Activity (Afternoon - After 12AM)",
    x = "Bike Output (Origin) - Daily average",
    y = "Bike Input (Destination) - Daily average"
  )




