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

# ::geography para contar con la curvatura de la tierra (metros) ya que 4326 está en grados.
cyclable_total <- dbGetQuery(con, "
    SELECT
        n.neighborhood_code,n.neighborhood_name, 
        ST_AsText(n.geom) AS neighborhood_geom_wkt,
        SUM(ST_Length(ST_Intersection(c.geom, n.geom)::geography)) / 1000 AS cyclable_lane_km 
    FROM neighborhood n
    JOIN cyclable_total c 
    ON ST_Intersects(n.geom, c.geom)
    GROUP BY n.neighborhood_code
    ORDER BY cyclable_lane_km  DESC;
")

cyclable_total_sf <- st_as_sf(cyclable_total, wkt = "neighborhood_geom_wkt")
plot(cyclable_total_sf)

ggplot(cyclable_total_sf) +
  geom_sf(aes(fill = cyclable_lane_km)) +  
  scale_fill_gradient(low = "lightpink", high = "darkred") +  
  theme_minimal() +
  labs(title = "Cyclable lane per Neighborhood", fill = "Cyclable Lane (km)") 

