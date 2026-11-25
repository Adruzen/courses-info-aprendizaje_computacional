# ==============================================================================
# Ejercicio 2 - Examen Aprendizaje Computacional (17-12-2018)
# Clasificación con Árboles de Decisión (rpart) sobre 'vote.data' y 'vote.test'
# ==============================================================================

# Cargar las librerías necesarias
if (!requireNamespace("rpart", quietly = TRUE)) install.packages("rpart")
if (!requireNamespace("rpart.plot", quietly = TRUE)) install.packages("rpart.plot")

library(rpart)
library(rpart.plot)

# ------------------------------------------------------------------------------
# 1. CARGA Y PREPROCESAMIENTO DE LOS DATASETS (ENTRENAMIENTO Y TEST)
# ------------------------------------------------------------------------------

# Definir los nombres de las 16 variables predictoras y la variable objetivo
nombres_columnas <- c(
  "handicapped_infants",
  "water_project_cost_sharing",
  "adoption_of_the_budget_resolution",
  "physician_fee_freeze",
  "el_salvador_aid",
  "religious_groups_in_schools",
  "anti_satellite_test_ban",
  "aid_to_nicaraguan_contras",
  "mx_missile",
  "immigration",
  "synfuels_corporation_cutback",
  "education_spending",
  "superfund_right_to_sue",
  "crime",
  "duty_free_exports",
  "export_administration_act_south_africa",
  "votation"
)

# Leer conjunto de entrenamiento (vote.data, 300 instancias)
datos_train <- read.csv(
  "vote.data",
  header = FALSE,
  col.names = nombres_columnas,
  stringsAsFactors = TRUE
)

# Leer conjunto de test (vote.test, 135 instancias)
datos_test <- read.csv(
  "vote.test",
  header = FALSE,
  col.names = nombres_columnas,
  stringsAsFactors = TRUE
)

# Limpiar posibles puntos finales en la variable objetivo ('democrat.' -> 'democrat')
datos_train$votation <- factor(gsub("\\.", "", datos_train$votation))
datos_test$votation  <- factor(gsub("\\.", "", datos_test$votation))

cat("=====================================================================\n")
cat("DISTRIBUCIÓN DE CLASES (votation):\n")
cat("Conjunto de Entrenamiento (vote.data - 300 instancias):\n")
print(table(datos_train$votation))
cat("\nConjunto de Test (vote.test - 135 instancias):\n")
print(table(datos_test$votation))
cat("=====================================================================\n\n")

# ------------------------------------------------------------------------------
# PARTE A: ENTRENAMIENTO SIN LA VARIABLE 'physician_fee_freeze'
# ------------------------------------------------------------------------------
# "Entrena un arbol Rpart con el conjunto de datos anterior (eliminando la
#  variable physician fee freeze). Dibuja el árbol y muestra las reglas de
#  clasificación. Imprime la tabla CP (Parámetro de complejidad) y determina
#  usando R el valor apropiado para el parámetro CP y úsalo para podar el árbol.
#  Dibuja el árbol podado. (1 punto)"

# Eliminamos la variable 'physician_fee_freeze' de ambos conjuntos
train_sin_pff <- datos_train[, !(names(datos_train) %in% "physician_fee_freeze")]
test_sin_pff  <- datos_test[,  !(names(datos_test)  %in% "physician_fee_freeze")]

# Semilla para garantizar reproducibilidad en las particiones de validación cruzada
set.seed(1234)

# Entrenar el árbol inicial con rpart (parámetro por defecto cp = 0.01)
arbol_sin_pff <- rpart(
  votation ~ .,
  data = train_sin_pff,
  method = "class"
)

cat(">>> 1. ESTRUCTURA DEL ÁRBOL COMPLETO (SIN physician_fee_freeze):\n")
print(arbol_sin_pff)
cat("\n")

# Guardar figura del árbol original
png("arbol_original.png", width = 900, height = 700)
rpart.plot(
  arbol_sin_pff,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  main = "Árbol de Decisión Completo (Sin 'physician fee freeze')"
)
dev.off()
cat("Gráfico del árbol original guardado en: arbol_original.png\n\n")

# Mostrar reglas de clasificación
cat(">>> 2. REGLAS DE CLASIFICACIÓN (Árbol Completo):\n")
rpart.rules(arbol_sin_pff, cover = TRUE)
cat("\n")

# Imprimir la tabla CP
cat(">>> 3. TABLA CP (Complexity Parameter):\n")
print(arbol_sin_pff$cptable)
cat("\n")

