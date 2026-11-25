# ==============================================================================
# Ejercicio 2 (Variante Redes Neuronales / Perceptrón Multicapa con 'nnet')
# Clasificación sobre 'vote.data' y 'vote.test' variando 'size' de 1 a 10
# ==============================================================================

# Cargar la librería 'nnet' (incluida en el paquete base de R)
if (!requireNamespace("nnet", quietly = TRUE)) install.packages("nnet")
library(nnet)

# ------------------------------------------------------------------------------
# 1. CARGA Y PREPROCESAMIENTO DE LOS DATASETS
# ------------------------------------------------------------------------------

# Nombres de las 16 variables predictoras de votación y el objetivo 'votation'
nombres_columnas <- c(
  "handicapped_infants",
  "water_project_cost_sharing",
  "adoption_of_the_budget_resolution",
  "physician_fee_freeze",
  "el_salvador_aid",
  "religious_groups_in_schools",
  "anti_satellite_test_ban",
  "aid_to_nicaraguan_contras",
  "mx_missile",
  "immigration",
  "synfuels_corporation_cutback",
  "education_spending",
  "superfund_right_to_sue",
  "crime",
  "duty_free_exports",
  "export_administration_act_south_africa",
  "votation"
)

# Cargar datos de entrenamiento (300 instancias) y test (135 instancias)
datos_train <- read.csv(
  "vote.data",
  header = FALSE,
  col.names = nombres_columnas,
  stringsAsFactors = TRUE
)

datos_test <- read.csv(
  "vote.test",
  header = FALSE,
  col.names = nombres_columnas,
  stringsAsFactors = TRUE
)

# Limpiar posibles puntos finales en las etiquetas ('democrat.' -> 'democrat')
datos_train$votation <- factor(gsub("\\.", "", datos_train$votation))
datos_test$votation  <- factor(gsub("\\.", "", datos_test$votation))

cat("=====================================================================\n")
cat("REDES NEURONALES / PERCEPTRÓN MULTICAPA (MLP) CON 'nnet'\n")
cat("=====================================================================\n")
cat("Entrenamiento (vote.data):", nrow(datos_train), "muestras\n")
cat("Test          (vote.test):", nrow(datos_test),  "muestras\n\n")

# Siguiendo la premisa del Ejercicio 2, eliminamos 'physician_fee_freeze'
train_sin_pff <- datos_train[, !(names(datos_train) %in% "physician_fee_freeze")]
test_sin_pff  <- datos_test[,  !(names(datos_test)  %in% "physician_fee_freeze")]

# ------------------------------------------------------------------------------
# 2. EXPERIMENTO: VARIAR 'size' DE 1 A 10 (NÚMERO DE NEURONAS EN CAPA OCULTA)
# ------------------------------------------------------------------------------
# Debido a que el algoritmo de retropropagación (backpropagation) parte de pesos
# iniciales aleatorios y puede converger a mínimos locales, para cada tamaño (size)
# entrenamos varios modelos con distintas semillas (repeticiones) y calculamos:
#   - Media de Accuracy en Entrenamiento y Test
#   - Mejor modelo (Accuracy máximo)
#   - Desviación estándar (estabilidad)

tamanos <- 1:10
num_repeticiones <- 10

# Data frame para almacenar resultados agregados
resultados <- data.frame(
  size            = tamanos,
  train_acc_mean  = 0.0,
  train_acc_sd    = 0.0,
  test_acc_mean   = 0.0,
  test_acc_sd     = 0.0,
  test_acc_max    = 0.0
)

# Guardar la mejor red global encontrada
mejor_red <- NULL
mejor_test_acc <- -1
mejor_size <- 1

cat("Entrenando modelos para size = 1..10 (con", num_repeticiones, "repeticiones por tamaño)...\n\n")

