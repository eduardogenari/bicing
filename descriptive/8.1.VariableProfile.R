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
library(moments)  # For skewness and kurtosis
library(tidyr)
library(openxlsx)

stations_neighborhoods_consolidated <- dbGetQuery(con, "SELECT * FROM calc_stations_neighborhoods_consolidated")
str(stations_neighborhoods_consolidated)
summary(stations_neighborhoods_consolidated)

stations <- dbGetQuery(con, "SELECT * FROM mvw_latest_station_info")
neighborhoods <- dbGetQuery(con, "SELECT * FROM neighborhoods")

variable <- stations_neighborhoods_consolidated %>%
  mutate(across(where(bit64::is.integer64), as.numeric))

numeric_vars <- variable %>%
  select(where(is.numeric))


profile_variables <- function(df) {
  df %>%
    summarise(across(
      everything(),
      list(
        Min = ~ min(.x, na.rm = TRUE),
        Q1 = ~ quantile(.x, probs = 0.25, na.rm = TRUE),
        Median = ~ median(.x, na.rm = TRUE),
        Mean = ~ mean(.x, na.rm = TRUE),
        Q3 = ~ quantile(.x, probs = 0.75, na.rm = TRUE),
        Max = ~ max(.x, na.rm = TRUE),
        Missing = ~ sum(is.na(.x)),
        Missing_perc = ~ mean(is.na(.x)) * 100,
        Unique = ~ n_distinct(.x)
      ),
      .names = "{.col}.{.fn}"
    )) %>%
    # Pivot longer with names_pattern to correctly split on the final dot
    pivot_longer(
      cols = everything(),
      names_to = c("Variable", "Statistic"),
      names_pattern = "^(.*)\\.(.*)$",
      values_to = "Value"
    ) %>%
    pivot_wider(
      names_from = Statistic,
      values_from = Value
    )
}

profile <- profile_variables(numeric_vars)

print(profile)
write.xlsx(profile, "neighborhoods.xlsx", rowNames = FALSE)


hist(variable$neighborhood_daily_bikes_output ,col=NA, border = "darkred", main=NA, xlab =NA, ylab = NA)
boxplot(variable$neighborhood_daily_bikes_output, col="darkred")


ggplot(stations_neighborhoods_consolidated, aes(x = station_id)) +
  geom_histogram(fill = "steelblue", color = "black", bins = 30, alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Histograma de la Altitud de Estaciones",
    x = "Altitud",
    y = "Frecuencia"
  )






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


neighborhoods <- dbGetQuery(con, "
    SELECT
        n.neighborhood_code,n.neighborhood_name, 
        ST_AsText(n.geom) AS neighborhood_geom_wkt
    FROM neighborhoods n")
neighborhoods_sf <- st_as_sf(neighborhoods, wkt = "neighborhood_geom_wkt",crs = 4326)
