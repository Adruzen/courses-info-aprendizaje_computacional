# ==============================================================================
# УСРЕДНЁННЫЙ ШАБЛОН ПРОФЕССОРА: РУЧНОЙ АНСАМБЛЬ С ГОЛОСОВАНИЕМ (ENSEMBLE MANUAL)
# ==============================================================================
# Назначение: решение задач экзаменов 2018-01-24, 2015-01-22, 2022-01-19,
# 2022-02-03, 2025-12-01, где нужно вручную обучить список (list) моделей
# (nnet, rpart или svm) на случайных подвыборках / разных признаках и
# объединить их простым голосованием большинством.
# Источники стиля: ensemblePerceptron.R и Sugerencia из экзаменов 2018-01-24 / 2015-01-22.
# ==============================================================================

# ------------------------------------------------------------------------------
# ВАРИАНТ 1. ЦИКЛ ИЗ K МОДЕЛЕЙ НА СЛУЧАЙНЫХ ПОДВЫБОРКАХ + ГОЛОСОВАНИЕ
# (как в ensemblePerceptron.R и задаче про recidiva / datos_icb.txt)
# ------------------------------------------------------------------------------
library(nnet)
library(rpart)
library(e1071)

# Предположим, датасет лежит в train.csv (или datos_icb.txt с sep = "")
datos <- read.csv("train.csv", stringsAsFactors = TRUE)
datos <- na.omit(datos)
datos$Clase <- as.factor(datos$Clase)

# Разбиение на обучающий пул (90%) и тестовую выборку (10%)
set.seed(123)
n <- nrow(datos)
ind <- sample(n, n)
dt_size <- ceiling(0.1 * n)
idt <- ind[1:dt_size]

dtrain <- datos[-idt, ]
dtest  <- datos[idt, ]

# Список для хранения обученных слабых классификаторов (как w <- c(lista1, lista2) в подсказке)
numeroModelos <- 10
listamodelos <- list()

for (i in 1:numeroModelos) {
  # Случайная подвыборка из dtrain (например, 75% или 80% объектов)
  n_tr <- nrow(dtrain)
  indices_sub <- sample(1:n_tr, size = round(0.75 * n_tr), replace = FALSE)
  dtrain_i <- dtrain[indices_sub, ]

  # Вариант А: слабый классификатор — перцептрон nnet (подбираем size)
  modelo_i <- nnet(Clase ~ ., data = dtrain_i, size = 5, maxit = 500, decay = 1, trace = FALSE)

  # Вариант Б: слабый классификатор — дерево решений rpart (как в п. b) экзамена 2018-01-24)
  # modelo_i <- rpart(Clase ~ ., data = dtrain_i, minbucket = 1, minsplit = 2)

  listamodelos[[i]] <- modelo_i
}

# Примечание: в оригинале профессора (ensemblePerceptron.R) был цикл 1:numeroPerceptrones-1
# (что в R даёт 0:9) и подсчёт голосов суммой по всему вектору dtest сразу.
# Ниже — корректное построчное голосование большинством для каждого объекта dtest:
matriz_preds <- sapply(1:numeroModelos, function(i) {
  as.character(predict(listamodelos[[i]], dtest, type = "class"))
})

# Для каждой строки тестовой выборки выбираем класс с максимальным числом голосов
pred_final <- apply(matriz_preds, 1, function(votos_fila) {
  names(which.max(table(votos_fila)))
})
pred_final <- factor(pred_final, levels = levels(dtest$Clase))

matrizconfusion <- table(pred_final, dtest$Clase)
matrizconfusion
accuracy <- sum(diag(matrizconfusion)) / sum(matrizconfusion)
accuracy


# ------------------------------------------------------------------------------
# ВАРИАНТ 2. ФИКСИРОВАННЫЙ АНСАМБЛЬ ИЗ 2–3 МОДЕЛЕЙ НА РАЗНЫХ ПАРАХ ПРИЗНАКОВ
# (типичная задача по датасету Kyphosis в экзаменах 2025-12-01, 2022-02-03, 2022-01-19)
# ------------------------------------------------------------------------------
library(rpart)
library(nnet)
library(e1071)
library(randomForest)

# Предположим, у нас датасет (например, kyphosis) с признаками Atr1, Atr2, Atr3 и целью Clase
# data(kyphosis)
set.seed(123)
n_total <- nrow(datos)
idx_test <- sample(1:n_total, size = round(0.2 * n_total))
pool_train <- datos[-idx_test, ]
dtest      <- datos[idx_test, ]

# Функция выборки случайных 75% (или 80%) из обучающего пула для каждой модели
sample_sub <- function(df, frac = 0.75) {
  idx <- sample(1:nrow(df), size = round(frac * nrow(df)), replace = FALSE)
  df[idx, ]
}

# Вариант с 3 перцептронами nnet (экзамен 2025-12-01, Проблема 1):
m1 <- nnet(Clase ~ Atr1 + Atr2, data = sample_sub(pool_train, 0.75), size = 5, maxit = 500, trace = FALSE)
m2 <- nnet(Clase ~ Atr1 + Atr3, data = sample_sub(pool_train, 0.75), size = 5, maxit = 500, trace = FALSE)
m3 <- nnet(Clase ~ Atr2 + Atr3, data = sample_sub(pool_train, 0.75), size = 5, maxit = 500, trace = FALSE)

# Вариант с 3 SVM с полиномиальным ядром (экзамен 2022-02-03, Упр. 4):
# m1 <- svm(Clase ~ Atr1 + Atr2, data = sample_sub(pool_train, 0.75), kernel = "polynomial")
# m2 <- svm(Clase ~ Atr1 + Atr3, data = sample_sub(pool_train, 0.75), kernel = "polynomial")
# m3 <- svm(Clase ~ Atr2 + Atr3, data = sample_sub(pool_train, 0.75), kernel = "polynomial")

# Вариант с 2 одноуровневыми деревьями rpart (экзамен 2022-01-19, Упр. 3):
# m1 <- rpart(Clase ~ Atr1 + Atr2, data = sample_sub(pool_train, 0.80), control = rpart.control(maxdepth = 1))
# m2 <- rpart(Clase ~ Atr1 + Atr3, data = sample_sub(pool_train, 0.80), control = rpart.control(maxdepth = 1))

# Голосование большинством
p1 <- as.character(predict(m1, dtest, type = "class"))
p2 <- as.character(predict(m2, dtest, type = "class"))
p3 <- as.character(predict(m3, dtest, type = "class"))

voto_ensamble <- sapply(1:nrow(dtest), function(j) {
  names(which.max(table(c(p1[j], p2[j], p3[j]))))
})

MC_ens <- table(voto_ensamble, dtest$Clase)
acc_ens <- sum(diag(MC_ens)) / sum(MC_ens)
cat("Accuracy ensemble:", acc_ens, "\n")

# Обязательное на экзамене сравнение с Random Forest (или AdaBoost)
rf_comp <- randomForest(Clase ~ ., data = pool_train, ntree = 100, proximity = TRUE)
MC_rf <- table(predict(rf_comp, newdata = dtest), dtest$Clase)
acc_rf <- sum(diag(MC_rf)) / sum(MC_rf)
cat("Accuracy Random Forest:", acc_rf, "\n")
importance(rf_comp)
