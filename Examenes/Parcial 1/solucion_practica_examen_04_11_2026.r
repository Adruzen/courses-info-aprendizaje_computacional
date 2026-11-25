library(kernlab)
library(e1071)

set.seed(1234)

# 1. Conjunto de Datos
datos <- data.frame(
  X1 = c(-2, -2,  2,  2, -1,  1,  0,  0, -0.5, -0.5,  0.5,  0.5),
  X2 = c(-2,  2, -2,  2,  0,  0, -1,  1, -0.5,  0.5, -0.5,  0.5),
  Y  = factor(c(-1, -1, -1, -1,  1,  1,  1,  1,    1,    1,    1,    1))
)


cat("=== DATOS DEL EXAMEN ===\n")
print(datos)
cat("\n")



# ------------------------------------------------------------------------------
# Problema 1. 
# ------------------------------------------------------------------------------


# 1.1 Representación Gráfica (0.5 puntos) --------------------------------------

cat("=== BLOQUE 1: REPRESENTACIÓN GRÁFICA ===\n")
colores <- ifelse(datos$Y == "1", "blue", "red")
simbolos <- ifelse(datos$Y == "1", 16, 17)

png("observaciones.png", width = 800, height = 800, res = 120)
plot(datos$X1, datos$X2, col = colores, pch = simbolos, cex = 1.6, lwd = 2,
     xlab = "X1", ylab = "X2", main = "Distribución de Clases (Examen 04/11/2026)",
     xlim = c(-2.5, 2.5), ylim = c(-2.5, 2.5))
grid()
legend("topright", legend = c("Clase +1 (Interior)", "Clase -1 (Exterior)"),
       col = c("blue", "red"), pch = c(16, 17), pt.cex = 1.4)
dev.off()

# 1.2 SVM con kernlab (ksvm con kernel RBF) -------------------------------------

cat("=== BLOQUE 2: SVM CON KERNLAB (ksvm) ===\n")

# 2.1. Entrenamiento con C = 10, gamma (sigma) = 0.5
modelo_ksvm <- ksvm(
  Y ~ ., 
  data = datos, 
  type = "C-svc", 
  C = 10, 
  kernel = "rbfdot", 
  kpar = list(sigma = 0.5)
)

print(modelo_ksvm)

# 2.2. Elementos del modelo:
cat("\n--- Parámetros y Elementos Extraídos de ksvm ---\n")

# a) Número de vectores soporte
num_sv <- nSV(modelo_ksvm)
cat("a) Número de vectores soporte:", num_sv, "\n")

# b) Índices de las observaciones que son vectores soporte
indices_sv <- SVindex(modelo_ksvm)
cat("b) Índices de vectores soporte:", paste(indices_sv, collapse = ", "), "\n")

# c) Multiplicadores de Lagrange (alpha_i)
coeficientes_y_alpha <- coef(modelo_ksvm)[[1]]
alfa_valores <- abs(coeficientes_y_alpha)
cat("c) Multiplicadores de Lagrange (alpha_i) de los vectores soporte:\n")
for (k in 1:length(indices_sv)) {
  cat(sprintf("   - Obs %2d (%+d): alpha = %8.6f\n", 
              indices_sv[k], 
              ifelse(datos$Y[indices_sv[k]] == "1", 1, -1), 
              alfa_valores[k]))
}

# d) Parámetro b
termino_b <- b(modelo_ksvm)
cat("d) Parámetro b (función b(ksvm)):", termino_b, "\n")
cat("   Término independiente estándar (-b(ksvm)):", -termino_b, "\n")

