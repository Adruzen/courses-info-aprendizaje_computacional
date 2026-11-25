# ==============================================================================
# УСРЕДНЁННЫЙ ШАБЛОН ПРОФЕССОРА: BOOSTING (ADABOOST.M1, SVM+ALPHA, GBM, CARET)
# ==============================================================================
# Назначение: типовое решение задач на Boosting в стиле преподавателя (UMA).
# Источники стиля: Adaboost.M1.R, Boosting-Titanic.R, calidad vinos.R,
#                  Adaboost.M1 con SVM.R, Solucion del profe.R, boosting.R.
# ==============================================================================

# ------------------------------------------------------------------------------
# ВАРИАНТ 1. КЛАССИЧЕСКИЙ ADABOOST.M1 ЧЕРЕЗ adabag::boosting (основной шаблон)
# ------------------------------------------------------------------------------
library(adabag)
library(caret)
library(rpart)
library(rpart.plot)
library(ggplot2)

# Предположим, датасет лежит в train.csv
datos <- read.csv("train.csv", stringsAsFactors = TRUE)
datos <- na.omit(datos)
datos$Clase <- as.factor(datos$Clase)

# Вариант А разбиения (как в Adaboost.M1.R): стратифицированное через caret
set.seed(123)
indice <- createDataPartition(datos$Clase, p = 0.80, list = FALSE)
dtrain <- datos[indice, ]
dtest  <- datos[-indice, ]

# Вариант Б разбиения (как в Boosting-Titanic.R и calidad vinos.R): через sample
# set.seed(200)
# d_size <- dim(datos)[1]
# dtest_size <- ceiling(0.2 * d_size)
# samples <- sample(d_size, d_size, replace = FALSE)
# indexes <- samples[1:dtest_size]
# dtrain <- datos[-indexes, ]
# dtest  <- datos[indexes, ]

# Обучение AdaBoost.M1
# mfinal = 10 или 100 (число слабых классификаторов);
# control = rpart.control(maxdepth = 1, minsplit = 2, cp = 0) — решающие пни (stumps)!
set.seed(123)
modelo_adaboost <- boosting(
  Clase ~ .,
  data = dtrain,
  boos = TRUE,
  mfinal = 100,       # На экзамене иногда просят mfinal = 10
  coeflearn = "Breiman",
  control = rpart.control(
    maxdepth = 1,
    minsplit = 2,
    cp = 0
  )
)

# Инспекция обученного ансамбля (часто просят на экзаменах!)
print(modelo_adaboost)
modelo_adaboost$weights      # Веса моделей / наблюдений
modelo_adaboost$importance   # Важность признаков в бустинге
errorevol(modelo_adaboost, dtrain) # Эволюция ошибки по итерациям

# Извлечение и отрисовка одного из деревьев (например, первого: trees[[1]])
tree1 <- modelo_adaboost$trees[[1]]
rpart.plot(tree1)

# Предсказание на тестовой выборке
predicciones <- predict(modelo_adaboost, newdata = dtest)
# Приводим уровни к test$Clase (защита от несовпадения уровней, как в calidad vinos.R)
clases_predichas <- factor(predicciones$class, levels = levels(dtest$Clase))

# Матрица ошибок и Accuracy (через caret или вручную через table)
matriz <- confusionMatrix(data = clases_predichas, reference = dtest$Clase)
print(matriz)
accuracy <- matriz$overall["Accuracy"]
cat("Accuracy:", round(accuracy, 4), "\n")

# Ручной расчёт (альтернативный стиль из Boosting-Titanic.R / calidad vinos.R):
# MC <- table(dtest$Clase, clases_predichas)
# accuracy <- sum(diag(MC)) / sum(MC)


# ------------------------------------------------------------------------------
# ВАРИАНТ 2. РУЧНОЙ ADABOOST.M1 С 10 СЛАБЫМИ SVM И ВЕСАМИ alpha (экзамен 2025-12-01)
# ------------------------------------------------------------------------------
library(kernlab)

# Предположим, заданы предвычисленные веса alpha и тестовые точки test1, test2
# load("alpha y test de Problema 2")

