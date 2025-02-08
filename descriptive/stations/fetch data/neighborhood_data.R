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
n_sf <- st_read(con, query = "select * from neighborhoods;")

# Save the data locally
saveRDS(n_sf, "n_data.rds")

# Close the connection
dbDisconnect(con)
