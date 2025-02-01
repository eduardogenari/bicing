import pandas as pd

# Load the data from the pickle file
stations_data = pd.read_pickle("stations_data.pkl")

# Display the first few rows of the data
print("First 3 entries:")
print(stations_data.head(3))

# Display summary statistics for numeric columns
print("\nSummary statistics for numeric columns:")
print(stations_data.describe())

# Display the data types of each column
print("\nData types of each column:")
print(stations_data.dtypes)
