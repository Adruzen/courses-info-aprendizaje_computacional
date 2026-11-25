# ==============================================================================
# APRENDIZAJE COMPUTACIONAL - EXAMEN 03/11/2022 (Parte 1)
# Solución Ejercicio 2, Apartado c):
# Clasificación con Árboles de Decisión (rpart), Poda por Validación Cruzada
# (mínimo xerror y regla 1-SE) y Comparación de Accuracies.
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Carga de librerías y configuración de reproducibilidad
# ------------------------------------------------------------------------------
# rpart: implementación del algoritmo CART para árboles de clasificación y regresión
library(rpart)
# rpart.plot: permite visualizar de forma clara y estética el árbol de decisión
library(rpart.plot)

# Fijamos una semilla aleatoria para garantizar la reproducibilidad de la partición train/test
set.seed(1234)

# ------------------------------------------------------------------------------
# 1. Carga del conjunto de datos GermanCredit
# ------------------------------------------------------------------------------
# Leemos el archivo CSV. stringsAsFactors = TRUE convierte automáticamente las 
# cadenas de texto (como la variable objetivo 'Class') en factores (Good / Bad).
archivo_datos <- "GermanCredit.csv"
if (!file.exists(archivo_datos)) {
  # Si se ejecuta desde el directorio raíz del proyecto
  archivo_datos <- "Examenes/03-11-2025 (Parte 1).pdf/GermanCredit.csv"
}

german <- read.csv(archivo_datos, stringsAsFactors = TRUE)

# ------------------------------------------------------------------------------
# 2. Selección de las variables especificadas en el enunciado
# ------------------------------------------------------------------------------
# El enunciado requiere utilizar exclusivamente las siguientes 12 variables:
# 11 variables predictoras + 1 variable objetivo ('Class')
variables_seleccionadas <- c(
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
  "Class"  # Variable objetivo (Good / Bad)
)

# Filtramos el dataset para quedarnos únicamente con las columnas solicitadas
datos <- german[, variables_seleccionadas]

# Aseguramos explícitamente que la variable objetivo sea de tipo factor
datos$Class <- as.factor(datos$Class)

cat("Dimensiones del dataset filtrado:", nrow(datos), "filas y", ncol(datos), "columnas.\n\n")

# ------------------------------------------------------------------------------
# 3. División del dataset en Entrenamiento (Train) y Test
# ------------------------------------------------------------------------------
# Siguiendo la metodología habitual de la asignatura (90% entrenamiento, 10% test):
indices <- sample(2, nrow(datos), replace = TRUE, prob = c(0.9, 0.1))

train_data <- datos[indices == 1, ]  # Conjunto para entrenar y validar mediante CV
test_data  <- datos[indices == 2, ]  # Conjunto independiente para evaluar el accuracy final

cat("Número de instancias en Train:", nrow(train_data), "\n")
cat("Número de instancias en Test :", nrow(test_data), "\n\n")

# ------------------------------------------------------------------------------
# 4. Entrenamiento del Árbol de Decisión Inicial (sin podar)
# ------------------------------------------------------------------------------
# - Class ~ . : predice la clase crediticia en función de todas las variables restantes.
# - method = "class" : indica que es un árbol de clasificación (variable cualitativa).
# - rpart.control(minsplit = 5) : número mínimo de observaciones necesarias en un nodo
#   para intentar una división (permite que el árbol crezca lo suficiente para ser podado).
# rpart ejecuta internamente validación cruzada de 10 particiones (xval = 10 por defecto).
arbol_inicial <- rpart(
  Class ~ ., 
  data = train_data, 
  method = "class", 
  control = rpart.control(minsplit = 5, cp = 0.001)
)

# Visualización del árbol completo sin podar
cat("--- Visualización del Árbol Inicial (Sin Podar) ---\n")
rpart.plot(arbol_inicial, main = "Árbol GermanCredit Inicial (Sin Podar)", extra = 104)

# ------------------------------------------------------------------------------
# 5. Evaluación del Accuracy del Árbol Sin Podar
# ------------------------------------------------------------------------------
# Realizamos la predicción de clases (type = "class") sobre el conjunto de test
pred_inicial <- predict(arbol_inicial, newdata = test_data, type = "class")

# Matriz de confusión
matriz_inicial <- table(Prediccion = pred_inicial, Real = test_data$Class)
cat("\nMatriz de Confusión (Árbol Sin Podar):\n")
print(matriz_inicial)

# Accuracy = Casos acertados (diagonal) / Total de casos
acc_inicial <- sum(diag(matriz_inicial)) / sum(matriz_inicial)
cat("Accuracy Árbol Sin Podar:", round(acc_inicial * 100, 2), "%\n\n")

# ------------------------------------------------------------------------------
# 6. Análisis de la Tabla de Complejidad (cptable) resultante de Validación Cruzada
# ------------------------------------------------------------------------------
# La tabla cptable contiene:
# - CP: Parámetro de complejidad
# - nsplit: Número de divisiones del árbol
# - rel error: Error relativo en entrenamiento
# - xerror: Error estimado mediante validación cruzada (Cross-Validation Error)
# - xstd: Desviación estándar del error de validación cruzada
cat("--- Tabla de Parámetros de Complejidad (cptable) ---\n")
print(arbol_inicial$cptable)
cat("\n")

# ------------------------------------------------------------------------------
# 7. Poda del Árbol por Mínimo xerror (Error Mínimo de Validación Cruzada)
# ------------------------------------------------------------------------------
# 7.1. Localizamos la fila que contiene el menor error de validación cruzada (xerror)
idx_min_xerror <- which.min(arbol_inicial$cptable[, "xerror"])

