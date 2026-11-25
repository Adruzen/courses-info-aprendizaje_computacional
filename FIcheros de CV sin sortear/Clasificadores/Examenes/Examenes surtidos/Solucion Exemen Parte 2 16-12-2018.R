# Instalar una sola vez, si es necesario
install.packages("e1071")

library(e1071)

# Conjunto A
A <- data.frame(
  X1 = c(1, 3, 1, 3, 2, 3, 4),
  X2 = c(1, 3, 3, 1, 2.5, 2.5, 3),
  Y  = factor(c(-1, 1, 1, -1, 1, -1, -1))
)

# Conjunto B: añadimos dos observaciones
B <- data.frame(
  X1 = c(1, 3, 1, 3, 2, 3, 4, 1.5, 1),
  X2 = c(1, 3, 3, 1, 2.5, 2.5, 3, 1.5, 2),
  Y  = factor(c(-1, 1, 1, -1, 1, -1, -1, 1, -1))
)


plot(A$X1,A$X2,
     col = ifelse(A$Y == 1, "blue", "red"),
     pch = 19,
     xlab = "x1",
     ylab = "x2",
     main = "Conjunto de datos  lineal",
     asp = 1)
graphics.off()
plot(B$X1,B$X2,
     col = ifelse(B$Y == 1, "blue", "red"),
     pch = 19,
     xlab = "x1",
     ylab = "x2",
     main = "Conjunto de datos  no lineal",
     asp = 1)

modeloA <- svm(
  Y ~ .,
  data = A,
  type = "C-classification",
  kernel = "linear",
  cost = 1000,
  scale = FALSE
)

summary(modeloA)

# Vectores soporte
A[modeloA$index, ]




modeloB <- svm(
  Y ~ .,
  data = B,
  type = "C-classification",
  kernel = "radial",
  gamma = 1,
  cost = 1000,
  scale = FALSE
)

summary(modeloB)

# Coordenadas de los vectores soporte
B[modeloB$index, ]

# Predicciones sobre el conjunto de entrenamiento
predB <- predict(modeloB, B)

table(Real = B$Y, Predicho = predB)



# Vectores soporte
SV <- modeloB$SV

# Coeficientes beta_i = alpha_i * y_i
beta <- as.vector(modeloB$coefs)

# Matriz del kernel RBF entre vectores soporte
dist2 <- as.matrix(dist(SV))^2
K <- exp(-modeloB$gamma * dist2)

# Norma al cuadrado de W en el espacio de características
normaW2 <- as.numeric(t(beta) %*% K %*% beta)

normaW <- sqrt(normaW2)
ancho <- 2 / normaW

cat("Número de vectores soporte:", nrow(SV), "\n")
cat("Norma de W en el espacio de características:", normaW, "\n")
cat("Ancho del margen:", ancho, "\n")
cat("Término independiente b:", -modeloB$rho, "\n")