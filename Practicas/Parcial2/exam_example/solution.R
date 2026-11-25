# ==============================================================================
# Экзаменационная работа: Spaceship Titanic (Random Forest, AdaBoost.M1, SVM)
# Сравнение 3 вариантов предобработки расходов:
#   1) v1_5gastos — без свёртки (5 отдельных столбцов расходов)
#   2) v2_2grupos — компромисс (2 группы: GastosLujo и GastosBasicos)
#   3) v3_1suma   — полная свёртка в 1 столбец (GastosTotales)
# Стиль кода и названия переменных адаптированы под примеры курса (code_examples).
# ==============================================================================

t_total_ini <- Sys.time()

library(randomForest)
library(adabag)
library(rpart)
library(kernlab)
library(e1071)

# ==============================================================================
# APARTADO 1. Загрузка, предобработка и обоснование решений по атрибутам
# ==============================================================================

# 1. Загружаем данные.
# ВАЖНО: в CSV-файле Spaceship Titanic пропуски в строковых и логических колонках
# записаны как пустые строки "", а не как "NA". Указываем na.strings = c("", "NA"),
# чтобы na.omit() корректно удалил все пропуски, а не превратил "" в уровень фактора.
datos_base <- read.csv(
  "train Space Titanic.csv",
  na.strings = c("", "NA"),
  stringsAsFactors = TRUE
)

# 2. Удаляем неинформативные идентификаторы (в стиле примеров по Titanic через = NULL):
# - PassengerId — уникальный идентификатор пассажира, не дающий обобщения.
# - Name — имя пассажира (удаляем до na.omit(), чтобы не терять строки, где
#   отсутствовало только имя).
datos_base$PassengerId <- NULL
datos_base$Name <- NULL

# 3. Удаляем наблюдения с пропущенными значениями (na.omit).
datos_base <- na.omit(datos_base)

# 4. Разбиение одного составного атрибута на несколько («Y al contrario»):
# Атрибут Cabin имеет формат "Deck/Num/Side" (например, "B/0/P"). Имеет смысл разбить его 
# на три разных атрибута: Deck, Num и Side так как все три могут иметь разное влияние на выживаемость
# Насколько я помню, Deck был одним из решающих факторов в оригинальном Титанике, так что выделить его в отдельный параметр исключительно важно.
partes_cabin <- strsplit(as.character(datos_base$Cabin), "/")
datos_base$CabinDeck <- as.factor(sapply(partes_cabin, "[", 1))
datos_base$CabinNum  <- as.numeric(sapply(partes_cabin, "[", 2))
datos_base$CabinSide <- as.factor(sapply(partes_cabin, "[", 3))
datos_base$Cabin <- NULL

# Целевая переменная обязательно должна быть фактором; очищаем неиспользуемые уровни
datos_base$Transported <- as.factor(datos_base$Transported)
datos_base <- droplevels(datos_base)

# Что до склейки атрибутов, очевидным кандидатом тут являются траты.
# Однако не столь очевидно, действительно ли их можно просто суммировать в однин атрибут
# или же структура трат (люкс-услуги против обычных трат) влияет на выхиваемость.
# Я решил сделать три варианта дата сета и посмотреть какой сработает лучше:

# Вариант 1: не сворачиваем расходы (оставляем все 5 исходных колонок)
datos_v1 <- datos_base

# Вариант 2 (компромисс): делим расходы на 2 смысловые группы — люкс и базовые
datos_v2 <- datos_base
datos_v2$GastosLujo    <- datos_v2$RoomService + datos_v2$Spa + datos_v2$VRDeck
datos_v2$GastosBasicos <- datos_v2$FoodCourt + datos_v2$ShoppingMall
datos_v2$RoomService  <- NULL
datos_v2$FoodCourt    <- NULL
datos_v2$ShoppingMall <- NULL
datos_v2$Spa          <- NULL
datos_v2$VRDeck       <- NULL

# Вариант 3: сворачиваем все 5 расходов в одну общую сумму GastosTotales
datos_v3 <- datos_base
datos_v3$GastosTotales <- datos_v3$RoomService + datos_v3$FoodCourt +
  datos_v3$ShoppingMall + datos_v3$Spa + datos_v3$VRDeck
datos_v3$RoomService  <- NULL
datos_v3$FoodCourt    <- NULL
datos_v3$ShoppingMall <- NULL
datos_v3$Spa          <- NULL
datos_v3$VRDeck       <- NULL

# Чтобы было прощк сравнивать, запишем три датасета в список
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

# 6. Единое разбиение 80% / 20% для всех 3 вариантов,
# чтобы модели сравнивались строго на одних и тех же обучающих и тестовых пассажирах.
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
# APARTADO 2. Random Forest с ntry=4 (mtry=4) и 50 деревьями для всех 3 вариантов 
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

