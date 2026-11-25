# ==============================================================================
# УСРЕДНЁННЫЙ ШАБЛОН ПРОФЕССОРА: RANDOM FOREST (СЛУЧАЙНЫЕ ЛЕСА)
# ==============================================================================
# Назначение: основной экзаменационный шаблон по Random Forest в стиле профессора
# (UMA), включая оценку важности переменных, отбор признаков, margin и симуляцию.
# Источники стиля: url maliciosa.R, kyphosys con Random forest.R, titanic con RF.r,
#                  calidad vinos.R, Simular RF con RPART.R, Rdatamining.pdf (§4.3).
# ==============================================================================

# ------------------------------------------------------------------------------
# ВАРИАНТ 1. СТАНДАРТНЫЙ RANDOM FOREST (пакет randomForest — главный шаблон)
# ------------------------------------------------------------------------------
library(randomForest)
# library(rpart) # Если берём встроенный датасет kyphosis

# Предположим, датасет лежит в train.csv (при ";" добавить sep = ";")
datos <- read.csv("train.csv", stringsAsFactors = TRUE)

# Предобработка: удаление лишних столбцов (ID, имена и т.п.) и NA
# datos$PassengerId <- NULL
# datos$Name <- NULL
datos <- na.omit(datos)

# Для классификации целевой атрибут обязательно преобразуем в factor!
datos$Clase <- as.factor(datos$Clase)

# Разбиение на обучающую (80%) и тестовую (20%) выборки
# Способ А (самый частый у профессора в RF — через sample(2, ...)):
set.seed(1234)
ind <- sample(2, nrow(datos), replace = TRUE, prob = c(0.8, 0.2))
trainData <- datos[ind == 1, ]
testData  <- datos[ind == 2, ]

# Способ Б (как в calidad vinos.R и titanic con RF.r):
# set.seed(200)
# d_size <- dim(datos)[1]
# dtest_size <- ceiling(0.2 * d_size)
# samples <- sample(d_size, d_size, replace = FALSE)
# indexes <- samples[1:dtest_size]
# dtrain <- datos[-indexes, ]
# dtest  <- datos[indexes, ]

# Обучение Random Forest
# ntree — число деревьев; mtry — число признаков на разбиение (по умолчанию ~sqrt(p))
# importance = TRUE нужно, если потом вызывать importance(rf, type = 1)
rf <- randomForest(
  Clase ~ .,
  data = trainData,
  ntree = 100,
  # mtry = 2,
  proximity = TRUE,
  importance = TRUE
)

# Просмотр сводки (OOB estimate of error rate + Confusion matrix) и графика ошибки
print(rf)
plot(rf)

# Предсказание на тестовой выборке, матрица ошибок и Accuracy
prediccion <- predict(rf, newdata = testData)
matrizconfusion <- table(prediccion, testData$Clase)
matrizconfusion

accuracy <- sum(diag(matrizconfusion)) / sum(matrizconfusion)
accuracy

# Анализ важности признаков (очень частый вопрос на экзамене!)
# Чем выше MeanDecreaseGini (или %IncMSE / type = 1), тем сильнее переменная
# снижает неоднородность (влияет на разделение классов)
imp <- importance(rf)
print(imp)
# importance(rf, type = 1) # Точность по перестановкам (Permutation importance)
varImpPlot(rf)

# Отбор только самых важных признаков (например, MeanDecreaseGini > 7, как в DDoS 2024)
# vars_importantes <- rownames(imp)[imp[, "MeanDecreaseGini"] > 7]
# formula_filtrada <- as.formula(paste("Clase ~", paste(vars_importantes, collapse = " + ")))
# rf_filtrado <- randomForest(formula_filtrada, data = trainData, ntree = 100, proximity = TRUE)

# График запаса уверенности (margin) из Rdatamining.pdf
# Положительный margin = верная классификация, отрицательный = ошибка
plot(margin(rf, testData$Clase))


# ------------------------------------------------------------------------------
# ВАРИАНТ 2. РУЧНАЯ СИМУЛЯЦИЯ RANDOM FOREST НА ОСНОВЕ rpart
# (педагогический код профессора из Simular RF con RPART.R)
# ------------------------------------------------------------------------------
library(rpart)

datos_rf <- na.omit(datos)
datos_rf$Clase <- as.factor(datos_rf$Clase)

# Список доступных признаков (без целевой колонки Clase)
datos_vars <- datos_rf
datos_vars$Clase <- NULL
atributos <- names(datos_vars)

# Число случайных признаков на каждое дерево: около sqrt(p)
numerovariables <- round(sqrt(length(atributos)))

set.seed(44664575)
numeroArboles <- 10
accuracy_vec <- c()

# Фиксированная тестовая выборка (20%)
d_size <- dim(datos_rf)[1]
dtest_size <- ceiling(0.2 * d_size)
samples <- sample(d_size, d_size, replace = FALSE)
indexes <- samples[1:dtest_size]
datos_train_pool <- datos_rf[-indexes, ]
dtest <- datos_rf[indexes, ]

for (i in 1:numeroArboles) {
  # Случайный выбор подмножества признаков (Feature Sampling)
  atributosparaentrenar <- sample(1:length(atributos), size = numerovariables, replace = FALSE)
  formula_str <- paste("Clase ~", paste(atributos[atributosparaentrenar], collapse = " + "))
  print(i)
  print(formula_str)

  # Случайная подвыборка объектов из обучающего пула
  pool_size <- dim(datos_train_pool)[1]
  sub_size <- ceiling(0.2 * pool_size)
  sub_idx <- sample(pool_size, pool_size, replace = FALSE)[1:sub_size]
  dtrain_i <- datos_train_pool[-sub_idx, ]

  arbolrpart <- rpart(as.formula(formula_str), data = dtrain_i)
  pred_i <- predict(arbolrpart, dtest, type = "class")
  mc_i <- table(pred_i, dtest$Clase)
  accuracy_vec[i] <- sum(diag(mc_i)) / sum(mc_i)
}

max(accuracy_vec)
min(accuracy_vec)
mean(accuracy_vec)


# ------------------------------------------------------------------------------
# ВАРИАНТ 3. RANDOM FOREST ЧЕРЕЗ caret (method = "rf")
# ------------------------------------------------------------------------------
library(caret)

control <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
seed <- 7
metric <- "Accuracy"

set.seed(seed)
fit.rf <- train(Clase ~ ., data = datos, method = "rf", metric = metric, trControl = control)
print(fit.rf)
