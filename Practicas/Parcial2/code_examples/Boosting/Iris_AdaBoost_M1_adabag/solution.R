
# ==========================================
# MODELO MACHINE LEARNING: ADABOOST.M1
# ==========================================

# 1. Librerias
library(adabag)
library(caret)
library(ggplot2)
library(rpart)

# 2. Cargar datos
data(iris)

# 3. Dividir datos
set.seed(123)

indice <- createDataPartition(
  iris$Species,
  p = 0.80,
  list = FALSE
)

train <- iris[indice, ]
test <- iris[-indice, ]

# 4. Entrenar AdaBoost.M1
set.seed(123)

modelo_adaboost <- boosting(
  Species ~ .,
  data = train,
  boos = TRUE,
  mfinal = 100,
  control = rpart.control(
    maxdepth = 1,
    minsplit = 2,
    cp = 0
  )
)

# 5. Mostrar modelo
print(modelo_adaboost)

# 6. Predicciones
predicciones <- predict(
  modelo_adaboost,
  newdata = test
)

clases_predichas <- predicciones$class

# 7. Resultados
resultados <- data.frame(
  Real = test$Species,
  Predicho = clases_predichas
)

print(resultados)

# 8. Matriz de confusion
matriz <- confusionMatrix(
  data = clases_predichas,
  reference = test$Species
)

print(matriz)

# 9. Accuracy
accuracy <- matriz$overall["Accuracy"]

cat(
  "Accuracy:",
  round(accuracy, 4),
  "\n"
)

# 10. Grafico de matriz de confusion
datos_matriz <- as.data.frame(matriz$table)

ggplot(
  datos_matriz,
  aes(x = Reference, y = Prediction, fill = Freq)
) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 5) +
  scale_fill_gradient(
    low = "white",
    high = "darkgreen"
  ) +
  labs(
    title = "Matriz de confusion - AdaBoost.M1",
    x = "Clase real",
    y = "Clase predicha"
  ) +
  theme_minimal()
