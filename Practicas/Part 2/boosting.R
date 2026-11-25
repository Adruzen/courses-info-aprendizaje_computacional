# 1. Librerias
library(gbm)
library(caret)
library(ggplot2)

# 2. Cargar datos
data(mtcars)

# 3. Dividir datos
set.seed(123)

indice <- createDataPartition(
  mtcars$mpg,
  p = 0.80,
  list = FALSE
)

train <- mtcars[indice, ]
test <- mtcars[-indice, ]

# 4. Entrenar modelo Boosting
modelo_gbm <- gbm(
  mpg ~ .,
  data = train,
  distribution = "gaussian",
  n.trees = 2000,
  interaction.depth = 3,
  shrinkage = 0.01,
  n.minobsinnode = 3,
  cv.folds = 5,
  verbose = FALSE
)

# 5. Numero optimo de arboles
arboles_optimos <- gbm.perf(
  modelo_gbm,
  method = "cv",
  plot.it = TRUE
)

# 6. Predicciones
predicciones <- predict(
  modelo_gbm,
  newdata = test,
  n.trees = arboles_optimos
)

# 7. Evaluacion
rmse <- sqrt(mean((test$mpg - predicciones)^2))
mae <- mean(abs(test$mpg - predicciones))

r2 <- 1 - sum((test$mpg - predicciones)^2) /
  sum((test$mpg - mean(test$mpg))^2)

cat("\nRESULTADOS DEL MODELO BOOSTING\n")
cat("RMSE:", round(rmse, 4), "\n")
cat("MAE:", round(mae, 4), "\n")
cat("R2:", round(r2, 4), "\n")

# 8. Comparacion de resultados
resultados <- data.frame(
  Real = test$mpg,
  Predicho = predicciones
)

print(resultados)

# 9. Grafico de predicciones
ggplot(resultados, aes(x = Real, y = Predicho)) +
  geom_point(color = "blue", size = 3) +
  geom_abline(
    intercept = 0,
    slope = 1,
    color = "red",
    linetype = "dashed"
  ) +
  labs(
    title = "Modelo Gradient Boosting",
    x = "Valores reales",
    y = "Valores predichos"
  ) +
  theme_minimal()

# 10. Importancia de variables
summary(modelo_gbm, n.trees = arboles_optimos)
