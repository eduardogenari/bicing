library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
  port = 5432,
  dbname = "proyecto_12",
  user = "postgres",
  password = "proyecto12upc"
)

# Fetch neighborhoods table
stations_intervals_data <- dbGetQuery(con, query = "select * from stations_intervals;")

# Save the data locally
saveRDS(stations_intervals_data, "stations_intervals_data.rds")

# Close the connection
dbDisconnect(con)
