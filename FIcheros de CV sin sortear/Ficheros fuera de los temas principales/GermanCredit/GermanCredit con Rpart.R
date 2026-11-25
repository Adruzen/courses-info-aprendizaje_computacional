
# ============================================================
# GERMANCREDIT: RPART, VALIDACION CRUZADA Y PODA
# Criterios: minimo xerror y regla 1-SE
# ============================================================

# 1. Instalar y cargar paquetes
if (!requireNamespace("caret", quietly = TRUE)) {
  install.packages("caret")
}
if (!requireNamespace("rpart", quietly = TRUE)) {
  install.packages("rpart")
}

library(caret)
library(rpart)

set.seed(123)

# 2. Cargar el conjunto de datos completo
data("GermanCredit", package = "caret")
datos <- GermanCredit

# 3. Seleccionar las variables solicitadas
variables <- c(
  "Age",
  "Job.Management.SelfEmp.HighlyQualified",
  "Housing.Rent",
  "Housing.ForFree",
  "Housing.Own",
  "SavingsAccountBonds.500.to.1000",
  "CheckingAccountStatus.lt.0",
  "CheckingAccountStatus.0.to.200",
  "Amount",
  "Duration",
  "Purpose.NewCar",
  "Class"
)

# Comprobar que existen todas las columnas
if (!all(variables %in% names(datos))) {
  stop(
    "No se encuentran estas variables: ",
    paste(setdiff(variables, names(datos)), collapse = ", ")
  )
}

datos <- datos[, variables]

# GermanCredit contiene variables indicadoras y numéricas.
# La variable objetivo debe ser un factor.
datos$Class <- factor(datos$Class)

cat("Numero de observaciones:", nrow(datos), "\n")
cat("Distribucion de clases:\n")
print(table(datos$Class))

# 4. Particion estratificada: 70% entrenamiento, 30% prueba
# Se mantiene la proporcion de las clases en ambos conjuntos.
indices_train <- createDataPartition(
  datos$Class,
  p = 0.70,
  list = FALSE
)

train <- datos[indices_train, ]
test  <- datos[-indices_train, ]

cat("\nObservaciones de entrenamiento:", nrow(train), "\n")
cat("Observaciones de prueba:", nrow(test), "\n")

# 5. Entrenar el arbol inicial sin poda previa
# cp = 0 permite generar el arbol inicial sin el umbral
# habitual de poda por complejidad.
modelo_inicial <- rpart(
  Class ~ .,
  data = train,
  method = "class",
  control = rpart.control(
    cp = 0,
    xval = 10,
    minsplit = 20,
    minbucket = 7,
    maxdepth = 30
  )
)

# Mostrar el arbol
print(modelo_inicial)
plot(modelo_inicial)
text(modelo_inicial, use.n = TRUE, cex = 0.65)

# 6. Tabla de complejidad y error de validacion cruzada
tabla_cp <- modelo_inicial$cptable

cat("\nTabla de complejidad (CP):\n")
print(tabla_cp)

# Graficar el error de validacion cruzada
plotcp(modelo_inicial)

# 7. Elegir el CP que minimiza xerror
fila_min <- which.min(tabla_cp[, "xerror"])

cp_min <- tabla_cp[fila_min, "CP"]

cat("\nCP con minimo xerror:", cp_min, "\n")
cat("Minimo xerror:", tabla_cp[fila_min, "xerror"], "\n")
cat("Error estandar en el minimo:",
    tabla_cp[fila_min, "xstd"], "\n")

# Podar el arbol usando el CP de minimo xerror
modelo_min <- prune(
  modelo_inicial,
  cp = cp_min
)

# 8. Aplicar la regla de un error estandar (1-SE)
# Umbral = minimo xerror + error estandar en ese minimo
umbral_1se <- tabla_cp[fila_min, "xerror"] +
  tabla_cp[fila_min, "xstd"]

# Elegir el arbol mas sencillo que cumpla el umbral.
# La tabla esta ordenada de arboles mas sencillos a mas complejos.
filas_validas <- which(tabla_cp[, "xerror"] <= umbral_1se)

fila_1se <- filas_validas[1]
cp_1se <- tabla_cp[fila_1se, "CP"]

cat("\nUmbral 1-SE:", umbral_1se, "\n")
cat("CP seleccionado por 1-SE:", cp_1se, "\n")
cat("xerror del arbol 1-SE:",
    tabla_cp[fila_1se, "xerror"], "\n")

modelo_1se <- prune(
  modelo_inicial,
  cp = cp_1se
)

# 9. Funcion para calcular accuracy sobre los mismos datos
calcular_accuracy <- function(modelo, datos_test) {
  pred <- predict(
    modelo,
    newdata = datos_test,
    type = "class"
  )
  
  mean(pred == datos_test$Class)
}

# 10. Comparar los tres arboles en el conjunto de prueba
acc_inicial <- calcular_accuracy(modelo_inicial, test)
acc_min     <- calcular_accuracy(modelo_min, test)
acc_1se     <- calcular_accuracy(modelo_1se, test)

comparacion <- data.frame(
  Modelo = c(
    "Sin podar",
    "Podado: minimo xerror",
    "Podado: regla 1-SE"
  ),
  CP = c(
    min(tabla_cp[, "CP"]),
    cp_min,
    cp_1se
  ),
  Hojas = c(
    sum(modelo_inicial$frame$var == "<leaf>"),
    sum(modelo_min$frame$var == "<leaf>"),
    sum(modelo_1se$frame$var == "<leaf>")
  ),
  Accuracy = c(
    acc_inicial,
    acc_min,
    acc_1se
  )
)

comparacion$Accuracy_porcentaje <-
  round(100 * comparacion$Accuracy, 2)

cat("\n--- COMPARACION FINAL ---\n")
print(comparacion, row.names = FALSE)

# 11. Matrices de confusion
cat("\nMatriz de confusion: arbol sin podar\n")
print(table(
  Real = test$Class,
  Predicho = predict(
    modelo_inicial, test, type = "class"
  )
))

cat("\nMatriz de confusion: arbol minimo xerror\n")
print(table(
  Real = test$Class,
  Predicho = predict(
    modelo_min, test, type = "class"
  )
))

cat("\nMatriz de confusion: arbol 1-SE\n")
print(table(
  Real = test$Class,
  Predicho = predict(
    modelo_1se, test, type = "class"
  )
))

# 12. Dibujar los dos arboles podados
par(mfrow = c(1, 2))

plot(modelo_min, uniform = TRUE,
     main = "Poda: minimo xerror")
text(modelo_min, use.n = TRUE, cex = 0.65)

plot(modelo_1se, uniform = TRUE,
     main = "Poda: regla 1-SE")
text(modelo_1se, use.n = TRUE, cex = 0.65)

par(mfrow = c(1, 1))
