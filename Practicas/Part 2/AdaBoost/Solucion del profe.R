# Nota: solución es incompleta (el profesor ha dicho algo sobre "faltan votos"?)


library(kernlab)
datosiris<-iris

datosiris$Species <- ifelse(datosiris$Species == "versicolor", 1, -1)


n <- 150  # Número total de observaciones
porcentaje <- 0.9

indicesTotales <- sample(1:n, size = round(n * porcentaje))
train <- datosiris[indicesTotales, ]
test <- datosiris[-indicesTotales, ]

listaSVM<-list()
for (i in 1:10) {
  n <- 135  # Número total de observaciones
  porcentaje <- 0.8
  indicesSVM <- sample(1:n, size = round(n * porcentaje))
  trainSVM<-- datosiris[indicesSVM, ]
  modeloSvm<-ksvm(Species~., data=trainSVM, kernel = "vanilladot", C = 0.1)
  listaSVM<-c(listaSVM, modeloSvm)
}
listaSVMPredicciones<-list()
for (i in 1:10) {
  prediccionSVM<-predict (listaSVM[[i]], test[1,])
  listaSVMPredicciones<-c(listaSVMPredicciones, prediccionSVM)
}

  