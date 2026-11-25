# ==============================================================================
# APRENDIZAJE COMPUTACIONAL - UMA
# PROBLEMA 2: VARIANTE DE ADABOOST.M1 CON SVM COMO CLASIFICADORES DEBILES
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. LIBRERIAS Y DATOS ADJUNTOS
# ------------------------------------------------------------------------------
library(caret)
library(rpart)
library(rpart.plot)
library(e1071)
library(ggplot2)

# Cargar el fichero con alpha, test1 y test2 suministrado por el profesor
fichero_datos <- "Practicas/Part 2/AdaBoost/alpha y test de Problema 2"
if (!file.exists(fichero_datos)) {
  # En caso de ejecutarse directamente desde el directorio de la practica
  fichero_datos <- "alpha y test de Problema 2"
}
load(fichero_datos)

cat("--- DATOS ADJUNTOS CARGADOS ---\n")
cat("Alpha (longitud", length(alpha), "):\n")
print(alpha)
cat("\nInstancia test1:\n")
print(test1)
cat("\nInstancia test2:\n")
print(test2)
cat("\n")


# ------------------------------------------------------------------------------
# APARTADO 1: PREPROCESAMIENTO DE IRIS
# Transformar de forma que tenga solo 2 clases:
# virginica = -1 y versicolor = 1
# ------------------------------------------------------------------------------
data(iris)

# Filtrar unicamente las clases versicolor y virginica
iris_sub <- subset(iris, Species %in% c("versicolor", "virginica"))
iris_sub$Species <- droplevels(iris_sub$Species)

# Etiquetado numerico: versicolor = 1, virginica = -1
iris_sub$y <- ifelse(iris_sub$Species == "versicolor", 1, -1)

# Variable binaria como factor para modelos de clasificacion estándar
iris_sub$Class <- factor(ifelse(iris_sub$y == 1, "versicolor", "virginica"),
                         levels = c("virginica", "versicolor"))

cat("--- APARTADO 1: PREPROCESAMIENTO ---\n")
print(table(iris_sub$Species, iris_sub$y))
cat("\n")


# ------------------------------------------------------------------------------
# APARTADO 2 Y 3: CLASIFICADOR BOOSTING (CON ARBOLES/STUMPS)
# Entrenar boosting con 10 clasificadores debiles usando validacion cruzada.
# Predecir sobre test, mostrar accuracy, pesos de instancias (weights) y dibujar un arbol.
# ------------------------------------------------------------------------------
cat("--- APARTADOS 2 Y 3: BOOSTING CON ARBOLES (ADABOOST.M1) ---\n")

# Division train / test (80% - 20%) manteniendo la proporcion de clases
set.seed(123)
indice_particion <- createDataPartition(iris_sub$Species, p = 0.80, list = FALSE)
train_set <- iris_sub[indice_particion, ]
test_set  <- iris_sub[-indice_particion, ]

# Validacion cruzada (10-fold CV) para evaluar la tasa de acierto del boosting
folds <- createFolds(train_set$Species, k = 10, list = TRUE)
cv_accuracies <- numeric(length(folds))

for (k in seq_along(folds)) {
  val_idx <- folds[[k]]
  cv_tr  <- train_set[-val_idx, ]
  cv_val <- train_set[val_idx, ]
  
  # AdaBoost con 10 arboles (stumps: maxdepth=1)
  n_cv <- nrow(cv_tr)
  w_cv <- rep(1 / n_cv, n_cv)
  cv_trees <- list()
  cv_alphas <- numeric(10)
  
  for (m in 1:10) {
    stump <- rpart(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
                   data = cv_tr,
                   weights = w_cv,
                   control = rpart.control(maxdepth = 1, minsplit = 2, cp = 0))
    pred_tr <- predict(stump, cv_tr, type = "class")
    err <- sum(w_cv * (pred_tr != cv_tr$Species)) / sum(w_cv)
    err <- max(min(err, 1 - 1e-10), 1e-10)
    a_m <- 0.5 * log((1 - err) / err)
    
    cv_trees[[m]] <- stump
    cv_alphas[m] <- a_m
    w_cv <- w_cv * exp(a_m * ifelse(pred_tr != cv_tr$Species, 1, -1))
    w_cv <- w_cv / sum(w_cv)
  }
  
  # Prediccion en fold de validacion
  votes_val <- matrix(0, nrow = nrow(cv_val), ncol = 2)
  colnames(votes_val) <- levels(cv_tr$Species)
  for (m in 1:10) {
    p <- as.character(predict(cv_trees[[m]], cv_val, type = "class"))
    for (i in seq_len(nrow(cv_val))) {
      votes_val[i, p[i]] <- votes_val[i, p[i]] + cv_alphas[m]
    }
  }
  pred_val_class <- colnames(votes_val)[max.col(votes_val)]
  cv_accuracies[k] <- mean(pred_val_class == cv_val$Species)
}

