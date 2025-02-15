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

stations <- dbGetQuery(con, "
  SELECT DISTINCT
    s.station_id,
    s.address,
    s.lat,
    s.lon,
    ST_AsText(s.geom) AS geom_wkt  
  FROM stations s
")
str(stations)
stations$geom_sf <- st_as_sf(stations, wkt = "geom_wkt")

stations_days <- dbGetQuery(con, "SELECT * FROM calc_stations_minmaxlastreported")
str(stations_days)
stations_days <- stations_days %>%
  filter(is.na(year))

stations_intervals <- dbGetQuery(con, "SELECT * FROM mvw_stations_intervals")
str(stations_intervals)
summary(stations_intervals)

stations_neighborhoods_consolidated <- dbGetQuery(con, "SELECT * FROM calc_stations_neighborhoods_consolidated")
str(stations_neighborhoods_consolidated)
summary(stations_neighborhoods_consolidated)

neighborhoods <- dbGetQuery(con, "
    SELECT
        n.neighborhood_code,n.neighborhood_name, 
        ST_AsText(n.geom) AS neighborhood_geom_wkt
    FROM neighborhoods n")
neighborhoods_sf <- st_as_sf(neighborhoods, wkt = "neighborhood_geom_wkt",crs = 4326)


############### PREPARACIÓN DE LOS DATOS: INTERVALOS 1 hora + JOIN capacity + JOIN geom... ######################

stations_activity_1 <- stations_intervals %>%
  filter(interval_value == 1)  

stations_activity_1 <- stations_activity_1 %>%
  left_join(stations_neighborhoods_consolidated %>%
              select(station_id, station_address, neighborhood_name,station_capacity), 
            by = "station_id")

stations_activity_1 <- stations_activity_1 %>%
  left_join(stations %>%
              select(station_id,lat, lon), 
            by = "station_id", multiple = "last")

############### ESTACIONES CON MÁS INTERVALES +90% OCUPACION... ######################

stations_most_occupied <- stations_activity_1 %>%
  mutate(
    initial_occupancy = initial_num_bikes_available / station_capacity,
    final_occupancy = final_num_bikes_available / station_capacity
  ) %>%
  group_by(station_id, station_address, neighborhood_name, lat, lon) %>%  
  mutate(total_intervals = n()) %>%  # CONTAR TOTAL DE INTERVALOS POR ESTACION
  filter(initial_occupancy >= 0.9 & final_occupancy >= 0.9) %>%
  summarise(
    total_high_occupancy_hours = n(),
    total_intervals = first(total_intervals),
    high_occupancy_percentage = (total_high_occupancy_hours / total_intervals) * 100
  ) %>%
  arrange(desc(high_occupancy_percentage)) 

stations_most_occupied_sincopaamerica <- stations_most_occupied[-c(1,2), ]  #eliminamos los dos primeros registros, corresponden a estaciones temporales

stations_most_occupied_sf <- st_as_sf(stations_most_occupied_sincopaamerica, coords = c("lon", "lat"), crs = 4326)

############### MAP ######################

library(ggplot2)

ggplot() +
  geom_sf(data = neighborhoods_sf, fill = NA, color = "black", size = 0.2) +  
  labs(title = "Stations with high Occupancy (+90% docks occupied)", 
       size = "% of hours with high occupancy", 
       color = "% of hours with high occupancy") +
  geom_sf(data = stations_most_occupied_sf, 
          aes(size = high_occupancy_percentage, color = high_occupancy_percentage), alpha = 0.7) +
  scale_size(range = c(1, 8)) +  # Adjust the range for better visualization
  scale_color_gradient(low = "#FFCDD2", high = "#8B0000", name = "% of hours with high occupancy") +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "white", color = "white"),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

library(openxlsx)
write.xlsx(stations_most_occupied, "stations_most_occupied.xlsx", rowNames = FALSE)

############### ESTACIONES CON MÁS INTERVALoS >10% DISPONIBILIDAD ######################

stations_less_availability <- stations_activity_1 %>%
  mutate(
    initial_occupancy = initial_num_bikes_available / station_capacity,
    final_occupancy = final_num_bikes_available / station_capacity
  ) %>%
  group_by(station_id, station_address, neighborhood_name, lat, lon) %>%  
  mutate(total_intervals = n()) %>%  # Contar total de intervalos por estación
  filter(initial_occupancy <= 0.1 & final_occupancy <= 0.1) %>%
  summarise(
    total_low_availability_hours = n(),
    total_intervals = first(total_intervals),
    low_availability_percentage = (total_low_availability_hours / total_intervals) * 100
  ) %>%
  arrange(desc(low_availability_percentage))

stations_less_availability_sf <- st_as_sf(stations_less_availability, coords = c("lon", "lat"), crs = 4326)

############### MAP ######################

ggplot() +
  geom_sf(data = neighborhoods_sf, fill = NA, color = "black", size = 0.2) +  
  labs(title = "Stations with low availability (<10% bikes availables)", 
       size = "% of hours with low availability", 
       color = "% of hours with low availability") +
  geom_sf(data = stations_less_availability_sf, 
          aes(size = low_availability_percentage, color = low_availability_percentage), alpha = 0.7) +
  scale_size(range = c(1, 6)) +  
  scale_color_gradient(low = "#FFCDD2", high = "#8B0000", name = "% of hours with low availability") +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "white", color = "white"),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

write.xlsx(stations_less_availability, "stations_stations_less_availability.xlsx", rowNames = FALSE)


rm(stations_activity_1)
rm(stations_most_occupied)



