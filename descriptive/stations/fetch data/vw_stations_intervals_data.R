library(DBI)
library(RPostgres)
library(logger)

# Initialize logger
log_appender(appender_console(lines = TRUE))

# Connect to the database
log_info("Connecting to the database...")
con <- dbConnect(
  RPostgres::Postgres(),
  host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
  port = 5432,
  dbname = "proyecto_12",
  user = "postgres",
  password = "proyecto12upc"
)
log_info("Connected to the database.")

# Fetch vw_stations_intervals table
log_info("Fetching vw_stations_intervals table...")
vw_stations_intervals_data <- dbGetQuery(con, "SELECT * FROM vw_stations_intervals;")
log_info("Fetched {nrow(vw_stations_intervals_data)} rows from vw_stations_intervals table.")

# Save the data locally
log_info("Saving vw_stations_intervals data locally...")
saveRDS(vw_stations_intervals_data, "vw_stations_intervals_data.rds")
log_info("Saved vw_stations_intervals data to vw_stations_intervals_data.rds.")

# Close the connection
log_info("Disconnecting from the database...")
dbDisconnect(con)
log_info("Disconnected from the database.")