
# ==========================================
# MODELO MACHINE LEARNING: BAGGING
# ==========================================

# 1. Librerias
library(ipred)
library(caret)
library(ggplot2)
library(rpart)

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

# 4. Entrenar modelo Bagging
set.seed(123)

modelo_bagging <- bagging(
  mpg ~ .,
  data = train,
  nbagg = 500,
  coob = TRUE,
  control = rpart.control(
    minsplit = 3,
    cp = 0
  )
)

# 5. Mostrar modelo
print(modelo_bagging)

# 6. Predicciones
predicciones <- predict(
  modelo_bagging,
  newdata = test
)

# 7. Evaluacion
rmse <- sqrt(
  mean((test$mpg - predicciones)^2)
)

mae <- mean(
  abs(test$mpg - predicciones)
)

r2 <- 1 -
  sum((test$mpg - predicciones)^2) /
  sum((test$mpg - mean(test$mpg))^2)

cat("\nRESULTADOS DEL MODELO BAGGING\n")
cat("RMSE:", round(rmse, 4), "\n")
cat("MAE:", round(mae, 4), "\n")
cat("R2:", round(r2, 4), "\n")

# 8. Comparacion de predicciones
resultados <- data.frame(
  Real = test$mpg,
  Predicho = predicciones
)

print(resultados)

# 9. Representacion grafica
ggplot(resultados, aes(x = Real, y = Predicho)) +
  geom_point(color = "darkgreen", size = 3) +
  geom_abline(
    intercept = 0,
    slope = 1,
    color = "red",
    linetype = "dashed"
  ) +
  labs(
    title = "Modelo Bagging",
    x = "Valores reales",
    y = "Valores predichos"
  ) +
  theme_minimal()
