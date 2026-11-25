library (rpart)
fit <-rpart (Species~., data=iris, method="class", cp=0.001)

print (fit$cptable)

min_error<-min (fit$cptable[,"xerror"])

xstd_min<-fit$cptable[fit$cptable[,"xerror"]==min_error,"xstd"]
thershold<-min_error+xstd_min
i<-which(fit$cptable[,"xerror"]<=thershold)

cp_1_SE<-fit$cptable[i,"CP"]

arbolpodado_1se<-prune (fit, cp=cp_1_SE)