# 7.2. Extraemos el valor del parámetro CP asociado a ese mínimo
cp_min <- arbol_inicial$cptable[idx_min_xerror, "CP"]
cat("Criterio Mínimo xerror:\n")
cat(" - Fila seleccionada:", idx_min_xerror, "\n")
cat(" - Mínimo xerror:", arbol_inicial$cptable[idx_min_xerror, "xerror"], "\n")
cat(" - CP óptimo (cp_min):", cp_min, "\n\n")

# 7.3. Podamos el árbol con el CP óptimo
arbol_podado_min <- prune(arbol_inicial, cp = cp_min)

# Visualización del árbol podado por mínimo xerror
rpart.plot(arbol_podado_min, main = "Árbol GermanCredit Podado (Mínimo xerror)", extra = 104)

# 7.4. Calculamos el accuracy del árbol podado por mínimo xerror en test
pred_podado_min <- predict(arbol_podado_min, newdata = test_data, type = "class")
matriz_podado_min <- table(Prediccion = pred_podado_min, Real = test_data$Class)
acc_podado_min <- sum(diag(matriz_podado_min)) / sum(matriz_podado_min)
cat("Accuracy Árbol Podado (Mínimo xerror):", round(acc_podado_min * 100, 2), "%\n\n")

# ------------------------------------------------------------------------------
# 8. Poda del Árbol aplicando la Regla 1-SE (One Standard Error Rule)
# ------------------------------------------------------------------------------
# La regla 1-SE busca el árbol más simple (menor número de nodos / mayor CP) cuyo
# error de validación cruzada no supere al mínimo xerror más una desviación estándar:
# Límite = xerror_min + xstd_min
tabla_cp <- arbol_inicial$cptable
min_xerror <- tabla_cp[idx_min_xerror, "xerror"]
min_xstd   <- tabla_cp[idx_min_xerror, "xstd"]

limite_1se <- min_xerror + min_xstd

# Buscamos el primer árbol (de menor tamaño / mayor CP) que esté por debajo del límite
idx_1se <- which(tabla_cp[, "xerror"] <= limite_1se)[1]
cp_1se  <- tabla_cp[idx_1se, "CP"]

cat("Criterio Regla 1-SE (One Standard Error Rule):\n")
cat(" - Límite (xerror_min + xstd):", round(limite_1se, 5), "\n")
cat(" - Fila seleccionada:", idx_1se, "\n")
cat(" - xerror bajo regla 1-SE:", tabla_cp[idx_1se, "xerror"], "\n")
cat(" - CP seleccionado (cp_1se):", cp_1se, "\n\n")

# Podamos el árbol aplicando el CP bajo la regla 1-SE
arbol_podado_1se <- prune(arbol_inicial, cp = cp_1se)

# Visualización del árbol podado por regla 1-SE
rpart.plot(arbol_podado_1se, main = "Árbol GermanCredit Podado (Regla 1-SE)", extra = 104)

# Calculamos el accuracy del árbol podado con 1-SE en test
pred_podado_1se <- predict(arbol_podado_1se, newdata = test_data, type = "class")
matriz_podado_1se <- table(Prediccion = pred_podado_1se, Real = test_data$Class)
acc_podado_1se <- sum(diag(matriz_podado_1se)) / sum(matriz_podado_1se)
cat("Accuracy Árbol Podado (Regla 1-SE):", round(acc_podado_1se * 100, 2), "%\n\n")

# ------------------------------------------------------------------------------
# 9. Comparación y Resumen Final de Resultados
# ------------------------------------------------------------------------------
cat("======================================================================\n")
cat("                TABLA COMPARATIVA DE ACCURACIES EN TEST               \n")
cat("======================================================================\n")
cat(sprintf("%-35s | %-10s | %-12s\n", "Modelo", "Nº Nodos", "Accuracy (%)"))
cat("----------------------------------------------------------------------\n")
cat(sprintf("%-35s | %-10d | %-12.2f%%\n", 
            "1. Árbol Sin Podar", 
            length(arbol_inicial$frame$var[arbol_inicial$frame$var == "<leaf>"]), 
            acc_inicial * 100))
cat(sprintf("%-35s | %-10d | %-12.2f%%\n", 
            "2. Árbol Podado (Mínimo xerror)", 
            length(arbol_podado_min$frame$var[arbol_podado_min$frame$var == "<leaf>"]), 
            acc_podado_min * 100))
cat(sprintf("%-35s | %-10d | %-12.2f%%\n", 
            "3. Árbol Podado (Regla 1-SE)", 
            length(arbol_podado_1se$frame$var[arbol_podado_1se$frame$var == "<leaf>"]), 
            acc_podado_1se * 100))
cat("======================================================================\n\n")

# Comentarios sobre la comparación:
# 1. Árbol sin podar vs. podado: El árbol sin podar suele sufrir sobreajuste (overfitting),
#    memorizando ruido del conjunto de entrenamiento. La poda reduce la varianza y suele
#    mantener o mejorar el accuracy en test a la vez que hace el modelo mucho más interpretable.
# 2. Mínimo xerror vs. 1-SE: La regla 1-SE favorece un principio de parsimonia (Navaja de Ockham),
#    seleccionando un árbol aún más pequeño y robusto con un rendimiento estadísticamente
#    equivalente al del árbol de mínimo error de validación cruzada.

