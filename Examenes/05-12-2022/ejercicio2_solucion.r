# ==============================================================================
# APRENDIZAJE COMPUTACIONAL - EXAMEN 05/12/2022
# Solución Ejercicio 2: Predicción del atributo faltante "Age" en Titanic
# Basado en la plantilla: ejemplo_titanik-poda.r
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Carga de librerías necesarias y fijación de semilla
# ------------------------------------------------------------------------------
library(rpart)       # Librería para la creación y poda de árboles de decisión
library(rpart.plot)  # Librería para la visualización gráfica de árboles

set.seed(1234)       # Fijamos la semilla para garantizar la reproducibilidad de los resultados

# ------------------------------------------------------------------------------
# 1. Carga del conjunto de datos del Titanic
# ------------------------------------------------------------------------------
# Leemos el archivo CSV. stringsAsFactors=TRUE convierte cadenas de texto a factores (ej. Sex)
titanic <- read.csv("titanic.csv", stringsAsFactors = TRUE)

# Verificamos los nombres de las columnas en el dataset original
names(titanic)

# ------------------------------------------------------------------------------
# 2. Preprocesamiento: Eliminación de atributos no relevantes y tratamiento de NAs
# ------------------------------------------------------------------------------
# Eliminamos los atributos habituales según lo especificado en el enunciado:
# Name, PassengerId, Ticket, Cabin y Embarked
titanic$PassengerId <- NULL
titanic$Name        <- NULL
titanic$Ticket      <- NULL
titanic$Cabin       <- NULL
titanic$Embarked    <- NULL

# Eliminamos todas las filas que contengan valores faltantes (incluyendo el campo Age)
# na.omit() elimina los registros incompletos para entrenar y evaluar el modelo sólo con datos reales conocidos
titanic <- na.omit(titanic)

# ------------------------------------------------------------------------------
# 3. División del dataset en conjuntos de Entrenamiento (Train) y Test
# ------------------------------------------------------------------------------
# Generamos un vector de índices (1 y 2) con probabilidades 90% (train) y 10% (test),
# siguiendo exactamente el mismo esquema que la plantilla del profesor
ind <- sample(2, nrow(titanic), replace = TRUE, prob = c(0.9, 0.1))

trainTitanic <- titanic[ind == 1, ] # 90% de los datos para entrenamiento
testTitanic  <- titanic[ind == 2, ] # 10% de los datos para evaluación (test)

# ------------------------------------------------------------------------------
# 4. Entrenamiento del árbol de decisión (rpart) para la variable continua "Age"
# ------------------------------------------------------------------------------
# Entrenamos el árbol de regresión especificando Age como variable respuesta (Age ~ .)
# y usando el resto de atributos disponibles (Survived, Pclass, Sex, SibSp, Parch, Fare).
# rpart utiliza validación cruzada interna (xval=10 por defecto) para calcular la tabla CP.
arbolEdad <- rpart(Age ~ ., data = trainTitanic, control = rpart.control(minsplit = 5))

# Visualizamos el árbol inicial entrenado y lo guardamos como PNG
png("arbol_edad_inicial.png", width = 1000, height = 800, res = 120)
rpart.plot(arbolEdad, main = "Árbol de Decisión Inicial para Edad")
dev.off()

# ------------------------------------------------------------------------------
# 5. Validación Cruzada y Poda del Árbol (Pruning)
# ------------------------------------------------------------------------------
# Imprimimos la tabla de complejidad de parámetros (CP) resultante de la validación cruzada
print(arbolEdad$cptable)

# Localizamos el valor de CP que minimiza el error de validación cruzada (xerror)
indicetablaCP <- which.min(arbolEdad$cptable[, "xerror"])
cpMin <- arbolEdad$cptable[indicetablaCP, "CP"]

# Podamos el árbol utilizando el valor de CP óptimo
arbolEdadPodado <- prune(arbolEdad, cp = cpMin)

# Dibujamos el árbol podado resultante y lo guardamos como PNG
png("arbol_edad_podado.png", width = 1000, height = 800, res = 120)
rpart.plot(arbolEdadPodado, main = "Árbol de Decisión Podado para Edad")
dev.off()

# Muestra también en la ventana interactiva si está disponible
rpart.plot(arbolEdadPodado, main = "Árbol de Decisión Podado para Edad")

# ------------------------------------------------------------------------------
# 6. Predicción en el conjunto de Test e Iteración Pasajero a Pasajero
# ------------------------------------------------------------------------------
# Según el enunciado:
# - Iteramos por el conjunto de datos de test
# - Realizamos la predicción con type="vector" para obtener la edad predicha
# - Calculamos la diferencia al cuadrado entre la edad predicha y la edad real (para MSE)
# - Guardamos las diferencias cuadráticas en un vector y obtenemos su media (MSE)

# Creamos un vector numérico para almacenar la diferencia al cuadrado de cada pasajero
diferencias_cuadradas <- numeric(nrow(testTitanic))

# Bucle para iterar por cada pasajero en el conjunto de test
for (i in 1:nrow(testTitanic)) {
  # Obtenemos la predicción de edad para el pasajero i (usando type = "vector")
  prediccion_edad <- predict(arbolEdadPodado, newdata = testTitanic[i, ], type = "vector")
  
  # Edad real almacenada en el conjunto de test
  edad_real <- testTitanic$Age[i]
  
  # Calculamos la diferencia al cuadrado (Error Cuadrático)
  diferencias_cuadradas[i] <- (prediccion_edad - edad_real)^2
}

# ------------------------------------------------------------------------------
# 7. Obtención del MSE (Mean Squared Error / Error Cuadrático Medio)
# ------------------------------------------------------------------------------
mse <- mean(diferencias_cuadradas)
rmse <- sqrt(mse) # Raíz del error cuadrático medio (RMSE) en años

cat("\n======================================================\n")
cat("RESULTADOS DE LA EVALUACIÓN DE PREDICCIÓN DE EDAD:\n")
cat("======================================================\n")
cat("Número de pasajeros en el conjunto de test:", nrow(testTitanic), "\n")
cat("Error Cuadrático Medio (MSE):", round(mse, 4), "\n")
cat("Raíz del Error Cuadrático Medio (RMSE):", round(rmse, 4), "años\n")
cat("======================================================\n\n")

# NOTA ADICIONAL (Forma vectorizada equivalente en R):
# predicciones_vec <- predict(arbolEdadPodado, newdata = testTitanic, type = "vector")
# mse_vec <- mean((predicciones_vec - testTitanic$Age)^2)
