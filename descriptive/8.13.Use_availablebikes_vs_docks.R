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

############### BIKES VS DOCKS ######################
############### CARGAR t1 100millones ######################
library(lubridate)
library(dplyr)


stations_t1 <- dbGetQuery(con, "SELECT * FROM stations_status_t1")
str(stations_t1)

stations_t1$hour <- hour(stations_t1$last_reported)

stations_hourly <- stations_t1[, c("hour", "num_bikes_available", "num_docks_available")]

hourly_avg <- stations_hourly %>%
  group_by(hour) %>%
  summarise(
    avg_bikes_available = mean(num_bikes_available, na.rm = TRUE),
    avg_docks_available = mean(num_docks_available, na.rm = TRUE)
  )

head(hourly_avg)

############### CHART ######################
library(ggplot2)

ggplot(hourly_avg, aes(x = hour)) +
  geom_line(aes(y = avg_bikes_available, color = "Bikes Available"), size = 1) + 
  geom_line(aes(y = avg_docks_available, color = "Docks Available"), size = 1) +
  labs(
    title = "Average Bikes and Docks Available by Hour",
    x = "Hour of the Day",
    y = "Average Availability",
    color = "Legend"
  ) +
  scale_color_manual(values = c("Bikes Available" = "darkred", "Docks Available" = "red")) +
  scale_x_continuous(breaks = 0:23) +
  theme_minimal() +
  theme(legend.position = "top")
