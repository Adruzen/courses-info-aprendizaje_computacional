
t_total_ini <- Sys.time()

library(randomForest)
library(adabag)
library(rpart)
library(kernlab)
library(e1071)

# ==============================================================================
# APARTADO 1. Carga, preprocesamiento y justificacion de las decisiones
# ==============================================================================

# 1. Cargamos los datos.
# IMPORTANTE: en el fichero CSV de Spaceship Titanic los valores faltantes en las
# columnas categoricas y logicas aparecen como cadenas vacias "" en lugar de "NA".
# Indicamos na.strings = c("", "NA") para que na.omit() elimine correctamente todos
# los datos faltantes y no convierta "" en un nivel adicional del factor.
datos_base <- read.csv(
  "train Space Titanic.csv",
  na.strings = c("", "NA"),
  stringsAsFactors = TRUE
)

# 2. Eliminamos los identificadores no informativos
datos_base$PassengerId <- NULL
datos_base$Name <- NULL

# 3. Eliminamos las observaciones con valores faltantes
datos_base <- na.omit(datos_base)

# 4. Division de un atributo compuesto en varios ("Y al contrario"):
# El atributo Cabin tiene el formato "Deck/Num/Side" (por ejemplo, "B/0/P"). Tiene sentido
# dividirlo en tres atributos distintos (Deck, Num y Side), ya que los tres pueden influir
# de forma diferente en la supervivencia. Por lo que recuerdo, Deck era uno de los factores
# decisivos en el Titanic original, por lo que separarlo como parametro propio es muy importante.
partes_cabin <- strsplit(as.character(datos_base$Cabin), "/")
datos_base$CabinDeck <- as.factor(sapply(partes_cabin, "[", 1))
datos_base$CabinNum  <- as.numeric(sapply(partes_cabin, "[", 2))
datos_base$CabinSide <- as.factor(sapply(partes_cabin, "[", 3))
datos_base$Cabin <- NULL

# La variable objetivo debe ser obligatoriamente un factor; limpiamos niveles sin uso
datos_base$Transported <- as.factor(datos_base$Transported)
datos_base <- droplevels(datos_base)

# En cuanto a la reduccion de atributos, el candidato evidente son los gastos.
# Sin embargo, no esta tan claro si realmente conviene sumarlos todos en un unico atributo
# o si la estructura de los gastos (servicios de lujo frente a gastos habituales) influye
# en la supervivencia. Por ello, he decidido crear tres variantes del dataset y comprobar
# cual funciona mejor:

# Variante 1: no agrupamos los gastos (mantenemos las 5 columnas originales)
datos_v1 <- datos_base

# Variante 2 (compromiso): dividimos los gastos en 2 grupos semanticos (lujo y basicos)
datos_v2 <- datos_base
datos_v2$GastosLujo    <- datos_v2$RoomService + datos_v2$Spa + datos_v2$VRDeck
datos_v2$GastosBasicos <- datos_v2$FoodCourt + datos_v2$ShoppingMall
datos_v2$RoomService  <- NULL
datos_v2$FoodCourt    <- NULL
datos_v2$ShoppingMall <- NULL
datos_v2$Spa          <- NULL
datos_v2$VRDeck       <- NULL

# Variante 3: reducimos los 5 gastos a una unica suma total (GastosTotales)
datos_v3 <- datos_base
datos_v3$GastosTotales <- datos_v3$RoomService + datos_v3$FoodCourt +
  datos_v3$ShoppingMall + datos_v3$Spa + datos_v3$VRDeck
datos_v3$RoomService  <- NULL
datos_v3$FoodCourt    <- NULL
datos_v3$ShoppingMall <- NULL
datos_v3$Spa          <- NULL
datos_v3$VRDeck       <- NULL

# Para facilitar la comparacion, guardamos los tres conjuntos de datos en una lista
variantes <- list(
  v1_5gastos = datos_v1,
  v2_2grupos = datos_v2,
  v3_1suma   = datos_v3
)
nombres_var <- names(variantes)

cat("Filas tras preprocesamiento:", nrow(datos_base), "\n")
for (v in nombres_var) {
  cat(" -", v, ": columnas =", ncol(variantes[[v]]), "\n")
}

# 6. Division unica 80% / 20% para las 3 variantes,
# de modo que los modelos se comparen exactamente con los mismos pasajeros de train y test.
set.seed(200)
d_size <- dim(datos_base)[1]
dtest_size <- ceiling(0.2 * d_size)
samples <- sample(d_size, d_size, replace = FALSE)
indexes <- samples[1:dtest_size]

lista_dtrain <- list()
lista_dtest  <- list()
for (v in nombres_var) {
  lista_dtrain[[v]] <- variantes[[v]][-indexes, ]
  lista_dtest[[v]]  <- variantes[[v]][indexes, ]
}


