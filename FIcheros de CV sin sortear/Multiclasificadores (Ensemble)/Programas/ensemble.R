library(nnet)

datosiris<-iris

n <- 150  # Número total de observaciones
porcentaje <- 0.9

indicesTotales <- sample(1:n, size = round(n * porcentaje))
train <- datosiris[indicesTotales, ]
test <- datosiris[-indicesTotales, ]



perceptron<-nnet(Species ~ ., data=train,  size=2)


predicionNnet<-predict(perceptron,train, type="class" )

datosirisRart<-train
datosirisRart$Species<-NULL

datosirisRart<-data.frame(datosirisRart,predicionNnet )
