library(sf)
library(DBI)
library(RPostgres)

############# CONEXÓN A BASE DE DATOS ###########
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "proyecto_12",
  host = "proyecto12.czowmm2ee3ym.us-east-1.rds.amazonaws.com",
  port = 5432,
  user = "postgres",
  password = "proyecto12upc"
)
dbListTables(con)

############# ANALIZAR TABLAS BASE DE DATOS  ###########

tabla_analizar <- dbGetQuery(con, "SELECT * FROM stations")
str(tabla_analizar)
summary(tabla_analizar)
colnames(tabla_analizar)

############### ANALIZAR OUTLIERS DE VARIABLE ###############
variable_analizar <- tabla_analizar$value
plot(tabla_analizar)

summary(variable_analizar)
quantile(variable_analizar, probs = seq(0, 1, by = 0.1), na.rm = TRUE) 
hist(variable_analizar, 
     breaks = 30, 
     col = "cyan", 
     main = "Histograma de income",  
     xlab = "Ingreso (€)")
boxplot(variable_analizar, 
        col = "cyan", 
        main = "Boxplot de ingresos", 
        ylab = "Ingreso (€)")

iqr <- IQR(variable_analizar,na.rm = TRUE) #Interquartil
upper_threshold_severe <- quantile(variable_analizar, 0.75, na.rm = TRUE) + 3 * iqr
lower_threshold_severe <- quantile(variable_analizar, 0.25, na.rm = TRUE) - 3 * iqr
upper_threshold_mild <- quantile(variable_analizar, 0.75, na.rm = TRUE) + 1.5 * iqr
lower_threshold_mild <- quantile(variable_analizar, 0.25, na.rm = TRUE) - 1.5 * iqr
severe_outliers <- which(variable_analizar > upper_threshold_severe | variable_analizar < lower_threshold_severe) 
length(severe_outliers)  # Número de outliers severos
mild_outliers <- which(variable_analizar > upper_threshold_mild | variable_analizar < lower_threshold_mild)
length(mild_outliers)    # Número de outliers suaves
boxplot(variable_analizar, 
        col = "cyan", 
        main = "Boxplot 'value' en Demographics", 
        ylab = "Ingreso (€)")
abline(h = upper_threshold_severe, col = "red", lty = 2, lwd = 2)  # Límite severo superior
abline(h = lower_threshold_severe, col = "red", lty = 2, lwd = 2)  # Límite severo inferior
abline(h = upper_threshold_mild, col = "orange", lty = 2, lwd = 2) # Límite suave superior
abline(h = lower_threshold_mild, col = "orange", lty = 2, lwd = 2) # Límite suave inferior



