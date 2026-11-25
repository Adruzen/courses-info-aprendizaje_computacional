# ==============================================================================
# УСРЕДНЁННЫЙ ШАБЛОН ПРОФЕССОРА: STACKING (СТЕКИНГ / МЕТА-ОБУЧЕНИЕ)
# ==============================================================================
# Назначение: типовые способы реализации Stacking в стиле преподавателя (UMA):
# 1) Ручной двухуровневый Stacking (как в Stacking con SVM.R и Stacking rpart y Svm)
# 2) Stacking через caretEnsemble (caretList + caretStack)
# 3) Stacking простым голосованием разнородных моделей без весов (для экзаменов)
# ==============================================================================

# ------------------------------------------------------------------------------
# ВАРИАНТ 1. РУЧНОЙ ДВУХУРОВНЕВЫЙ STACKING (фирменный приём профессора)
# ------------------------------------------------------------------------------
library(rpart)
library(nnet)
library(e1071)

# Предположим, датасет лежит в train.csv (или используется встроенный iris)
datos <- read.csv("train.csv", stringsAsFactors = TRUE)
datos <- na.omit(datos)
datos$Clase <- as.factor(datos$Clase)

# Разбиение на dtrain и dtest
set.seed(200)
d_size <- dim(datos)[1]
dtest_size <- ceiling(0.2 * d_size)
samples <- sample(d_size, d_size, replace = FALSE)
indexes <- samples[1:dtest_size]

dtrain <- datos[-indexes, ]
dtest  <- datos[indexes, ]

# УРОВЕНЬ 0 (базовые разнородные модели на dtrain)
perceptron <- nnet(Clase ~ ., data = dtrain, size = 2, trace = FALSE)
arbol      <- rpart(Clase ~ ., data = dtrain)
# При желании можно заменить/добавить svm:
# svm_base <- svm(Clase ~ ., data = dtrain)

# Предсказания базовых моделей на dtest
pper <- predict(perceptron, dtest, type = "class")
par  <- predict(arbol, dtest, type = "class")

# Подготовка обучающей таблицы для УРОВНЯ 1 (стиль из Stacking con SVM.R):
# Профессор дублирует признаки dtest (без истинной цели) и подставляет предсказания
# базовых моделей в качестве столбца Clase для мета-классификатора!
# (Примечание: в идеале по теории мета-признаками должны быть сами предсказания
#  моделей уровня 0, полученные через внутреннюю кросс-валидацию.)
dtestM <- dtest
dtestM$Clase <- NULL
entrada2Capa <- rbind(dtestM, dtestM)
entrada2Capa <- data.frame(
  entrada2Capa,
  Clase = as.factor(c(as.character(par), as.character(pper)))
)

# УРОВЕНЬ 1 (мета-модель поверх входных данных с ответами уровня 0)
# Можно обучить svm (как в Stacking con SVM.R) или rpart (как в Stacking rpart y Svm)
fitSVM_meta <- svm(Clase ~ ., data = entrada2Capa)
# fitRpart_meta <- rpart(Clase ~ ., data = entrada2Capa, control = rpart.control(minbucket = 5))

# Предсказание и оценка Accuracy итогового стекинга
prediccionGlobal <- predict(fitSVM_meta, dtest, type = "class")
matrizconfusion  <- table(prediccionGlobal, dtest$Clase)
matrizconfusion

accuracy <- sum(diag(matrizconfusion)) / sum(matrizconfusion)
accuracy


# ------------------------------------------------------------------------------
# ВАРИАНТ 2. STACKING ЧЕРЕЗ caretEnsemble (caretList + caretStack)
# ------------------------------------------------------------------------------
library(caret)
library(caretEnsemble)
library(rpart)
library(nnet)
library(e1071)

set.seed(7)
ind <- sample(nrow(datos), nrow(datos))
idt <- ind[1:ceiling(0.2 * nrow(datos))]
dtrain <- datos[-idt, ]
dtest  <- datos[idt, ]

dtrain$Clase <- as.factor(dtrain$Clase)
dtest$Clase  <- as.factor(dtest$Clase)

# Важно: для caretList обязательно savePredictions = "final" и classProbs = TRUE
control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  savePredictions = "final",
  classProbs = TRUE
)

algorithmList <- c("nnet", "svmRadial") # Можно добавить "rpart", "rf", "gbm" и др.
models <- caretList(
  Clase ~ .,
  data = dtrain,
  trControl = control,
  methodList = algorithmList,
  tuneList = NULL
)

results <- resamples(models)
summary(results)
dotplot(results)

# Мета-модель (уровень 1): например, "svmRadial" или "glm"
stackControl <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  savePredictions = "final",
  classProbs = TRUE
)

stackingSVM <- caretStack(models, method = "svmRadial", trControl = stackControl)
print(stackingSVM)

pred <- predict(stackingSVM, newdata = dtest)
accuracy_caret <- mean(pred == dtest$Clase)
cat("Accuracy del modelo en test:", accuracy_caret, "\n")
print(confusionMatrix(pred, dtest$Clase))


# ------------------------------------------------------------------------------
# ВАРИАНТ 3. СТЕКИНГ ПО ПРОСТОМУ ГОЛОСОВАНИЮ БЕЗ ВЕСОВ (экзамен 2020-09-21 / 2018-01-23)
# "Crea un stacking (por votación y sin pesos) con los clasificadores pobres..."
# ------------------------------------------------------------------------------
m_rpart <- rpart(Clase ~ ., data = dtrain)
m_nnet  <- nnet(Clase ~ ., data = dtrain, size = 5, trace = FALSE)
m_svm   <- svm(Clase ~ ., data = dtrain)

p1 <- as.character(predict(m_rpart, dtest, type = "class"))
p2 <- as.character(predict(m_nnet, dtest, type = "class"))
p3 <- as.character(predict(m_svm, dtest, type = "class"))

# Построчное голосование большинством среди 3 разных классификаторов
pred_voto <- sapply(1:nrow(dtest), function(i) {
  votos <- c(p1[i], p2[i], p3[i])
  names(which.max(table(votos)))
})

MC_voto <- table(pred_voto, dtest$Clase)
accuracy_voto <- sum(diag(MC_voto)) / sum(MC_voto)
accuracy_voto
