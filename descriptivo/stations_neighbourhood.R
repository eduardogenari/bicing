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

###############################

stations_data <- dbGetQuery(con, "
  SELECT 
      n.neighborhood_name, 
      ST_AsText(n.geom) AS neighborhood_geom_wkt,
      COUNT(DISTINCT s.station_id) AS num_stations
  FROM neighborhood n
  LEFT JOIN stations s ON ST_Intersects(n.geom, s.geom)
  GROUP BY n.neighborhood_name, n.geom
  ORDER BY num_stations DESC;
")

stations_data$num_stations <- as.integer(stations_data$num_stations)
stations_neighborhood <- st_as_sf(stations_data, wkt = "neighborhood_geom_wkt")
plot(stations_neighborhood)

ggplot(stations_neighborhood) +
  geom_sf(aes(fill = num_stations)) +  
  scale_fill_gradientn(
    colors = c("white", "lightpink", "darkred"),
    values = scales::rescale(c(0, 1, max(stations_neighborhood$num_stations))),
    na.value = "white"
  ) +  
  theme_minimal() +
  labs(title = "Number of Bike Stations per Neighborhood", fill = "Number of Stations")