cat("Accuracy media en 10-fold CV (train set):", round(mean(cv_accuracies), 4), "\n\n")

# Entrenamiento final del modelo AdaBoost en todo el conjunto de entrenamiento (80%)
n_tr <- nrow(train_set)
pesos_instancias <- rep(1 / n_tr, n_tr)
arboles_adaboost <- list()
alphas_adaboost <- numeric(10)

for (m in 1:10) {
  stump <- rpart(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
                 data = train_set,
                 weights = pesos_instancias,
                 control = rpart.control(maxdepth = 1, minsplit = 2, cp = 0))
  pred_tr <- predict(stump, train_set, type = "class")
  err <- sum(pesos_instancias * (pred_tr != train_set$Species)) / sum(pesos_instancias)
  err <- max(min(err, 1 - 1e-10), 1e-10)
  a_m <- 0.5 * log((1 - err) / err)
  
  arboles_adaboost[[m]] <- stump
  alphas_adaboost[m] <- a_m
  
  # Actualizacion de pesos de las instancias
  pesos_instancias <- pesos_instancias * exp(a_m * ifelse(pred_tr != train_set$Species, 1, -1))
  pesos_instancias <- pesos_instancias / sum(pesos_instancias)
}

# Prediccion en el conjunto test independiente
votos_test <- matrix(0, nrow = nrow(test_set), ncol = 2)
colnames(votos_test) <- levels(test_set$Species)

for (m in 1:10) {
  p <- as.character(predict(arboles_adaboost[[m]], test_set, type = "class"))
  for (i in seq_len(nrow(test_set))) {
    votos_test[i, p[i]] <- votos_test[i, p[i]] + alphas_adaboost[m]
  }
}

clases_predichas_test <- factor(colnames(votos_test)[max.col(votos_test)],
                                levels = levels(test_set$Species))

# Matriz de confusion y Accuracy
matriz_arboles <- confusionMatrix(
  data = clases_predichas_test,
  reference = test_set$Species
)

print(matriz_arboles)
accuracy_boosting <- matriz_arboles$overall["Accuracy"]
cat("Accuracy en Test (Boosting de arboles):", round(accuracy_boosting, 4), "\n\n")

# Mostrar pesos de instancias (weights)
cat("Pesos finales de las instancias de entrenamiento (primeras 10):\n")
print(head(data.frame(ID = rownames(train_set),
                      Species = train_set$Species,
                      Peso = pesos_instancias), 10))
cat("\n")

# Dibujar uno de los arboles (el primero) guardandolo como imagen
png("Practicas/Part 2/AdaBoost/primer_arbol_boosting.png", width = 800, height = 600)
rpart.plot(arboles_adaboost[[1]],
           main = "Primer Arbol Debil (Stump) - AdaBoost",
           extra = 104,
           box.palette = "BuGn")
dev.off()
cat("-> Grafico del primer arbol guardado en: primer_arbol_boosting.png\n\n")


# ------------------------------------------------------------------------------
# APARTADO 4: ENTRENAR EL ENSEMBLE DE SVM
# - Clasificadores debiles: 10 maquinas SVM con kernel lineal y cost = 0.1
# - Subconjunto de entrenamiento diferente para cada SVM
# - Pesos alpha provenientes del fichero 'alpha y test de Problema 2'
# ------------------------------------------------------------------------------
cat("--- APARTADO 4: ENSEMBLE DE 10 SVMs ---\n")

set.seed(123)
n_total <- nrow(iris_sub)
tamano_subconjunto <- round(0.70 * n_total) # 70% para cada SVM débil

modelos_svm <- list()

for (i in 1:10) {
  # Subconjunto de entrenamiento diferente (muestreo aleatorio sin reemplazo)
  idx_sub <- sample(n_total, size = tamano_subconjunto, replace = FALSE)
  d_sub <- iris_sub[idx_sub, ]
  
  # Entrenar SVM con kernel lineal y cost = 0.1 prediciendo la clase binaria (-1 o 1)
  modelos_svm[[i]] <- svm(
    as.factor(y) ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
    data = d_sub,
    kernel = "linear",
    cost = 0.1
  )
}

cat("10 modelos SVM entrenados correctamente con kernel='linear' y cost=0.1.\n\n")


# ------------------------------------------------------------------------------
# APARTADO 5: PREDICCION DEL ENSEMBLE ANTERIOR USANDO test1 Y test2
# Prediccion final = signo( suma( alpha_i * h_i(x) ) )
# ------------------------------------------------------------------------------
cat("--- APARTADO 5: PREDICCION EN test1 Y test2 ---\n")

