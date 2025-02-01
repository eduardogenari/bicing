import psycopg2
import pandas as pd

# Database connection details
conn = psycopg2.connect(
    dbname="proyecto_12",
    host="proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
    port="5432",
    user="postgres",
    password="proyecto12upc"
)

# Fetch the station table
query = "SELECT * FROM stations"
stations_data = pd.read_sql_query(query, conn)

# Save the data locally
stations_data.to_pickle("stations_data.pkl")

# Close the connection
conn.close()