# ==============================================================================
# APARTADO 2. Random Forest con ntry=4 (mtry=4) y 50 arboles para las 3 variantes
# ==============================================================================
t_p2_ini <- Sys.time()

lista_rf  <- list()
lista_imp <- list()
acc_rf    <- numeric(length(nombres_var))
names(acc_rf) <- nombres_var

cat("\n==================== APARTADO 2: RANDOM FOREST ====================\n")
for (v in nombres_var) {
  dtrain <- lista_dtrain[[v]]
  dtest  <- lista_dtest[[v]]

  set.seed(200)
  rf <- randomForest(
    Transported ~ .,
    data = dtrain,
    mtry = 4,
    ntree = 50
  )

  prediccion_rf <- predict(rf, newdata = dtest)
  matrizconfusion_rf <- table(prediccion_rf, dtest$Transported)
  accuracy_rf <- sum(diag(matrizconfusion_rf)) / sum(matrizconfusion_rf)

  lista_rf[[v]]  <- rf
  lista_imp[[v]] <- importance(rf)
  acc_rf[v]      <- accuracy_rf

  cat("\n--- Random Forest |", v, "---\n")
  print(matrizconfusion_rf)
  cat("Accuracy RF (", v, "):", round(accuracy_rf, 5), "\n")
  cat("Importancia de variables (MeanDecreaseGini):\n")
  print(lista_imp[[v]])
}

# Determinamos la mejor variante del Apartado 2 y dibujamos su grafico de importancia
mejor_var_p2 <- names(which.max(acc_rf))
cat("\nMejor variante en Apartado 2 (RF):", mejor_var_p2,
    "| Accuracy:", round(acc_rf[mejor_var_p2], 5), "\n")
varImpPlot(lista_rf[[mejor_var_p2]], main = paste("Importancia RF -", mejor_var_p2))

t_p2_fin <- Sys.time()
cat("Tiempo Apartado 2 (seg):", round(as.numeric(difftime(t_p2_fin, t_p2_ini, units = "secs")), 2), "\n")


# ==============================================================================
# APARTADO 3. Random Forest eliminando la variable de menor peso
# Se ejecuta unicamente para la variante con mejor accuracy en el Apartado 2.
# ==============================================================================
t_p3_ini <- Sys.time()

cat("\n==================== APARTADO 3: RF SIN VARIABLE DE MENOR PESO ====================\n")
imp_mejor <- lista_imp[[mejor_var_p2]]
var_menor_peso <- rownames(imp_mejor)[which.min(imp_mejor[, "MeanDecreaseGini"])]
cat("Variante seleccionada:", mejor_var_p2,
    "| Variable eliminada (menor MeanDecreaseGini):", var_menor_peso, "\n")

dtrain_rf2 <- lista_dtrain[[mejor_var_p2]]
dtest_rf2  <- lista_dtest[[mejor_var_p2]]
dtrain_rf2[[var_menor_peso]] <- NULL
dtest_rf2[[var_menor_peso]]  <- NULL

set.seed(200)
rf2 <- randomForest(
  Transported ~ .,
  data = dtrain_rf2,
  mtry = 4,
  ntree = 50
)

prediccion_rf2 <- predict(rf2, newdata = dtest_rf2)
matrizconfusion_rf2 <- table(prediccion_rf2, dtest_rf2$Transported)
print(matrizconfusion_rf2)

accuracy_rf2 <- sum(diag(matrizconfusion_rf2)) / sum(matrizconfusion_rf2)
cat("Accuracy RF sin", var_menor_peso, "(", mejor_var_p2, "):", round(accuracy_rf2, 5),
    "| vs RF original:", round(acc_rf[mejor_var_p2], 5),
    "| Diferencia:", round(accuracy_rf2 - acc_rf[mejor_var_p2], 5), "\n")

# Comentario sobre la eleccion del modelo:
# Eliminar la variable de menor peso (VIP) practicamente no empeora el rendimiento del modelo
# (e incluso lo mejora ligeramente en algunas particiones), mientras que el modelo resulta mas
# sencillo y con menos ruido. Por el principio de parsimonia, es preferible utilizar rf2.

t_p3_fin <- Sys.time()
cat("Tiempo Apartado 3 (seg):", round(as.numeric(difftime(t_p3_fin, t_p3_ini, units = "secs")), 2), "\n")


# ==============================================================================
# APARTADO 4. AdaBoost.M1 con arboles de caracteristicas similares al apartado 2
# ==============================================================================
# Usamos mfinal = 50 (50 arboles, igual que en el apartado 2, y 50 pesos alpha para el apartado 5)
# y control = rpart.control(cp = 0.001, minsplit = 7) (arboles multinivel similares a RF).
t_p4_ini <- Sys.time()

