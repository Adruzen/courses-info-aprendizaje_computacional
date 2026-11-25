library (rpart)
library (rpart.plot)
titanicDF <- read.csv("C:/Users/Usuario_UMA/Downloads/train.csv", stringsAsFactors=TRUE)

#Preprocesamiento


titanicDF$Name<-NULL
titanicDF$PassengerId<-NULL
titanicDF$Ticket<-NULL
titanicDF$Embarked<-NULL
titanicDF$Cabin<-NULL


titanicDF<-na.omit(titanicDF)

set.seed(100)
ind <- sample(714,714)
idt <- ind[1:50]
trainTitanic <- titanicDF[-idt,]
testTitanic <- titanicDF[idt,]


arbolDecisionTitanic<-rpart(Age~., data=trainTitanic)
rpart.plot(arbolDecisionTitanic)

matrizdeconfusion<-table (predict(object=arbolDecisionTitanic, newdata =testTitanic), testTitanic$Age)

accuracy<-sum(diag(matrizdeconfusion))/sum(matrizdeconfusion)

arbolDecisionTitanic$cptable



opt <- which.min(arbolDecisionTitanic$cptable[,"xerror"])

cpMinimoTitanic <- arbolDecisionTitanic$cptable[opt, "CP"]

arbolpodadoTitanic<-prune (arbolDecisionTitanic, cp=cpMinimoTitanic)

rpart.plot(arbolpodadoTitanic)
#tune
arboltune<-tune.rpart(Survived~., data=trainTitanic, cp = c(arbolDecisionTitanic$cptable[1], arbolDecisionTitanic$cptable[2]))
arboltune$best.model
rpart.plot(arboltune$best.model)
