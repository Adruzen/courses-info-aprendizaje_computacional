library(rpart)
library(rpart.plot)
set.seed(144564343234)
titanic <- read.csv("C:/Users/Usuario_UMA/Downloads/train.csv", stringsAsFactors=TRUE)
names(titanic)
titanic$PassengerId<-NULL
titanic$Cabin<-NULL
titanic$Embarked<-NULL
titanic$Name<-NULL
titanic$Ticket<-NULL
titanicSinNA<-na.omit(titanic)
ind <- sample(2, nrow(titanicSinNA), replace=TRUE, prob=c(0.9, 0.1))
trainTitanic <- titanicSinNA[ind==1,]
testTitanic <- titanicSinNA[ind==2,]
arbolTitanicEdad<- rpart(Age ~., data = trainTitanic, control = rpart.control(minsplit = 5))

prediccion<-predict(arbolTitanicEdad, newdata = testTitanic, type="vector")
prediccion
mean((testTitanic$Age-prediccion)^2)
