library(party)
datosiris<-iris
set.seed(1234)
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7, 0.3))
trainData <- iris[ind==1,]
testData <- iris[ind==2,]
iris_ctree <- ctree(Species~., data=trainData)
table(predict(iris_ctree), trainData$Species)
accuracy<-sum(diag(table(predict(iris_ctree), trainData$Species)))/sum(table(predict(iris_ctree), trainData$Species))
print(iris_ctree)
plot(iris_ctree)
testPred <- predict(iris_ctree, newdata = testData)
table(testPred, testData$Species)

accuracyPrediccion<-sum(diag(table(testPred, testData$Species)))/sum(table(testPred, testData$Species))

                                                                     