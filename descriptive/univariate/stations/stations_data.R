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

# Fetch the station table
stations_data <- dbGetQuery(con, "SELECT * FROM stations")

# Save the data locally
saveRDS(stations_data, "stations_data.rds")

# Close the connection
dbDisconnect(con)