datos_bin <- datos
# Бинаризация целевого класса в "-1" и "1" (в задаче iris: virginica = -1, versicolor = 1)
# datos_bin <- subset(datos, Clase %in% c("ClasePos", "ClaseNeg"))
datos_bin$Clase <- ifelse(datos_bin$Clase == "ClasePos", "1", "-1")
datos_bin$Clase <- as.factor(datos_bin$Clase)

set.seed(123)
n <- nrow(datos_bin)
porcentaje <- 0.9
indicesTotales <- sample(1:n, size = round(n * porcentaje))
train <- datos_bin[indicesTotales, ]
test  <- datos_bin[-indicesTotales, ]

# Обучаем 10 линейных SVM с низким C = 0.1 на разных 80% подвыборках из train
listaSVM <- list()
for (i in 1:10) {
  n_tr <- nrow(train)
  porcentaje_svm <- 0.8
  indicesSVM <- sample(1:n_tr, size = round(n_tr * porcentaje_svm))
  trainSVM <- train[indicesSVM, ]

  modeloSvm <- ksvm(
    Clase ~ .,
    data = trainSVM,
    kernel = "vanilladot",
    C = 0.1
  )
  listaSVM[[i]] <- modeloSvm
}

# Предсказание всеми 10 SVM для конкретного тестового объекта (например, test[1, ] или test1)
listaSVMPredicciones <- list()
for (i in 1:10) {
  prediccionSVM <- predict(listaSVM[[i]], test[1, ])
  listaSVMPredicciones[[i]] <- prediccionSVM
}

# Перевод факторов "-1"/"1" в числа и итоговое взвешенное голосование sign(sum(pred * alpha))
predicciones_num <- sapply(listaSVMPredicciones, function(x) {
  as.numeric(as.character(x))
})
resultado <- predicciones_num * alpha
print(sign(sum(resultado)))


# ------------------------------------------------------------------------------
# ВАРИАНТ 3. GRADIENT BOOSTING (пакет gbm, регрессия / бинарная классификация)
# ------------------------------------------------------------------------------
library(gbm)
library(caret)

# Предположим, решаем задачу регрессии для числовой цели Objetivo
set.seed(123)
indice <- createDataPartition(datos$Objetivo, p = 0.80, list = FALSE)
train <- datos[indice, ]
test  <- datos[-indice, ]

modelo_gbm <- gbm(
  Objetivo ~ .,
  data = train,
  distribution = "gaussian", # Для бинарной 0/1 классификации: "bernoulli"
  n.trees = 2000,
  interaction.depth = 3,
  shrinkage = 0.01,
  n.minobsinnode = 3,
  cv.folds = 5,
  verbose = FALSE
)

# Поиск оптимального числа деревьев по кросс-валидации
arboles_optimos <- gbm.perf(modelo_gbm, method = "cv", plot.it = TRUE)
predicciones <- predict(modelo_gbm, newdata = test, n.trees = arboles_optimos)

rmse <- sqrt(mean((test$Objetivo - predicciones)^2))
mae  <- mean(abs(test$Objetivo - predicciones))
r2   <- 1 - sum((test$Objetivo - predicciones)^2) / sum((test$Objetivo - mean(test$Objetivo))^2)

summary(modelo_gbm, n.trees = arboles_optimos) # Важность переменных в gbm


# ------------------------------------------------------------------------------
# ВАРИАНТ 4. BOOSTING ЧЕРЕЗ caret (C5.0 и gbm)
# ------------------------------------------------------------------------------
library(caret)

control <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
seed <- 7
metric <- "Accuracy"

set.seed(seed)
fit.c50 <- train(Clase ~ ., data = datos, method = "C5.0", metric = metric, trControl = control)
set.seed(seed)
fit.gbm <- train(Clase ~ ., data = datos, method = "gbm", metric = metric, trControl = control, verbose = FALSE)

boosting_results <- resamples(list(c5.0 = fit.c50, gbm = fit.gbm))
summary(boosting_results)
dotplot(boosting_results)
