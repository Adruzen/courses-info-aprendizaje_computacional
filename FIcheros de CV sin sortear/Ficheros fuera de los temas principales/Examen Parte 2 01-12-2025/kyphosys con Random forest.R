library(randomForest)
library(rpart)
ind <- sample(2, nrow(kyphosis), replace=TRUE, prob=c(0.8, 0.2))
trainData <- kyphosis[ind==1,]
testData <- kyphosis[ind==2,]

rfkyphosis <- randomForest(Kyphosis ~ . , data=trainData, ntree=20, proximity=TRUE)

kyphosPred <- predict(rfkyphosis, newdata=testData)
matrizcofusion <-table(kyphosPred, testData$Kyphosis)

accuracy<-sum(diag(matrizcofusion))/sum(matrizcofusion)
importance(rfkyphosis)
