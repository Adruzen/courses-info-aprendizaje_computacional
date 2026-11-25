# ==============================================================================
# Тема 2 (Ансамбли): Ensemble из 3 перцептронов (nnet) vs Random Forest (kyphosis)
# Опора на code_examples:
#   - RandomForest/Kyphosis_RandomForest/solution.R
#   - Ensemble_Manual/Recidiva_Ensemble_Perceptron_Votacion/solution.R
# ==============================================================================

library(rpart)
library(nnet)
library(randomForest)
library(caret)

set.seed(123)
data(kyphosis)

# 1. Разбиение на обучающую и тестовую выборки (стратифицированно, 80% / 20%)
idx_train <- createDataPartition(kyphosis$Kyphosis, p = 0.80, list = FALSE)
train_data <- kyphosis[idx_train, ]
test_data  <- kyphosis[-idx_train, ]

# Стандартизация числовых признаков по обучающей выборке для стабильной работы nnet
num_cols <- c("Age", "Number", "Start")
prep <- preProcess(train_data[, num_cols], method = c("center", "scale"))
train_scaled <- train_data
test_scaled  <- test_data
train_scaled[, num_cols] <- predict(prep, train_data[, num_cols])
test_scaled[, num_cols]  <- predict(prep, test_data[, num_cols])

# 2. Подбор оптимального числа нейронов (size) через 5-фолдовую кросс-валидацию
cat("=== 1. Подбор числа нейронов (5-fold CV) ===\n")
formulas <- list(
  p1 = Kyphosis ~ Age + Number,
  p2 = Kyphosis ~ Age + Start,
  p3 = Kyphosis ~ Number + Start
)

ctrl <- trainControl(method = "cv", number = 5)
grid <- expand.grid(size = c(1, 2, 3, 5, 8, 10), decay = c(0.01, 0.1))

best_sizes <- numeric(length(formulas))
for (k in seq_along(formulas)) {
  fit_cv <- train(
    formulas[[k]],
    data = train_scaled,
    method = "nnet",
    trControl = ctrl,
    tuneGrid = grid,
    maxit = 500,
    trace = FALSE
  )
  best_sizes[k] <- fit_cv$bestTune$size
  cat(sprintf(
    "Перцептрон %d (%s): лучший size = %d, decay = %.2f, CV Accuracy = %.4f\n",
    k, deparse(formulas[[k]]), fit_cv$bestTune$size, fit_cv$bestTune$decay, max(fit_cv$results$Accuracy)
  ))
}

# 3. Обучение ансамбля из 3 перцептронов (по 75% случайных данных для каждого)
cat("\n=== 2. Обучение ансамбля из 3 перцептронов + голосование ===\n")
train_ensemble_nnet <- function(tr_data, sizes) {
  models <- vector("list", length(formulas))
  for (k in seq_along(formulas)) {
    sub_idx <- sample(seq_len(nrow(tr_data)), size = round(0.75 * nrow(tr_data)), replace = FALSE)
    sub_train <- tr_data[sub_idx, ]
    models[[k]] <- nnet(
      formulas[[k]],
      data = sub_train,
      size = sizes[k],
      decay = 0.1,
      maxit = 500,
      trace = FALSE
    )
  }
  models
}

predict_ensemble_vote <- function(models, newdata) {
  preds <- sapply(models, function(m) as.character(predict(m, newdata = newdata, type = "class")))
  # Голосование большинством (порог >= 2 из 3 для класса "present")
  votes_present <- rowSums(preds == "present")
  factor(ifelse(votes_present >= 2, "present", "absent"), levels = c("absent", "present"))
}

ens_models <- train_ensemble_nnet(train_scaled, best_sizes)
ens_pred <- predict_ensemble_vote(ens_models, test_scaled)

cm_ens <- table(Predicted = ens_pred, Actual = test_data$Kyphosis)
acc_ens <- sum(diag(cm_ens)) / sum(cm_ens)
print(cm_ens)
cat(sprintf("Accuracy ансамбля (3x nnet, test): %.4f\n", acc_ens))

# 4. Random Forest + важность признаков
cat("\n=== 3. Random Forest и важность признаков ===\n")
rf_model <- randomForest(Kyphosis ~ ., data = train_data, ntree = 100, importance = TRUE)
rf_pred <- predict(rf_model, newdata = test_data)

cm_rf <- table(Predicted = rf_pred, Actual = test_data$Kyphosis)
acc_rf <- sum(diag(cm_rf)) / sum(cm_rf)
print(cm_rf)
cat(sprintf("Accuracy Random Forest (test): %.4f\n\n", acc_rf))

cat("Важность признаков (importance):\n")
print(importance(rf_model))

# 5. Повторная проверка (20 случайных разбиений 80/20) для устойчивого сравнения
cat("\n=== 4. Сравнение на 20 случайных разбиениях (Monte Carlo CV) ===\n")
n_rep <- 20
acc_ens_vec <- numeric(n_rep)
acc_rf_vec  <- numeric(n_rep)

for (r in seq_len(n_rep)) {
  idx <- createDataPartition(kyphosis$Kyphosis, p = 0.80, list = FALSE)
  tr <- kyphosis[idx, ]
  te <- kyphosis[-idx, ]

  pr <- preProcess(tr[, num_cols], method = c("center", "scale"))
  tr_s <- tr; tr_s[, num_cols] <- predict(pr, tr[, num_cols])
  te_s <- te; te_s[, num_cols] <- predict(pr, te[, num_cols])

  m_ens <- train_ensemble_nnet(tr_s, best_sizes)
  p_ens <- predict_ensemble_vote(m_ens, te_s)
  acc_ens_vec[r] <- mean(p_ens == te$Kyphosis)

  m_rf <- randomForest(Kyphosis ~ ., data = tr, ntree = 100)
  p_rf <- predict(m_rf, newdata = te)
  acc_rf_vec[r] <- mean(p_rf == te$Kyphosis)
}

cat(sprintf("Средняя Accuracy Ensemble (3x nnet): %.4f (sd = %.4f)\n", mean(acc_ens_vec), sd(acc_ens_vec)))
cat(sprintf("Средняя Accuracy Random Forest:      %.4f (sd = %.4f)\n", mean(acc_rf_vec), sd(acc_rf_vec)))
