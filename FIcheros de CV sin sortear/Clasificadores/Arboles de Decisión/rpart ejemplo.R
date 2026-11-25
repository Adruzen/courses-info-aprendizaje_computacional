install.packages("rpart")
library(rpart)
library(rpart.plot)
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7, 0.3))
trainData <- iris[ind==1,]
testData <- iris[ind==2,]
modelorpart<-rpart (Species ~ ., data=trainData, control = rpart.control(minsplit = 10))
print(modelorpart$cptable)
opt <- which.min(modelorpart$cptable[,"xerror"])
cparbolpodado <- modelorpart$cptable[opt, "CP"]
rpartpodado <- prune(modelorpart, cp = 0.5)
rpart.plot(modelorpart)
text(modelorpart, use.n=TRUE)
rpart.plot(rpartpodado)
text(rpartpodado, use.n=TRUE)