lista_adaboost <- list()
lista_alpha    <- list()
acc_ada        <- numeric(length(nombres_var))
names(acc_ada) <- nombres_var

cat("\n==================== APARTADO 4: ADABOOST.M1 ====================\n")
for (v in nombres_var) {
  dtrain <- lista_dtrain[[v]]
  dtest  <- lista_dtest[[v]]

  set.seed(200)
  modelo_adaboost <- boosting(
    Transported ~ .,
    data = dtrain,
    boos = TRUE,
    mfinal = 50,
    coeflearn = "Breiman",
    control = rpart.control(cp = 0.001, minsplit = 7)
  )

  predicciones_ada <- predict(modelo_adaboost, newdata = dtest)
  clases_predichas_ada <- factor(predicciones_ada$class, levels = levels(dtest$Transported))
  matrizconfusion_ada <- table(clases_predichas_ada, dtest$Transported)
  accuracy_ada <- sum(diag(matrizconfusion_ada)) / sum(matrizconfusion_ada)

  lista_adaboost[[v]] <- modelo_adaboost
  lista_alpha[[v]]    <- modelo_adaboost$weights
  acc_ada[v]          <- accuracy_ada

  cat("\n--- AdaBoost.M1 |", v, "---\n")
  print(matrizconfusion_ada)
  cat("Accuracy AdaBoost.M1 (", v, "):", round(accuracy_ada, 5),
      "| vs RF (", v, "):", round(acc_rf[v], 5), "\n")
}

t_p4_fin <- Sys.time()
cat("Tiempo Apartado 4 (seg):", round(as.numeric(difftime(t_p4_fin, t_p4_ini, units = "secs")), 2), "\n")


# ==============================================================================
# APARTADO 5. Ensemble con filosofia AdaBoost.M1 de 50 SVM (RBF, kernlab)
# Para ahorrar tiempo de ejecucion, aqui se ejecuta unicamente la variante ganadora
# (v1_5gastos), aunque previamente se probaron las tres variantes:
#   - v1_5gastos: Accuracy = 0.81818 (C = 5, sigma = 0.1) - mejor resultado
#   - v2_2grupos: Accuracy = 0.81523 (C = 5, sigma = 0.1)
#   - v3_1suma:   Accuracy = 0.72727 (C = 0.1, sigma = 0.05)
# Los pesos alpha se obtienen directamente del modelo AdaBoost.M1 del apartado 4.
# ==============================================================================
t_p5_ini <- Sys.time()

acc_svm <- rep(NA_real_, length(nombres_var))
names(acc_svm) <- nombres_var

# Seleccionamos la variante ganadora segun los apartados 2 (RF) y 4 (AdaBoost.M1): v1_5gastos
v <- names(which.max((acc_rf + acc_ada) / 2))

cat("\n==================== APARTADO 5: ENSEMBLE 50 SVM (RBF, kernlab) ====================\n")
cat("Variante ejecutada en Apartado 5 (ganadora previa, por ahorro de tiempo):", v, "\n")

alpha <- lista_alpha[[v]]

# Binarizacion de la variable objetivo en "-1" y "1" para la votacion ponderada
dtrain_svm <- lista_dtrain[[v]]
dtest_svm  <- lista_dtest[[v]]

dtrain_svm$Transported <- ifelse(
  toupper(as.character(dtrain_svm$Transported)) == "TRUE", "1", "-1"
)
dtest_svm$Transported <- ifelse(
  toupper(as.character(dtest_svm$Transported)) == "TRUE", "1", "-1"
)
dtrain_svm$Transported <- as.factor(dtrain_svm$Transported)
dtest_svm$Transported  <- factor(dtest_svm$Transported, levels = levels(dtrain_svm$Transported))

# Seleccion de hiperparametros del kernel RBF (cost -> C, gamma -> sigma) con e1071::tune()
# sobre una submuestra aleatoria de 1000 observaciones con validacion cruzada de 3 pliegues
set.seed(123)
idx_tune <- sample(1:nrow(dtrain_svm), min(1000, nrow(dtrain_svm)))

modelo_tune <- tune(
  svm,
  Transported ~ .,
  data = dtrain_svm[idx_tune, ],
  kernel = "radial",
  ranges = list(cost = c(0.1, 1, 5), gamma = c(0.01, 0.05, 0.1)),
  tunecontrol = tune.control(cross = 3)
)

mejor_C     <- modelo_tune$best.parameters$cost
mejor_sigma <- modelo_tune$best.parameters$gamma

# Entrenamiento de 50 maquinas SVM (kernlab::ksvm) en submuestras aleatorias del 80% de dtrain_svm
numeroSVM <- 50
listaSVM <- list()

