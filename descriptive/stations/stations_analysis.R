library(ggplot2)

# Load the data
stations_data <- readRDS("stations_data.rds")

# Summary of the data
summary_data <- summary(stations_data)
print(summary_data)

# Boxplot for numeric columns
numeric_columns <- sapply(stations_data, is.numeric)
boxplot(stations_data[, numeric_columns], main = "Boxplot of Numeric Columns")

