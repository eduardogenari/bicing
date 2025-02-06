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

stations <- dbGetQuery(con, "
  SELECT DISTINCT
    s.station_id,
    s.address,
    ST_AsText(s.geom) AS geom_wkt  
  FROM stations s
")

str(stations)
stations_intervals <- dbGetQuery(con, "SELECT * FROM vw_stations_intervals")
str(stations_intervals)

############### cÁLCULO DE USO DE ESTACIONES ######################

station_use <- stations_intervals %>%
  group_by(station_id) %>%
  summarise(total_bike_usage = as.numeric(sum(input_num_bikes_available + output_num_bikes_available, na.rm = TRUE)))

head(station_use)

# stations_unique <- stations %>%
#   distinct(station_id, .keep_all = TRUE)

stations_final <- left_join(stations, station_use, by = "station_id")
head(stations_final)
summary(stations_final)

############### MAPA BUBBLE ######################

library(ggplot2)
library(sf)

# Ensure the geometry is in sf format, if not already
stations_final_sf <- st_as_sf(stations_final, wkt = "geom_wkt")


# Create the bubble map
ggplot(stations_final_sf) +
  geom_sf(aes(size = total_bike_usage, fill = total_bike_usage), shape = 21, color = "black") +
  scale_size_continuous(range = c(1, 10)) +  # Adjust the bubble size range
  scale_fill_gradient(low = "lightpink", high = "darkred") +  # Red color scale
  theme_minimal() +
  labs(title = "Bike Station Usage", fill = "Total Usage", size = "Bike Usage") +
  theme(legend.position = "bottom")  # Adjust legend position

