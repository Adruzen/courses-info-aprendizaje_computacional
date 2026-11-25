library(rpart)
library(rpart.plot)
GermanCredit <- read.csv("C:/Users/Alumno/Downloads/GermanCredit.csv")
set.seed(1234)
GermanCredit<-na.omit(GermanCredit)

indices <- sample(c(TRUE, FALSE), nrow(GermanCredit), replace = TRUE, prob = c(0.7, 0.3))

fitGC <- GermanCredit[indices, ]
testGC <- GermanCredit[!indices, ]

formula<-Class ~ Age+Job.Management.SelfEmp.HighlyQualified+Housing.Rent+Housing.ForFree+Housing.Own+SavingsAccountBonds.500.to.1000+CheckingAccountStatus.lt.0+CheckingAccountStatus.0.to.200+Amount+Duration+Purpose.NewCar

germanCreditCART<-rpart (formula, data=fitGC)

summary(germanCreditCART)
rpart.plot(germanCreditCART)

tabla_cp <- germanCreditCART$cptable
ind_min <- which.min(tabla_cp[, "xerror"])
limite_1se <- tabla_cp[ind_min, "xerror"] + tabla_cp[ind_min, "xstd"]

filas_candidatas <- which(tabla_cp[, "xerror"] < limite_1se)
fila_optima_1se <- filas_candidatas[1]
cp_optimo_1se <- tabla_cp[fila_optima_1se, "CP"]

arbolPodadoGermanCredit<- prune(germanCreditCART, cp = cp_optimo_1se)

predicciones <- predict(arbolPodadoGermanCredit, newdata = testGC, type = "class")
matriz_confusion <- table(testGC$Class, predicciones)

accuracyPodado <- sum(diag(matriz_confusion)) / sum(matriz_confusion)
print(accuracyPodado)



predicciones <- predict(germanCreditCART, newdata = testGC, type = "class")
matriz_confusion <- table(testGC$Class, predicciones)

accuracySinPodar <- sum(diag(matriz_confusion)) / sum(matriz_confusion)
print(accuracySinPodar)
