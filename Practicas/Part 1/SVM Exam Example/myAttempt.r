library(kernlab)

x<-c( 1,3,1, 3,  2,   3,   4)
y<-c( 1,3,3, 1   2.5, 2.5, 3)
z<-c(-1,1,1,-1,  1,   -1,  -1)

datos1 <- data.frame(x, y, z)

SVMachine <- ksvm(z ~ ., datos1, type="C-svc", C=100, kernel="vanilladot")

# Plot points:
