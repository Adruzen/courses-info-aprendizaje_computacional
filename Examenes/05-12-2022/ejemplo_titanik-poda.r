library(rpart)
library(rpart.plot)
set.seed(1234)
titanic <- read.csv("C:/Users/Usuario_UMA/Downloads/train.csv", stringsAsFactors=TRUE)
names(titanic)
titanic$PassengerId<-NULL
titanic$Cabin<-NULL
titanic$Embarked<-NULL
titanic$Name<-NULL
titanic$Ticket<-NULL
titanic$Survived<-as.factor(titanic$Survived)
ind <- sample(2, nrow(titanic), replace=TRUE, prob=c(0.9, 0.1))
trainTitanic <- titanic[ind==1,]
testTitanic <- titanic[ind==2,]
arbolTitanic <- rpart(Survived ~., data = trainTitanic, control = rpart.control(minsplit = 5))
rpart.plot(arbolTitanic)

prediccion<-table(predict(arbolTitanic, newdata = testTitanic, type="class"), testTitanic$Survived)
accuracy<-sum(diag(prediccion))/sum(prediccion)

print (arbolTitanic$cptable)
indicetablaCP <- which.min(arbolTitanic$cptable[,"xerror"])

cpMin <- arbolTitanic$cptable[indicetablaCP, "CP"]

arbolTitanicPodado<- prune(arbolTitanic, cp = cpMin)

rpart.plot(arbolTitanicPodado)



cp <- arbolTitanic$cptable

i.min <- which.min(cp[, "xerror"])
limite <- cp[i.min, "xerror"] + cp[i.min, "xstd"]

indice1_SE<- which(cp[, "xerror"] <= limite)[1]

cp_1_SE<-cp[indice1_SE, "CP"]
arbolTitanicPodado<- prune(arbolTitanic, cp = cp_1_SE)
rpart.plot(arbolTitanicPodado)