for (s in tamanos) {
  accs_tr <- numeric(num_repeticiones)
  accs_te <- numeric(num_repeticiones)
  
  for (r in seq_len(num_repeticiones)) {
    # Semilla determinista y única para cada combinación de size y repetición
    set.seed(100 * s + r)
    
    # Entrenar el Perceptrón Multicapa (MLP)
    # - size: número de neuronas en la capa oculta (1 a 10)
    # - maxit: máximo de iteraciones (épocas) para convergencia (300)
    # - decay: término de regularización L2 / weight decay (0.01) para frenar sobreajuste
    # - trace: FALSE para silenciar el log paso a paso del optimizador BFGS
    modelo_nn <- nnet(
      votation ~ .,
      data = train_sin_pff,
      size = s,
#      maxit = 300,
#      decay = 0.01,
#      trace = FALSE
    )
    
    # Predicción de clases
    pred_tr <- predict(modelo_nn, train_sin_pff, type = "class")
    pred_te <- predict(modelo_nn, test_sin_pff,  type = "class")
    
    acc_tr <- mean(pred_tr == train_sin_pff$votation)
    acc_te <- mean(pred_te == test_sin_pff$votation)
    
    accs_tr[r] <- acc_tr
    accs_te[r] <- acc_te
    
    if (acc_te > mejor_test_acc) {
      mejor_test_acc <- acc_te
      mejor_red      <- modelo_nn
      mejor_size     <- s
    }
  }
  
  resultados$train_acc_mean[s] <- mean(accs_tr)
  resultados$train_acc_sd[s]   <- sd(accs_tr)
  resultados$test_acc_mean[s]  <- mean(accs_te)
  resultados$test_acc_sd[s]    <- sd(accs_te)
  resultados$test_acc_max[s]   <- max(accs_te)
  
  cat(sprintf(
    "Size = %2d | Train Acc: %.2f%% (+/- %.2f) | Test Acc Media: %.2f%% (+/- %.2f) | Test Max: %.2f%%\n",
    s,
    resultados$train_acc_mean[s] * 100, resultados$train_acc_sd[s] * 100,
    resultados$test_acc_mean[s]  * 100, resultados$test_acc_sd[s]  * 100,
    resultados$test_acc_max[s]   * 100
  ))
}

cat("\n=====================================================================\n")
cat("RESUMEN DE RESULTADOS:\n")
print(round(resultados, 4))
cat("=====================================================================\n\n")

cat(sprintf(
  "Mejor configuración alcanzada en Test: size = %d con Accuracy = %.2f%%\n\n",
  mejor_size, mejor_test_acc * 100
))

# ------------------------------------------------------------------------------
# 3. GENERACIÓN DEL GRÁFICO (ACCURACY VS SIZE)
# ------------------------------------------------------------------------------
# Generamos un gráfico comparativo claro que muestra la curva de Accuracy en Train
# frente a Test en función del número de neuronas ocultas ('size').

png("grafico_perceptron_size.png", width = 850, height = 550, res = 110)

# Rango dinámico del eje Y
y_min <- min(resultados$test_acc_mean - resultados$test_acc_sd, 0.88)
y_max <- 1.01

plot(
  resultados$size, resultados$train_acc_mean,
  type = "b",
  pch = 19,
  col = "darkblue",
  lwd = 2,
  ylim = c(y_min, y_max),
  xlab = "Número de neuronas ocultas (size)",
  ylab = "Accuracy",
  main = "Evolución del Accuracy según 'size' en Perceptrón (nnet)",
  xaxt = "n",
  las = 1
)

# Configurar marcas del eje X de 1 a 10
axis(1, at = 1:10)
grid(nx = 10, ny = NULL, col = "gray85", lty = "dotted")

# Añadir curva de test
lines(resultados$size, resultados$test_acc_mean, type = "b", pch = 17, col = "firebrick", lwd = 2)

# Añadir línea con el mejor resultado en test (máximo de cada size)
lines(resultados$size, resultados$test_acc_max, type = "b", pch = 15, col = "darkorange", lty = 2, lwd = 1.5)

# Barra de referencia: accuracy del árbol podado (88.67% train, 91.85% test)
abline(h = 0.9185, col = "forestgreen", lty = 3, lwd = 1.8)

# Leyenda explicativa
legend(
  "bottomright",
  legend = c(
    "Entrenamiento (Media)",
    "Test (Media)",
    "Test (Mejor réplica)",
    "Referencia Árbol Podado (Test: 91.85%)"
  ),
  col = c("darkblue", "firebrick", "darkorange", "forestgreen"),
  pch = c(19, 17, 15, NA),
  lty = c(1, 1, 2, 3),
  lwd = c(2, 2, 1.5, 1.8),
  bg = "white"
)

dev.off()
cat("Gráfico exportado correctamente a: grafico_perceptron_size.png\n\n")