# e) Vector de pesos w en el espacio transformado
# Dado que el kernel RBF mapea a un espacio de dimensión infinita, 
# no se puede imprimir el vector w completo (tiene longitud infinita).
# Sin embargo, mediante el desarrollo en serie de Taylor de exp(2*gamma*<x, z>),
# podemos aproximar explícitamente los primeros 10 coeficientes del vector w:
terminos_taylor <- list(
  c(0,0), c(1,0), c(0,1), c(2,0), c(1,1), c(0,2), c(3,0), c(2,1), c(1,2), c(0,3)
)
nombres_terminos <- c("1", "x1", "x2", "x1^2", "x1*x2", "x2^2", "x1^3", "x1^2*x2", "x1*x2^2", "x2^3")
w_primeros_10 <- numeric(10)
x_sv <- as.matrix(datos[indices_sv, c("X1", "X2")])
norma2_sv <- rowSums(x_sv^2)

for (m in 1:10) {
  p1 <- terminos_taylor[[m]][1]
  p2 <- terminos_taylor[[m]][2]
  grado_k <- p1 + p2
  escala <- sqrt((2 * 0.5)^grado_k / factorial(grado_k) * choose(grado_k, p1))
  phi_m <- escala * exp(-0.5 * norma2_sv) * (x_sv[, 1]^p1) * (x_sv[, 2]^p2)
  w_primeros_10[m] <- sum(coeficientes_y_alpha * phi_m)
}
names(w_primeros_10) <- nombres_terminos

cat("e) Primeros 10 coeficientes del vector w (aproximación en base polinómica):\n")
print(round(w_primeros_10, 6))

# f) Ancho del canal: 
rbf_func <- rbfdot(sigma = 0.5)
sv_puntos <- as.matrix(datos[indices_sv, c("X1", "X2")])
K_sv <- kernelMatrix(rbf_func, sv_puntos)
norma_w2 <- as.numeric(t(coeficientes_y_alpha) %*% K_sv %*% coeficientes_y_alpha)
norma_w <- sqrt(norma_w2)
ancho_canal <- 2 / norma_w

cat(sprintf("f) Norma de w en el espacio transformado: ||w|| = %8.6f\n", norma_w))
cat(sprintf("   Ancho del canal: M = 2 / ||w|| = %8.6f\n", ancho_canal))

# 2.3. Predicción sobre el conjunto de entrenamiento y Accuracy
pred_train <- predict(modelo_ksvm, datos)
matriz_confusion_ksvm <- table(Prediccion = pred_train, Real = datos$Y)
cat("\nMatriz de confusión en entrenamiento (ksvm):\n")
print(matriz_confusion_ksvm)
accuracy_ksvm <- sum(diag(matriz_confusion_ksvm)) / sum(matriz_confusion_ksvm)
cat("Porcentaje de aciertos en entrenamiento:", accuracy_ksvm * 100, "%\n\n")

# ------------------------------------------------------------------------------
# BLOQUE 3. SVM con IPOP (Interior Point Optimization Procedure)
# ------------------------------------------------------------------------------
cat("=== BLOQUE 3: SVM CON IPOP (OPTIMIZACIÓN CUADRÁTICA DUAL) ===\n")

# Formulación matricial del problema dual:
# min (1/2 * alpha^T * H * alpha - c^T * alpha)
# s.t. A * alpha = 0 (b <= A*alpha <= b + r)
#      0 <= alpha <= C
N <- nrow(datos)
X_mat <- as.matrix(datos[, c("X1", "X2")])
Y_num <- ifelse(datos$Y == "1", 1, -1)

# Matriz H: H_ij = y_i * y_j * K(x_i, x_j)
K_completa <- kernelMatrix(rbf_func, X_mat)
H_mat <- K_completa * (Y_num %*% t(Y_num))

# Vector c (lineal): -1 para todos los alfas (para maximizar sum(alpha))
c_vec <- rep(-1, N)

# Restricción de igualdad: sum(y_i * alpha_i) = 0
A_mat <- matrix(Y_num, nrow = 1)
b_restriccion <- 0
r_restriccion <- 0

# Restricciones de caja (box constraints): 0 <= alpha_i <= C
l_cota_inf <- rep(0, N)
u_cota_sup <- rep(10, N)  # C = 10