# Определяем лучший вариант по итогам Apartado 2 и строим график важности для него
mejor_var_p2 <- names(which.max(acc_rf))
cat("\nMejor variante en Apartado 2 (RF):", mejor_var_p2,
    "| Accuracy:", round(acc_rf[mejor_var_p2], 5), "\n")
varImpPlot(lista_rf[[mejor_var_p2]], main = paste("Importancia RF -", mejor_var_p2))

t_p2_fin <- Sys.time()
cat("Tiempo Apartado 2 (seg):", round(as.numeric(difftime(t_p2_fin, t_p2_ini, units = "secs")), 2), "\n")


# ==============================================================================
# APARTADO 3. Random Forest без переменной с наименьшим весом
# Выполняется только для варианта с лучшим accuracy в Apartado 2.
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

# Комментарий по выбору модели (Apartado 3):
# Удаление переменной с минимальным весом (VIP) практически не ухудшает качество модели
# (а на части разбиений слегка его улучшает), при этом модель становится проще и содержит
# меньше шумовых признаков. По принципу простоты (парсимонии) предпочтительнее rf2.

t_p3_fin <- Sys.time()
cat("Tiempo Apartado 3 (seg):", round(as.numeric(difftime(t_p3_fin, t_p3_ini, units = "secs")), 2), "\n")


# ==============================================================================
# APARTADO 4. AdaBoost.M1 со схожими характеристиками деревьев для всех 3 вариантов (2 балла)
# ==============================================================================
# Используем mfinal = 50 (50 деревьев, как в п. 2, и 50 весов alpha для п. 5)
# и control = rpart.control(cp = 0.001, minsplit = 7) (многоуровневые деревья, как в Titanic_Bagging_adabag).
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
# APARTADO 5. Ансамбль в философии AdaBoost.M1 из 50 SVM (RBF, kernlab)
# В целях экономии времени выполнения здесь запускается только вариант-победитель
# (v1_5gastos), хотя предварительно были протестированы все три варианта:
#   - v1_5gastos: Accuracy = 0.81818 (C = 5, sigma = 0.1) — лучший результат
#   - v2_2grupos: Accuracy = 0.81523 (C = 5, sigma = 0.1)
#   - v3_1suma:   Accuracy = 0.72727 (C = 0.1, sigma = 0.05)
# Веса alpha берутся напрямую из соответствующей модели AdaBoost.M1 (п. 4).
# ==============================================================================
t_p5_ini <- Sys.time()

acc_svm <- rep(NA_real_, length(nombres_var))
names(acc_svm) <- nombres_var

# Выбираем вариант-победитель по итогам п. 2 (RF) и п. 4 (AdaBoost.M1) — v1_5gastos
v <- names(which.max((acc_rf + acc_ada) / 2))

cat("\n==================== APARTADO 5: ENSEMBLE 50 SVM (RBF, kernlab) ====================\n")
cat("Variante ejecutada en Apartado 5 (ganadora previa, por ahorro de tiempo):", v, "\n")

alpha <- lista_alpha[[v]]

# Бинаризация целевой переменной в "-1" и "1" (как в Iris_AdaBoost_M1_con_SVM/solution.R)
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

# Подбор параметров RBF-ядра (cost -> C, gamma -> sigma) через e1071::tune()
# на случайной подвыборке 1000 наблюдений с 3-фолдовой кросс-валидацией
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

# Обучение 50 машин SVM (kernlab::ksvm) на случайных 80% подвыборках из dtrain_svm
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

# Предсказания 50 SVM на всей тестовой выборке dtest_svm
listaSVMPredicciones <- list()
for (i in 1:numeroSVM) {
  prediccionSVM <- predict(listaSVM[[i]], dtest_svm)
  listaSVMPredicciones[[i]] <- prediccionSVM
}

matrizPrediccionesSVM <- sapply(listaSVMPredicciones, function(x) {
  as.numeric(as.character(x))
})

# Взвешенное мажоритарное голосование (Weighted Majority Voting) с весами alpha из п. 4
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
# ИТОГОВОЕ СРАВНЕНИЕ ВСЕХ 3 ВАРИАНТОВ И ВЫБОР ПОБЕДИТЕЛЯ
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

# Итоговый вывод по сравнению 3 вариантов:
# - Победитель по всем трём основным моделям — v1_5gastos (5 отдельных столбцов расходов):
#   RF = 0.81301 (без VIP = 0.81670), AdaBoost.M1 = 0.81301, Ensemble 50 SVM = 0.81818.
# - Компромиссный вариант v2_2grupos (GastosLujo + GastosBasicos) близок по точности
#   (RF = 0.80710, AdaBoost = 0.79823, предварительно проверенный SVM = 0.81523), но чуть уступает.
# - Полная свёртка в одну сумму v3_1suma (GastosTotales) резко ухудшает качество на 6.5–9%
#   (RF = 0.74723, AdaBoost = 0.74723, предварительно проверенный SVM = 0.72727),
#   подтверждая, что структура расходов критична.