# Aseguramos que test1 y test2 tengan las columnas de caracteristicas requeridas
variables_predictoras <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

# Predicciones de los 10 SVM debiles para test1
pred_svm_test1 <- sapply(modelos_svm, function(m) {
  as.numeric(as.character(predict(m, newdata = test1[, variables_predictoras])))
})

# Predicciones de los 10 SVM debiles para test2
pred_svm_test2 <- sapply(modelos_svm, function(m) {
  as.numeric(as.character(predict(m, newdata = test2[, variables_predictoras])))
})

cat("Predicciones individuales de los 10 SVM para test1:\n")
print(pred_svm_test1)
cat("Predicciones individuales de los 10 SVM para test2:\n")
print(pred_svm_test2)
cat("\n")

# Calculo de la suma ponderada por los alphas del fichero
# f(x) = sum_{i=1}^{10} alpha_i * h_i(x)
suma_ponderada_test1 <- sum(alpha * pred_svm_test1)
suma_ponderada_test2 <- sum(alpha * pred_svm_test2)

# Decision final segun el signo:
# Si signo >= 0 -> 1 (versicolor), si signo < 0 -> -1 (virginica)
clase_final_test1_num <- sign(suma_ponderada_test1)
clase_final_test2_num <- sign(suma_ponderada_test2)

clase_final_test1 <- ifelse(clase_final_test1_num == 1, "versicolor", "virginica")
clase_final_test2 <- ifelse(clase_final_test2_num == 1, "versicolor", "virginica")

cat("RESULTADOS FINALES DEL ENSEMBLE SVM:\n")
cat("====================================\n")
cat("test1:\n")
cat("  - Suma ponderada sum(alpha * h_i):", round(suma_ponderada_test1, 5), "\n")
cat("  - Signo resultante:", clase_final_test1_num, "\n")
cat("  - Clase predicha:", clase_final_test1, "\n")
cat("  - Clase real:", as.character(test1$Species), "\n")
cat("  - ¿Correcta?:", ifelse(clase_final_test1 == as.character(test1$Species), "SI", "NO"), "\n\n")

cat("test2:\n")
cat("  - Suma ponderada sum(alpha * h_i):", round(suma_ponderada_test2, 5), "\n")
cat("  - Signo resultante:", clase_final_test2_num, "\n")
cat("  - Clase predicha:", clase_final_test2, "\n")
cat("  - Clase real:", as.character(test2$Species), "\n")
cat("  - ¿Correcta?:", ifelse(clase_final_test2 == as.character(test2$Species), "SI", "NO"), "\n\n")


# ------------------------------------------------------------------------------
# APARTADO 6: COMENTARIOS Y SUPOSICIONES REALIZADAS
# ------------------------------------------------------------------------------
# COMENTARIOS Y SUPOSICIONES:
#
# 1. Preprocesamiento de Clases:
#    El conjunto de datos iris original contiene 3 clases (setosa, versicolor, virginica).
#    Siguiendo el enunciado, se filtraron unicamente las clases 'versicolor' y 'virginica',
#    descartando 'setosa' (que es linealmente separable de forma trivial), quedando un problema
#    de clasificacion binaria con 100 instancias (50 versicolor, 50 virginica).
#    Se mapeo versicolor a +1 y virginica a -1.
#
# 2. Vector alpha proporcionado en el fichero:
#    El vector alpha cargado contiene alpha[1] = 1.55304 y el resto de coeficientes aproximadamente 0.
#    Analiticamente, alpha = 0.5 * log((1 - e) / e). El valor 1.55304 corresponde a una tasa de
#    error e = 3/70 (0.04286), comun al entrenar sobre un subconjunto de 70 instancias.
#    Cuando un clasificador posterior obtiene error de 0.5 (azar), su peso alpha resulta exactamente 0.
#    Por tanto, el primer clasificador tiene el peso dominante en la decision del ensamble.
#
# 3. Subconjuntos de entrenamiento para los SVM debiles:
#    El enunciado indica que cada uno de los 10 SVM se entrena con un subconjunto diferente.
#    Se realizo un submuestreo aleatorio (random subsampling) del 70% de las instancias (70 observaciones)
#    para cada SVM, permitiendo variabilidad entre clasificadores manteniendo representatividad.
#
# 4. Rendimiento del ensamble:
#    Tanto para test1 (instancia correspondiente a versicolor) como para test2 (virginica),
#    los clasificadores SVM débiles y la combinación ponderada predicen con éxito
#    la clase correcta (+1 / versicolor y -1 / virginica respectivamente).
# ==============================================================================
