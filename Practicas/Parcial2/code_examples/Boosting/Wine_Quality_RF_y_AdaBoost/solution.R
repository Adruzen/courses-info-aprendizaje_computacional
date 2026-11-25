
library(randomForest)
library(adabag)
winequality.red <- read.csv("C:/Users/Usuario_UMA/Downloads/winequality-red.csv", sep=";", stringsAsFactors=TRUE)

winequality.red<-na.omit(winequality.red)

winequality.red$quality<-as.factor(winequality.red$quality)

set.seed(200)
d_size<-dim(winequality.red)[1]
dtest_size <- ceiling(0.2*d_size)
samples<-sample(d_size, d_size, replace=FALSE)
indexes<-samples[1:dtest_size]
dtrain<-winequality.red[-indexes,]
dtest<-winequality.red[indexes,]


#entrenar RF
vinoRF <- randomForest(quality ~ ., data=dtrain, ntree=100, proximity=TRUE, type ="class")

matrizconfusion<-table(predict(vinoRF, newdata=dtest,  type = "class"), dtest$quality)
accuracy<-sum(diag(matrizconfusion))/sum(matrizconfusion)
accuracy
importance(vinoRF)
varImpPlot(vinoRF)



#ADABOOST.M1


modelo_adaboost <- boosting(
  quality ~ .,
  data = dtrain,
  boos = TRUE,
  mfinal = 100,
  control = rpart.control(
    maxdepth = 1,
    minsplit = 2,
    cp = 0
  )
)



# 6. Predicciones
predicciones <- predict(
  modelo_adaboost,
  newdata = dtest
)

clases_predichas <- factor(predicciones$class, levels = levels(dtest$quality))

# 7. Resultados
resultados <- data.frame(
  Real = dtest$quality,
  Predicho = clases_predichas
)

print(resultados)

# 8. Matriz de confusion
matriz <- confusionMatrix(
  data = clases_predichas,
  reference = dtest$quality
)

print(matriz)

# 9. Accuracy
accuracy <- matriz$overall["Accuracy"]

accuracy
