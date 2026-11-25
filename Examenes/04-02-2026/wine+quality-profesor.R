library(rpart)
library(rpart.plot)
winequality.red <- read.csv("C:/Users/Alumno/Downloads/winequality-red.csv", sep=";", stringsAsFactors=TRUE)
set.seed(1234)
winequality.red<-na.omit(winequality.red)

indices <- sample(c(TRUE, FALSE), nrow(winequality.red), replace = TRUE, prob = c(0.8, 0.2))

fit <- winequality.red[indices, ]
test <- winequality.red[!indices, ]


germanCreditCART<-rpart (quality~., data=fit)

tabla_cp <- germanCreditCART$cptable
ind_min <- which.min(tabla_cp[, "xerror"])
limite_1se <- tabla_cp[ind_min, "xerror"] + tabla_cp[ind_min, "xstd"]

filas_candidatas <- which(tabla_cp[, "xerror"] < limite_1se)
fila_optima_1se <- filas_candidatas[1]
cp_optimo_1se <- tabla_cp[fila_optima_1se, "CP"]

arbolPodadoWine<- prune(germanCreditCART, cp = cp_optimo_1se)

predicciones <- predict(arbolPodadoWine, newdata = test, type="anova")
matriz_confusion <- table(test$quality, predicciones)

accuracyPodado <- sum(diag(matriz_confusion)) / sum(matriz_confusion)
print(accuracyPodado)
