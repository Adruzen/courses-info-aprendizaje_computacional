# Instalar si hace falta
# install.packages(c("rpart", "caret", "rpart.plot"))

#cp (complexity parameter), que controla la poda del árbol.

library(rpart)
library(caret)
library(rpart.plot)

data(iris)
# Definimos la rejilla de valores a probar
tuneGrid <- expand.grid(cp = seq(0.001, 0.05, by = 0.005))
set.seed(123)
train_control <- trainControl(method = "cv", number = 10)
# Entrenar el modelo con ajuste automático
modelo_tune <- train(
  Species ~ ., 
  data = iris,
  method = "rpart",
  trControl = train_control,
  tuneGrid = tuneGrid,
  metric = "Accuracy"
)
# Ver los resultados
print(modelo_tune)
plot(modelo_tune)

# Mejor modelo
modelo_tune$bestTune
best_model <- modelo_tune$finalModel
rpart.plot(best_model)

#con minbucket

library(rpart)
library(rpart.plot)
library(caret)

set.seed(123)
data(iris)

# Definir valores de minbucket a probar
valores_minbucket <- c(1, 3, 5, 10, 20)

# Validación cruzada 10-fold
train_control <- trainControl(method = "cv", number = 10)

# Crear data.frame para almacenar resultados
resultados <- data.frame(minbucket = integer(), Accuracy = numeric())

for (mb in valores_minbucket) {
  modelo <- train(
    Species ~ ., 
    data = iris,
    method = "rpart",
    trControl = train_control,
    tuneGrid = expand.grid(cp = seq(0.001, 0.05, by = 0.01)),
    control = rpart.control(minbucket = mb)
  )
  
  mejor_acc <- max(modelo$results$Accuracy)
  resultados <- rbind(resultados, data.frame(minbucket = mb, Accuracy = mejor_acc))
}

# Ver resultados
print(resultados)

# Mejor valor
mejor_minbucket <- resultados$minbucket[which.max(resultados$Accuracy)]
cat("Mejor minbucket:", mejor_minbucket, "\n")

# Entrenar modelo final
mejor_modelo <- rpart(
  Species ~ ., 
  data = iris,
  control = rpart.control(minbucket = mejor_minbucket)
)

rpart.plot(mejor_modelo)


