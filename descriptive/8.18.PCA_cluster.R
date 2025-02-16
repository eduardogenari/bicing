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

neighborhoods_consolidated <- dbGetQuery(con, "SELECT * FROM calc_neighborhoods_consolidated")
str(stations_neighborhoods_consolidated)
summary(stations_neighborhoods_consolidated)

############### PREPARACIÓN DE LOS DATOS: INTERVALOS, TOTALS, AVERAGES... ######################

stations_activity_1 <- stations_intervals %>%
  filter(interval_value == 1)  # MORNINGS

stations_activity_1 <- stations_activity_1 %>%
  group_by(station_id) %>%
  summarise(
    total_input = sum(input_num_bikes_available, na.rm = TRUE),
    total_output = sum(output_num_bikes_available, na.rm = TRUE),
    total_usage = total_input + total_output
  )

stations_activity_1 <- stations_activity_1 %>%
  left_join(stations_days %>% select(station_id, numdays), by = "station_id") %>%
  mutate(
    total_input_avg = total_input / numdays,
    total_output_avg = total_output / numdays,
    station_daily_usage_avg = total_usage / numdays
  )

summary(stations_activity_1)
head(stations_activity_1)

############### CHECK DATA FRAMES ######################

glimpse(stations)
glimpse(stations_days)
glimpse(stations_neighborhoods_consolidated)


stations_cluster<- stations_activity_1 %>%
  inner_join(stations, by = "station_id") %>%
  select(station_id, address, lat, lon, geom_sf, numdays, total_input_avg, total_output_avg) %>%
  na.omit()  

stations_cluster <- stations_activity_1 %>%
  left_join(
    stations %>% 
      distinct(station_id, .keep_all = TRUE),
    by = "station_id"
  ) %>%
  left_join(
    stations_neighborhoods_consolidated %>% 
      distinct(station_id, .keep_all = TRUE) %>%
      mutate(
        neighborhood_daily_usage = neighborhood_daily_bikes_input + neighborhood_daily_bikes_output,
        neighborhood_cyclable_density = neighborhood_cyclable_m / neighborhood_area_ha
      ) %>%
      select(
        station_id, 
        station_altitude, 
        neighborhood_code,
        neighborhood_perc_women, 
        neighborhood_population, 
        neighborhood_average_age,  
        neighborhood_gross_income, 
        neighborhood_avg_altitude,
        neighborhood_daily_bikes_output,
        neighborhood_capacity,
        neighborhood_cyclable_density,
        neighborhood_daily_usage
      ),
    by = "station_id"
  ) %>%
  select(
    station_id, neighborhood_code, address, lat, lon, geom_sf, numdays,
    total_input_avg, total_output_avg, station_daily_usage_avg, station_altitude,
    neighborhood_perc_women, neighborhood_population, neighborhood_average_age,
    neighborhood_gross_income, neighborhood_cyclable_density,
    neighborhood_avg_altitude, neighborhood_daily_usage,
    neighborhood_capacity
  ) %>%
  na.omit() 

# stations_cluster_morning <- stations_cluster_morning %>%
#   mutate(
#     lon_scaled = (lon - min(lon)) / (max(lon) - min(lon)),
#     lat_scaled = (lat - min(lat)) / (max(lat) - min(lat))
#   )

glimpse(stations_cluster)
summary(stations_cluster)



################################ CORRELATIONS HEATMAP ####################################################
library(dplyr)
library(ggcorrplot)


numeric_vars <- stations_cluster %>%
  select(where(is.numeric))
vars <- stations_cluster[, c("station_daily_usage_avg", "station_altitude", "neighborhood_perc_women", 
                                     "neighborhood_population", "neighborhood_average_age", 
                                     "neighborhood_gross_income", "neighborhood_cyclable_density",
                             "neighborhood_avg_altitude", "neighborhood_daily_usage",
                             "neighborhood_capacity")]

corr_matrix <- cor(vars, use = "pairwise.complete.obs")

ggcorrplot(corr_matrix,
           type = "lower",       
           lab = TRUE,          
           lab_size = 3,        
           colors = c("blue", "white", "red"),  
           title = "Heatmap de Correlaciones",
           ggtheme = theme_minimal())

print(corr_matrix)

################################ MORNINGS OUTPUTS ####################################################

############### NORMALIZAR + PCA Principal Component Analysis ############### 
library(FactoMineR)
library(factoextra)
library(NbClust)
stations_cluster_morning$neighborhood_population <- as.numeric(stations_cluster_morning$neighborhood_population)
stations_cluster_morning$neighborhood_capacity <- as.numeric(stations_cluster_morning$neighborhood_capacity)