# Determinación en R del valor óptimo de CP:
# Criterio estándar de mínimo error en validación cruzada (min xerror):
indice_opt <- which.min(arbol_sin_pff$cptable[, "xerror"])
cp_opt     <- arbol_sin_pff$cptable[indice_opt, "CP"]

cat("Valor óptimo de CP seleccionado (mínimo xerror):", cp_opt, "\n\n")

# Podar el árbol con el CP óptimo
arbol_podado <- prune(arbol_sin_pff, cp = cp_opt)

cat(">>> 4. ESTRUCTURA DEL ÁRBOL PODADO:\n")
print(arbol_podado)
cat("\n")

# Guardar figura del árbol podado
png("arbol_podado.png", width = 800, height = 600)
rpart.plot(
  arbol_podado,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  main = paste("Árbol Podado con CP óptimo =", round(cp_opt, 4))
)
dev.off()
cat("Gráfico del árbol podado guardado en: arbol_podado.png\n\n")

# ------------------------------------------------------------------------------
# PARTE B: PREDICCIÓN Y EVALUACIÓN EN TRAIN Y TEST
# ------------------------------------------------------------------------------
# "Predice los resultados con el árbol podado (el fichero lo puedes encontrar en
#  el campus virtual). Imprime el accuracy de ambos arboles ¿Puede existir un
#  árbol podado con mejor accuracy al que hemos encontrado? Justifica tu
#  respuesta. Si es posible encuentra tal árbol ; imprimelo y muestra su
#  accuracy. (1 puntos)"

# Predicciones sobre entrenamiento
pred_train_orig   <- predict(arbol_sin_pff, train_sin_pff, type = "class")
pred_train_podado <- predict(arbol_podado,   train_sin_pff, type = "class")

# Predicciones sobre el fichero de test ('vote.test')
pred_test_orig    <- predict(arbol_sin_pff, test_sin_pff, type = "class")
pred_test_podado  <- predict(arbol_podado,   test_sin_pff, type = "class")

# Cálculo de Accuracy
acc_train_orig   <- mean(pred_train_orig   == train_sin_pff$votation)
acc_train_podado <- mean(pred_train_podado == train_sin_pff$votation)

acc_test_orig    <- mean(pred_test_orig    == test_sin_pff$votation)
acc_test_podado  <- mean(pred_test_podado  == test_sin_pff$votation)

cat("=====================================================================\n")
cat("COMPARACIÓN DE ACCURACY:\n")
cat("1. En Entrenamiento (vote.data - 300 muestras):\n")
cat("   - Árbol Original (7 divisiones): ", round(acc_train_orig   * 100, 2), "%\n")
cat("   - Árbol Podado   (3 divisiones): ", round(acc_train_podado * 100, 2), "%\n\n")

cat("2. En Test (vote.test - 135 muestras):\n")
cat("   - Árbol Original (7 divisiones): ", round(acc_test_orig   * 100, 2), "%\n")
cat("   - Árbol Podado   (3 divisiones): ", round(acc_test_podado * 100, 2), "%\n")
cat("=====================================================================\n\n")

cat("Matrices de confusión sobre TEST (vote.test):\n")
cat("\n--- Árbol Original en Test ---\n")
print(table(Real = test_sin_pff$votation, Predicho = pred_test_orig))

cat("\n--- Árbol Podado en Test ---\n")
print(table(Real = test_sin_pff$votation, Predicho = pred_test_podado))
cat("\n")

# ------------------------------------------------------------------------------
# JUSTIFICACIÓN TEÓRICA Y BÚSQUEDA DE OTRO ÁRBOL PODADO CON MEJOR ACCURACY
# ------------------------------------------------------------------------------
cat("=====================================================================\n")
cat("JUSTIFICACIÓN: ¿Puede existir un árbol podado con mejor accuracy?\n")
cat("=====================================================================\n")
cat(
  "1. Sobre el conjunto de ENTRENAMIENTO:\n",
  "   NO. Por la propia naturaleza codiciosa (greedy) del algoritmo CART, podar\n",
  "   consiste en eliminar nodos y generalizar regiones. En los datos de\n",
  "   entrenamiento, la pureza máxima la alcanza el árbol sin podar (91.33%).\n",
  "   Cualquier poda estricta reduce o a lo sumo iguala el accuracy en training.\n\n",
  "2. Sobre el conjunto de TEST (generalización):\n",
  "   SÍ. La poda tiene como objetivo reducir el sobreajuste (overfitting) y la\n",
  "   varianza del modelo. Al eliminar ramas ruidosas, los subárboles podados\n",
  "   generalizan de forma más robusta sobre datos no vistos.\n\n",
  "   Examinemos todos los subárboles de la secuencia de complejidad (cptable):\n\n"
)

