library(rpart)
library(nnet)
library(e1071)
library(mlbench)
library(ins)
library(caretEnsemble)

set.seed(7)

# ===============================
# División train / test
# ===============================

ind <- sample(150, 150)
idt <- ind[1:10]
dtrain <- iris[-idt, ]
dtest  <- iris[idt, ]

# Asegurar que Species es factor
dtrain$Species <- as.factor(dtrain$Species)
dtest$Species  <- as.factor(dtest$Species)

# ===============================
# Modelos base con caretList
# ===============================

control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  savePredictions = "final",
  classProbs = TRUE
)

algorithmList <- c("nnet", "svmRadial")

models <- caretList(
  Species ~ ., 
  data = dtrain,
  trControl = control,
  methodList = algorithmList,
  tuneList = NULL
)

# Resultados individuales
results <- resamples(models)
summary(results)
dotplot(results)

# ===============================
# Stacking (meta-modelo SVM radial)
# ===============================

stackControl <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  savePredictions = "final",
  classProbs = TRUE
)

stackingSVM <- caretStack(
  models,
  method = "svmRadial",
  trControl = stackControl
)

print(stackingSVM)

# ===============================
# Evaluación en conjunto de prueba
# ===============================

# Predicciones finales del modelo apilado
pred <- predict(stackingSVM, newdata = dtest)

# Accuracy
accuracy <- mean(pred == dtest$Species)
cat("Accuracy del modelo en test:", accuracy, "\n")

# Matriz de confusión (recomendada)
print(confusionMatrix(pred, dtest$Species))

