install.packages("rpart")
library(rpart)
library(rpart.plot)
datosiris<-iris
set.seed(1234)
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7, 0.3))
trainData <- iris[ind==1,]
testData <- iris[ind==2,]
iris_ctree <- ctree(Species~., data=trainData)
arbolIris <- rpart(Species~., data = trainData, control = rpart.control(minsplit = 10))
prediccion<-table(predict(arbolIris, newdata = testData, type="class"), testData$Species)
accuracy<-sum(diag(prediccion))/sum(prediccion)
print(arbolIris)

rpart.plot(arbolIris)
text(arbolIris, use.n=TRUE)
testPred <- predict(arbolIris, newdata = testData)
table(testPred, testData$Species)

accuracyPrediccion<-sum(diag(table(testPred, testData$Species)))/sum(table(testPred, testData$Species))

print (arbolIris$cptable)


#PODA

indicetablaCP <- which.min(arbolIris$cptable[,"xerror"])

cpMin <- arbolIris$cptable[indicetablaCP, "CP"]

arbolIrisPodado<- prune(arbolIris, cp = cpMin)

rpart.plot(arbolIrisPodado)
