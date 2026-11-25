library(rpart)
library(rpart.plot)

data(iris)
set.seed(123)
evaluar_modelo <- function(data, minbucket, cp, k = 5) {
  n <- nrow(data)
  folds <- sample(rep(1:k, length.out = n))
  accuracies <- c()
  
  for (i in 1:k) {
    train <- data[folds != i, ]
    test  <- data[folds == i, ]
    
    modelo <- rpart(
      Species ~ ., 
      data = train,
      method = "class",
      control = rpart.control(cp = cp, minbucket = minbucket)
    )
    
    pred <- predict(modelo, test, type = "class")
    acc <- mean(pred == test$Species)
    accuracies <- c(accuracies, acc)
  }
  
  return(mean(accuracies))
}
rejilla <- expand.grid(
  cp = seq(0.001, 0.05, by = 0.01),
  minbucket = c(1, 3, 5, 10)
)
resultados <- data.frame(cp = numeric(), minbucket = numeric(), Accuracy = numeric())

for (i in 1:nrow(rejilla)) {
  cp_val <- rejilla$cp[i]
  mb_val <- rejilla$minbucket[i]
  
  acc <- evaluar_modelo(iris, minbucket = mb_val, cp = cp_val, k = 5)
  resultados <- rbind(resultados, data.frame(cp = cp_val, minbucket = mb_val, Accuracy = acc))
}

print(resultados)
mejor <- resultados[which.max(resultados$Accuracy), ]
cat("Mejor combinación: cp =", mejor$cp, ", minbucket =", mejor$minbucket, "\n")

# Entrenar modelo final con los mejores hiperparámetros
mejor_modelo <- rpart(
  Species ~ ., 
  data = iris,
  method = "class",
  control = rpart.control(cp = mejor$cp, minbucket = mejor$minbucket)
)

rpart.plot(mejor_modelo)

