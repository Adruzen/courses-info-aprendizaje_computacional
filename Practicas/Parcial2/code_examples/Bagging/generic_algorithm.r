# ==============================================================================
# УСРЕДНЁННЫЙ ШАБЛОН ПРОФЕССОРА: BAGGING (БЭГГИНГ)
# ==============================================================================
# Назначение: типовое решение задач на Bagging (классификация, регрессия, caret)
# в стиле кода преподавателя (Aprendizaje Computacional, UMA).
# Источники стиля: Bagging - Titanic.R, Bagging.R, Bagging Boosting con Caret.R.
# ==============================================================================

# ------------------------------------------------------------------------------
# ВАРИАНТ 1. КЛАССИФИКАЦИЯ ЧЕРЕЗ adabag::bagging (классический стиль профессора)
# ------------------------------------------------------------------------------
library(adabag)
library(rpart)

# Предположим, датасет лежит в train.csv (разделитель "," или ";", при необходимости sep=";")
datos <- read.csv("train.csv", header = TRUE, quote = "\"", stringsAsFactors = TRUE)

# Предобработка: удаление ненужных ID/строковых столбцов и пропусков (при необходимости)
# datos$PassengerId <- NULL
# datos$Name <- NULL
datos <- na.omit(datos)

# Целевая переменная для классификации обязательно должна быть factor!
datos$Clase <- as.factor(datos$Clase)

# Разбиение на обучение (80%) и тест (20%) — фирменная схема профессора
set.seed(200)
dsize <- dim(datos)[1]
dt_size <- ceiling(0.2 * dsize)
samples <- sample(dsize, dsize, replace = FALSE)
indexes <- samples[1:dt_size]

dtrain <- datos[-indexes, ]
dtest  <- datos[indexes, ]

Training <- dtrain
Training$Clase <- factor(Training$Clase)
Test <- dtest

# Обучение ансамбля Bagging на деревьях rpart
# mfinal — число бутстрэп-деревьев; control задаёт параметры базовых деревьев rpart
set.seed(110)
Modelo_AdaBag <- bagging(
  formula = Clase ~ .,
  data = Training,
  na.action = na.omit,
  mfinal = 10,
  control = rpart.control(cp = 0.001, minsplit = 7)
)

# Предсказание на тестовой выборке ($class возвращает вектор предсказанных классов)
Forecast <- predict(Modelo_AdaBag, Test, type = "class")$class

# Матрица ошибок, True Positive (для бинарной задачи) и Accuracy
MC <- table(Test[, "Clase"], Forecast)
MC
# TruePos <- MC[1, 2] / (MC[1, 1] + MC[1, 2]); TruePos
Scores <- sum(diag(MC))
Accuracy <- Scores / sum(MC)
Accuracy


# ------------------------------------------------------------------------------
# ВАРИАНТ 2. РЕГРЕССИЯ ЧЕРЕЗ ipred::bagging (шаблон с занятия)
# ------------------------------------------------------------------------------
library(ipred)
library(caret)
library(ggplot2)
library(rpart)

# Предположим, данные загружены и целевая переменная — числовая (Objetivo)
# datos <- read.csv("datos_regresion.csv")
set.seed(123)
indice <- createDataPartition(datos$Objetivo, p = 0.80, list = FALSE)
train <- datos[indice, ]
test  <- datos[-indice, ]

# Обучение модели Bagging для регрессии (nbagg = число бутстрэп-выборок, coob = OOB-оценка)
set.seed(123)
modelo_bagging <- bagging(
  Objetivo ~ .,
  data = train,
  nbagg = 500,
  coob = TRUE,
  control = rpart.control(minsplit = 3, cp = 0)
)

print(modelo_bagging)

# Предсказание и метрики качества регрессии (RMSE, MAE, R2)
predicciones <- predict(modelo_bagging, newdata = test)

rmse <- sqrt(mean((test$Objetivo - predicciones)^2))
mae  <- mean(abs(test$Objetivo - predicciones))
r2   <- 1 - sum((test$Objetivo - predicciones)^2) / sum((test$Objetivo - mean(test$Objetivo))^2)

cat("\nRESULTADOS DEL MODELO BAGGING\n")
cat("RMSE:", round(rmse, 4), "\n")
cat("MAE:", round(mae, 4), "\n")
cat("R2:", round(r2, 4), "\n")

resultados <- data.frame(Real = test$Objetivo, Predicho = predicciones)
print(resultados)

ggplot(resultados, aes(x = Real, y = Predicho)) +
  geom_point(color = "darkgreen", size = 3) +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(title = "Modelo Bagging", x = "Valores reales", y = "Valores predichos") +
  theme_minimal()


# ------------------------------------------------------------------------------
# ВАРИАНТ 3. BAGGING ЧЕРЕЗ caret (Bagged CART — "treebag")
# ------------------------------------------------------------------------------
library(caret)

# Повторная 10-блочная кросс-валидация (повторить 3 раза)
control <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
seed <- 7
metric <- "Accuracy"

set.seed(seed)
fit.treebag <- train(Clase ~ ., data = datos, method = "treebag", metric = metric, trControl = control)
print(fit.treebag)
