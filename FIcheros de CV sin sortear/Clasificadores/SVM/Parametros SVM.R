
library("kernlab")


x1<-c(2,2,-2,-2,1,1,-1,-1)
x2<-c(2,-2,-2,2,1,-1,-1,1)

z1<-c(1,1,1,1,-1,-1,-1,-1)

dataEj3<- data.frame(x1,x2, z1)
names(dataEj3)<- c("x1","y1", "z1")

svp <- ksvm(z1~., data=dataEj3,type="C-svc",C=100, kernel="rbfdot",scaled=c())
svp
dataEj3prima<-dataEj3
dataEj3prima$z1<-NULL
w <- colSums(coef(svp)[[1]] * dataEj3prima[SVindex(svp),])


w=t(dataEj3prima[SVindex(svp),])%*%(coef(svp)[[1]]*z1)

plot (svp)

b <- b(svp)