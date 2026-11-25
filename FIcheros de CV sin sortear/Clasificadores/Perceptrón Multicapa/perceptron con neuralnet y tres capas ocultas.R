
# ============================================================
# VALIDACION CON UNA UNICA PARTICION (80% / 20%)
# Red neuronal: 2 - 8 - 5 - 3 - 1
# ============================================================

library(neuralnet)

n <- 600

datos <- data.frame(
  x1 = runif(n, -1, 1),
  x2 = runif(n, -1, 1)
)

# XOR: clase 1 cuando las entradas tienen signos diferentes
datos$y <- as.numeric(
  (datos$x1 > 0) != (datos$x2 > 0)
)

datos$y <- as.numeric(datos$y)

# Visualizar los datos
plot(datos$x1, datos$x2,
     col = ifelse(datos$y == 1, "red", "blue"),
     pch = 19,
     xlab = "X1",
     ylab = "X2",
     main = "Conjunto de datos no lineal: XOR")

legend("topright",
       legend = c("Clase 0", "Clase 1"),
       col = c("blue", "red"),
       pch = 19)


set.seed(123)

# Separar los datos: 80% entrenamiento, 20% prueba
n <- nrow(datos)
indices <- sample(seq_len(n), size = floor(0.8 * n))

entrenamiento <- datos[indices, ]
prueba <- datos[-indices, ]

# Entrenar la red neuronal
modelo <- neuralnet(
  y ~ x1 + x2,
  data = entrenamiento,
  hidden = c(8, 5, 3),
  act.fct = "logistic",
  linear.output = FALSE,
  algorithm = "rprop+",
  stepmax = 1e6,
  threshold = 0.01
)

# Predecir sobre el conjunto de prueba
probabilidades <- compute(
  modelo,
  prueba[, c("x1", "x2")]
)$net.result[, 1]

predicciones <- ifelse(probabilidades >= 0.5, 1, 0)

# Evaluar el modelo
accuracy <- mean(predicciones == prueba$y)

cat("Accuracy en el conjunto de prueba:",
    round(accuracy, 4), "\n")

cat("\nMatriz de confusion:\n")
print(table(
  Real = prueba$y,
  Predicho = predicciones
))

# Mostrar la red neuronal
plot(modelo)