res.pca <- PCA(stations_cluster[, c("total_output_avg", 
                                            "station_altitude", "neighborhood_perc_women", 
                                            "neighborhood_population", "neighborhood_average_age", 
                                            "neighborhood_gross_income", "neighborhood_cyclable_density")], 
               scale.unit=TRUE, graph=FALSE)

res.pca <- PCA(stations_cluster[, c("neighborhood_perc_women", 
                                            "neighborhood_population", "neighborhood_average_age", 
                                            "neighborhood_gross_income", "neighborhood_cyclable_density",
                                            "neighborhood_avg_altitude", "neighborhood_daily_usage",
                                            "neighborhood_capacity")], 
               scale.unit=TRUE, graph=FALSE)
summary(res.pca)


neighborhoods_consolidated$stations_capacity <- as.numeric(neighborhoods_consolidated$stations_capacity)
neighborhoods_consolidated$population <- as.numeric(neighborhoods_consolidated$population)
neighborhoods_consolidated$cyclable_density <- neighborhoods_consolidated$cyclable_m / neighborhoods_consolidated$area_ha 


res.pca <- PCA(neighborhoods_consolidated[, c("perc_women","population", "average_age", 
                                            "gross_income", "cyclable_density",
                                            "stations_avg_altitude", "daily_bikes_output",
                                            "stations_capacity")], 
               scale.unit=TRUE, graph=FALSE)


summary(res.pca)
barplot(res.pca$eig[,1], main="Eigenvalues", names.arg=paste("dim", 1:nrow(res.pca$eig)))
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 100))
fviz_pca_var(res.pca, col.var = "black")
fviz_pca_ind(res.pca)
fviz_pca_biplot(res.pca)

nb_clust <- NbClust(res.pca$ind$coord[, 1:3], diss = NULL, distance = "euclidean", method = "ward.D2", index = "all") #selecciono X componentes principales que explican X%
print(nb_clust)

summary(stations_cluster_morning)

############### CLUSTERING K MEANS ############### 

set.seed(123)
res.kmeans <- kmeans(res.pca$ind$coord[, 1:3], centers = 3)  #ASUMIENDO X CLUSTERS
neighborhoods_consolidated$cluster <- factor(res.kmeans$cluster)
fviz_cluster(res.kmeans, data = res.pca$ind$coord[, 1:3], geom = "point")
# library(plotly)
# plot_ly(x = res.pca$ind$coord[,1], y = res.pca$ind$coord[,2], z = res.pca$ind$coord[,3], type = "scatter3d", mode = "markers", color = res.kmeans$cluster)
# 

fviz_cluster(res.kmeans, data = res.pca$ind$coord[, 1:3], geom = "point") +
  # Add the station_id labels
  geom_text(aes(label = neighborhoods_consolidated$neighborhood_code), 
            color = "black", 
            size = 3, 
            vjust = -1, 
            hjust = 1) # Adjust position of the text if needed

fviz_cluster(res.kmeans, 
             data = stations_cluster_morning[, c("lon", "lat")], 
             geom = "point",
             repel = TRUE) + # Overlap
  geom_text(aes(label = stations_cluster_morning$station_id), 
            color = "black", size = 3, vjust = -1, hjust = 1)





############### COMPONENTES PRINCIPALES ############### 
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 100))

############### CLUSTER PROFILE ############### 
stations_cluster_morning %>%
  group_by(cluster) %>%
  summarize(
    mean_output = mean(total_output_avg),
    mean_lat = mean(lat),
    mean_lon = mean(lon)
  )
############### OUTLIERS EN LOS CLUSTERS ############### 
dist_from_center <- sqrt(rowSums(res.pca$ind$coord^2))
stations_cluster_morning$distance_from_center <- dist_from_center
boxplot(stations_cluster_morning$distance_from_center, main = "Distance from PCA center")

############### CORRELACION ENTRE VARIABLES############### 

cor(stations_cluster_morning[, c("total_output_avg", "lat", "lon", 
                                 "station_altitude", "neighborhood_perc_women", 
                                 "neighborhood_average_age","neighborhood_gross_income", "neighborhood_cyclable_density")])




############### DBSCAN  ############### 

library(dbscan)

# Prepare latitude & longitude
coords <- stations_cluster_morning[, c("total_output_avg","lat", "lon")]

# Apply DBSCAN (adjust eps & minPts based on dataset size)
res.dbscan <- dbscan(coords, eps = 1, minPts = 20) 

# Assign clusters
stations_cluster_morning$cluster_dbscan <- factor(res.dbscan$cluster)

# Plot results

ggplot(stations_cluster_morning, aes(x = lon, y = lat, color = cluster_dbscan)) +
  geom_point(size = 3) +
  theme_minimal()