set.seed(123)
for (i in 1:numeroSVM) {
  n <- nrow(dtrain_svm)
  porcentaje <- 0.8
  indicesSVM <- sample(1:n, size = round(n * porcentaje))
  trainSVM <- dtrain_svm[indicesSVM, ]

  modeloSvm <- ksvm(
    Transported ~ .,
    data = trainSVM,
    type = "C-svc",
    kernel = "rbfdot",
    kpar = list(sigma = mejor_sigma),
    C = mejor_C
  )
  listaSVM[[i]] <- modeloSvm
}

# Predicciones de las 50 SVM sobre todo el conjunto de test dtest_svm
listaSVMPredicciones <- list()
for (i in 1:numeroSVM) {
  prediccionSVM <- predict(listaSVM[[i]], dtest_svm)
  listaSVMPredicciones[[i]] <- prediccionSVM
}

matrizPrediccionesSVM <- sapply(listaSVMPredicciones, function(x) {
  as.numeric(as.character(x))
})

# Votacion mayoritaria ponderada (Weighted Majority Voting) usando los pesos alpha del apartado 4
prediccion_final_num <- apply(matrizPrediccionesSVM, 1, function(predicciones_fila) {
  resultado <- predicciones_fila * alpha
  ifelse(sum(resultado) >= 0, "1", "-1")
})

prediccion_final_svm <- factor(prediccion_final_num, levels = levels(dtest_svm$Transported))
matrizconfusion_svm <- table(prediccion_final_svm, dtest_svm$Transported)
accuracy_svm <- sum(diag(matrizconfusion_svm)) / sum(matrizconfusion_svm)
acc_svm[v] <- accuracy_svm

t_p5_fin <- Sys.time()
cat("\n--- Ensemble 50 SVM |", v, "(C =", mejor_C, ", sigma =", mejor_sigma, ") ---\n")
print(matrizconfusion_svm)
cat("Accuracy Ensemble 50 SVM (", v, "):", round(accuracy_svm, 5),
    "| Tiempo Apartado 5 (seg):", round(as.numeric(difftime(t_p5_fin, t_p5_ini, units = "secs")), 2), "\n")


# ==============================================================================
# COMPARACION FINAL DE LAS 3 VARIANTES Y ELECCION DE LA GANADORA
# ==============================================================================
mat_acc <- cbind(acc_rf, acc_ada, acc_svm)

resumen <- data.frame(
  Variante      = nombres_var,
  RF_Ap2        = as.numeric(round(acc_rf, 5)),
  AdaBoost_Ap4  = as.numeric(round(acc_ada, 5)),
  SVM50_Ap5     = as.numeric(round(acc_svm, 5)),
  Media_Modelos = as.numeric(round(rowMeans(mat_acc, na.rm = TRUE), 5)),
  Max_Variante  = as.numeric(round(apply(mat_acc, 1, max, na.rm = TRUE), 5)),
  stringsAsFactors = FALSE
)

cat("\n==================== RESUMEN COMPARATIVO FINAL ====================\n")
print(resumen)
cat("Apartado 3 (RF sin", var_menor_peso, "en", mejor_var_p2, "):", round(accuracy_rf2, 5), "\n")

ganador_media <- resumen$Variante[which.max(resumen$Media_Modelos)]
ganador_max   <- resumen$Variante[which.max(resumen$Max_Variante)]

cat("\n>>> VARIANTE GANADORA (por media de los modelos):", ganador_media,
    "| Media Accuracy =", max(resumen$Media_Modelos), "\n")
cat(">>> VARIANTE GANADORA (por mejor accuracy individual):", ganador_max,
    "| Max Accuracy =", max(resumen$Max_Variante), "\n")
cat("Tiempo TOTAL (seg):", round(as.numeric(difftime(Sys.time(), t_total_ini, units = "secs")), 2), "\n")

# Conclusion final sobre las 3 variantes:
# - La ganadora en todos los modelos principales es v1_5gastos (las 5 columnas de gastos separadas):
#   RF = 0.81301 (sin VIP = 0.81670), AdaBoost.M1 = 0.81301, Ensemble 50 SVM = 0.81818.
# - La variante intermedia v2_2grupos (GastosLujo + GastosBasicos) obtiene resultados cercanos
#   (RF = 0.80710, AdaBoost = 0.79823, SVM probado previamente = 0.81523), pero ligeramente inferiores.
# - La reduccion total a una sola suma v3_1suma (GastosTotales) reduce el accuracy entre un 6.5% y un 9%
#   (RF = 0.74723, AdaBoost = 0.74723, SVM probado previamente = 0.72727), lo que confirma que
#   la estructura de los gastos es fundamental para la prediccion.
