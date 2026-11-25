library(kernlab)

datosiris <- iris

# Transformar las clases en factores
datosiris$Species <- ifelse(
  datosiris$Species == "versicolor", "1", "-1"
)

datosiris$Species <- as.factor(datosiris$Species)

# Separar entrenamiento y test
set.seed(123)

n <- nrow(datosiris)
porcentaje <- 0.9

indicesTotales <- sample(1:n, size = round(n * porcentaje))

train <- datosiris[indicesTotales, ]
test <- datosiris[-indicesTotales, ]

# Entrenar 10 SVM
listaSVM <- list()

for (i in 1:10) {
  
  n <- nrow(train)
  porcentaje <- 0.8
  
  indicesSVM <- sample(1:n, size = round(n * porcentaje))
  
  trainSVM <- train[indicesSVM, ]
  
  modeloSvm <- ksvm(
    Species ~ .,
    data = trainSVM,
    kernel = "vanilladot",
    C = 0.1
  )
  
  listaSVM[[i]] <- modeloSvm
}

# Obtener predicciones
listaSVMPredicciones <- list()

for (i in 1:10) {
  
  prediccionSVM <- predict(
    listaSVM[[i]],
    test[1, ]
  )
  
  listaSVMPredicciones[[i]] <- prediccionSVM
}






# Convertir la lista de predicciones en una matriz numérica
predicciones <- sapply(listaSVMPredicciones, function(x) {
  as.numeric(as.character(x))
})

predicciones




# Multiplicar las predicciones por alpha
resultado <- predicciones * alpha

# Mostrar resultado
print(sign(sum(resultado) ))
