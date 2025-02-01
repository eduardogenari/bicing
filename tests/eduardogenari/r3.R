library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
  port = 5432,
  dbname = "proyecto_12",
  user = "postgres",
  password = "proyecto12upc"
)

# Perform database operations
# Example: List tables
tables <- dbListTables(con)
print(tables)

# Example: Execute a query
result <- dbGetQuery(con, "SELECT * FROM stations LIMIT 10")
print(result)

# Close the database connection
dbDisconnect(con)