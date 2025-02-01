import psycopg2

# Database connection parameters
host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com"
port = 5432
database = "proyecto_12"
user = "postgres"
password = "proyecto12upc"

try:
    # Connect to the PostgreSQL database
    connection = psycopg2.connect(
        host=host,
        port=port,
        database=database,
        user=user,
        password=password
    )

    # Create a cursor object
    cursor = connection.cursor()

    # Execute a simple query
    cursor.execute("SELECT * FROM stations LIMIT 10;")

    # Fetch the results
    rows = cursor.fetchall()

    # Print the results
    for row in rows:
        print(row)

except Exception as e:
    print(f"Error: {e}")

finally:
    # Close the cursor and connection
    if cursor:
        cursor.close()
    if connection:
        connection.close()
