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

cyclable_total <- dbGetQuery(con, "
    SELECT 
      ST_AsText(c.geom) AS cyclable_total_geom_wkt
    FROM cyclable_total c;")

cyclable_total_sf <- st_as_sf(cyclable_lane, wkt = "cyclable_total_geom_wkt")


# ::geography para contar con la curvatura de la tierra (metros) ya que 4326 está en grados.
cyclable_neighborhood <- dbGetQuery(con, "
    SELECT
        n.neighborhood_code,n.neighborhood_name, 
        ST_AsText(n.geom) AS neighborhood_geom_wkt,
        SUM(ST_Length(ST_Intersection(c.geom, n.geom)::geography)) / 1000 AS cyclable_neighborhood_km 
    FROM neighborhoods n
    JOIN cyclable_total c 
    ON ST_Intersects(n.geom, c.geom)
    GROUP BY n.neighborhood_code
    ORDER BY cyclable_neighborhood_km DESC;
")

cyclable_neighborhood_sf <- st_as_sf(cyclable_neighborhood, wkt = "neighborhood_geom_wkt")
plot(cyclable_neighborhood_sf)
head(cyclable_neighborhood_sf)
tail(cyclable_neighborhood_sf)

neighborhoods_cyclable <- dbGetQuery(con, "SELECT * FROM vw_neighborhoods_cyclable;")

neighborhoods_cyclable <- neighborhoods_cyclable %>%
  mutate(cyclable_density = cyclable_m / area_ha)

head(neighborhoods_cyclable)
tail(neighborhoods_cyclable)


neighborhoods_cyclable %>%
  arrange(desc(cyclable_density)) %>%
  head(10)

neighborhoods_cyclable %>%
  arrange(desc(neighborhoods_cyclable)) %>%
  tail(10)


############################### PLOT DE KM POR BARRIO

ggplot(cyclable_neighborhood_sf) +
  geom_sf(aes(fill = cyclable_neighborhood_km)) +  
  scale_fill_gradient(low = "lightpink", high = "darkred") +  
  theme_minimal() +
  labs(title = "Cyclable lane per Neighborhood", fill = "Cyclable Lane (km)")
# geom_sf(data = cyclable_total_sf, color = "white", size = 1, alpha = 0.5)  


############################### PLOT DE BIKE LANE

ggplot() +
  geom_sf(data = cyclable_neighborhood_sf, fill = NA, color = "black", size = 0.3) +  
  theme_minimal() +
  labs(title = "Cyclable Lanes", fill = "Cyclable Lane (km)") +
  geom_sf(data = cyclable_total_sf, color = "darkred", size = 1)  

############################### PLOT DE M POR HA POR BARRIO

ggplot(cyclable_neighborhood_sf) +
  geom_sf(aes(fill = neighborhoods_cyclable$cyclable_density)) +  
  scale_fill_gradient(low = "lightpink", high = "darkred") +  
  theme_minimal() +
  labs(title = "Cyclable density per Neighborhood (meters of cyclable path per hectare)", fill = "Cyclable density")
# geom_sf(data = cyclable_total_sf, color = "white", size = 1, alpha = 0.5)  

