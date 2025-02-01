# Load the ggplot2 library
library(ggplot2)

# Create a sample data frame
data <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 3, 5, 7, 11)
)

# Create a basic plot using ggplot2
plot <- ggplot(data, aes(x = x, y = y)) +
  geom_point() +
  geom_line()

# Print the plot
print(plot)