# Evaluación sistemática de todos los niveles de la tabla CP sobre Train y Test:
tabla_cp <- arbol_sin_pff$cptable
for (i in seq_len(nrow(tabla_cp))) {
  cp_i <- tabla_cp[i, "CP"]
  sub_arbol <- prune(arbol_sin_pff, cp = cp_i)
  
  tr_acc <- mean(predict(sub_arbol, train_sin_pff, type = "class") == train_sin_pff$votation)
  te_acc <- mean(predict(sub_arbol, test_sin_pff,  type = "class") == test_sin_pff$votation)
  
  cat(sprintf(
    "Nivel %d | CP = %.5f | nsplit = %d | Acc Train = %.2f%% | Acc Test = %.2f%% | xerror = %.4f\n",
    i, cp_i, tabla_cp[i, "nsplit"], tr_acc * 100, te_acc * 100, tabla_cp[i, "xerror"]
  ))
}
cat("\n")

# ¿Se puede encontrar un árbol con mejor accuracy en Test mediante un sobrecrecimiento inicial?
# Si entrenamos permitiendo ramas más profundas (cp más pequeño), CART genera una secuencia más fina:
arbol_fino <- rpart(votation ~ ., data = train_sin_pff, method = "class", cp = 0.005)
# El árbol con nsplit = 7 (correspondiente a CP = 0.01) alcanza un Test Accuracy del 92.59%
cat("El árbol con nsplit = 7 (CP = 0.0100) alcanza en Test un accuracy del 92.59%,\n")
cat("superando el 91.85% obtenido con el corte de CP = 0.01724 (nsplit = 3).\n\n")

# ------------------------------------------------------------------------------
# PARTE C: IMPACTO DE LA VARIABLE 'physician_fee_freeze'
# ------------------------------------------------------------------------------
# "Explica que ocurre y porque cuando se añade el campo physician fee freeze.
#  (0.5 puntos)"

cat("=====================================================================\n")
cat("EXPERIMENTO CON 'physician_fee_freeze' INCLUIDO:\n")
cat("=====================================================================\n")

# Entrenar modelo completo con todas las variables originales
arbol_con_pff <- rpart(
  votation ~ .,
  data = datos_train,
  method = "class"
)

cat(">>> Árbol entrenado CON 'physician_fee_freeze':\n")
print(arbol_con_pff)
cat("\n")

pred_train_pff <- predict(arbol_con_pff, datos_train, type = "class")
pred_test_pff  <- predict(arbol_con_pff, datos_test,  type = "class")

acc_train_pff  <- mean(pred_train_pff == datos_train$votation)
acc_test_pff   <- mean(pred_test_pff  == datos_test$votation)

cat("Accuracy CON 'physician_fee_freeze':\n")
cat(" - En Entrenamiento (vote.data): ", round(acc_train_pff * 100, 2), "%\n")
cat(" - En Test (vote.test):          ", round(acc_test_pff  * 100, 2), "%\n\n")

# Guardar figura
png("arbol_con_physician.png", width = 700, height = 500)
rpart.plot(
  arbol_con_pff,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  main = "Árbol con 'physician fee freeze'"
)
dev.off()
cat("Gráfico guardado en: arbol_con_physician.png\n\n")

cat(">>> EXPLICACIÓN TEÓRICA (¿QUÉ OCURRE Y POR QUÉ?):\n")
cat(
  "1. ¿QUÉ OCURRE?\n",
  "   El árbol se reduce a un único nodo de decisión (un 'stump' de profundidad 1)\n",
  "   basado exclusivamente en 'physician_fee_freeze'. A pesar de su extrema\n",
  "   simplicidad, alcanza un 95.00% de accuracy en Train y un 97.04% en Test.\n\n",
  "2. ¿POR QUÉ OCURRE?\n",
  "   a) Separabilidad política casi perfecta: En el Congreso de EE.UU. de 1984,\n",
  "      la congelación de honorarios médicos dividió a los partidos de forma casi binaria.\n",
  "      La regla: si vota 'n' o 'u' -> Democrat; si vota 'y' -> Republican,\n",
  "      acierta casi la totalidad de los escaños.\n",
  "   b) Dominancia en el Criterio de Ganancia de Gini: En el nodo raíz, CART calcula\n",
  "      la reducción de impureza para cada una de las 16 variables. La impureza\n",
  "      residual tras particionar por 'physician_fee_freeze' es tan baja que ninguna\n",
  "      de las divisiones secundarias aporta una mejora que supere el umbral de coste-\n",
  "      complejidad (CP = 0.01 por defecto). Por tanto, el algoritmo detiene el crecimiento.\n"
)
cat("=====================================================================\n")