# Llamada al optimizador IPOP de kernlab
solucion_ipop <- ipop(
  c = c_vec, 
  H = H_mat, 
  A = A_mat, 
  b = b_restriccion, 
  l = l_cota_inf, 
  u = u_cota_sup, 
  r = r_restriccion, 
  verb = 0
)

# 3.2. Extracción de valores
alfa_ipop <- primal(solucion_ipop)
cat("Valores de todos los multiplicadores de Lagrange alpha_i (IPOP):\n")
print(round(alfa_ipop, 6))

# Umbral numérico para identificar vectores soporte
umbral_sv <- 1e-4
indices_sv_ipop <- which(alfa_ipop > umbral_sv)

cat("\nResultados con IPOP:\n")
cat(" - Número de vectores soporte:", length(indices_sv_ipop), "\n")
cat(" - Índices de vectores soporte:", paste(indices_sv_ipop, collapse = ", "), "\n")

# Término independiente b en IPOP:
# Para los vectores soporte en margen (0 < alpha < C):
# b = y_k - sum_{i} alpha_i * y_i * K(x_i, x_k)
f_sin_b <- colSums(alfa_ipop * Y_num * K_completa)
# Promedio sobre los vectores de soporte libres:
b_ipop <- mean(Y_num[indices_sv_ipop] - f_sin_b[indices_sv_ipop])
cat(sprintf(" - Término independiente b: %8.6f\n", b_ipop))

# Función de decisión f(x):
# f(x) = sign( sum_{i in SV} alpha_i * y_i * K(x_i, x) + b )
pred_score_ipop <- f_sin_b + b_ipop
pred_clase_ipop <- ifelse(pred_score_ipop >= 0, 1, -1)
acc_ipop <- mean(pred_clase_ipop == Y_num)
cat(" - Accuracy de la función de decisión (IPOP):", acc_ipop * 100, "%\n\n")

# ------------------------------------------------------------------------------
# BLOQUE 4. Ajuste de Parámetros con tune()
# ------------------------------------------------------------------------------
cat("=== BLOQUE 4: SELECCIÓN DE HIPERPARÁMETROS CON TUNE ===\n")

# Partición del conjunto de datos en Entrenamiento (70%) y Test (30%)
ind_particion <- sample(2, nrow(datos), replace = TRUE, prob = c(0.7, 0.3))
train_set <- datos[ind_particion == 1, ]
test_set  <- datos[ind_particion == 2, ]

cat(sprintf("Instancias en Train: %d | Instancias en Test: %d\n", nrow(train_set), nrow(test_set)))

# 4.1. Llamada a tune() para evaluar la cuadrícula de parámetros:
# C in {0.1, 1, 10, 100}
# gamma in {0.1, 0.5}
grid_c <- c(0.1, 1, 10, 100)
grid_gamma <- c(0.1, 0.5)

resultado_tune <- tune(
  svm, 
  train.x = Y ~ ., 
  data = train_set, 
  kernel = "radial",
  ranges = list(cost = grid_c, gamma = grid_gamma)
)

print(summary(resultado_tune))

# 4.2. Identificar los valores óptimos de C y gamma
mejor_modelo <- resultado_tune$best.model
c_optimo     <- resultado_tune$best.parameters$cost
gamma_optimo <- resultado_tune$best.parameters$gamma

cat(sprintf("\nValores óptimos identificados por tune():\n"))
cat(sprintf(" - Cost (C) óptimo    : %g\n", c_optimo))
cat(sprintf(" - Gamma óptimo        : %g\n", gamma_optimo))

# 4.3. Predicción con los datos de test y cálculo del accuracy
predicciones_test <- predict(mejor_modelo, newdata = test_set)
matriz_confusion_test <- table(Prediccion = predicciones_test, Real = test_set$Y)

cat("\nMatriz de Confusión en el conjunto de Test:\n")
print(matriz_confusion_test)

accuracy_test <- sum(diag(matriz_confusion_test)) / sum(matriz_confusion_test)
cat(sprintf("\nAccuracy final en Test: %.2f%%\n", accuracy_test * 100))
cat("======================================================================\n")

