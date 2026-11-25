library(randomForest)
detect.malicious.URL <- read.csv("C:/Users/Usuario_UMA/Downloads/detect-malicious-URL.csv", stringsAsFactors=TRUE)
ind <- sample(2, nrow(detect.malicious.URL), replace=TRUE, prob=c(0.8, 0.2))
trainData <- detect.malicious.URL[ind==1,]
testData <- detect.malicious.URL[ind==2,]

rf <- randomForest(label ~ url , data=trainData, ntree=100, proximity=TRUE)


urlPred <- predict(rf, newdata=testData)
matrizcofusion <-table(urlPred, testData$label)

accuracy<-sum(diag(matrizcofusion))/sum(matrizcofusion)
importance(rf)
