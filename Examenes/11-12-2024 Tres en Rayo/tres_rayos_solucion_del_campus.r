# Para resolver el problema de sugerir el siguiente movimiento en el juego de tres en raya,
# necesitamos construir un modelo predictivo que pueda prever la mejor jugada para el oponente dada
# una configuración del tablero actual.
# Los aspectos generales para abordar este problema serán:
# - Configuración del problema:
# Los atributos del DataFrame serán las celdas del tablero, cada celda del tablero puede ser representada como un atributo. 
# En un tablero de 3x3, hay un total de 9 celdas. Cada celda puede tener uno de los siguientes valores: X, O, o estar vacía.
#
# Clasificación (Objetivo): La clasificación sería la celda recomendada para el próximo movimiento del oponente.   
# Un atributo que indica en qué celda el oponente debería colocar su ficha. Puede ser un número del 1 al 9, representando la posición en el tablero.
#
# Ejemplos:
#
# Ejemplo 1 (Ganó X):
# 
# Tablero:
# X | O | X
# ---------
# O | X | O
# ---------
# X |   | O
# Atributo de clasificación: ENDED.
#
# Ejemplo 2 (Empate):
#
# Tablero:
# X | O | X
# ---------
# O | X | X
# ---------
# O | X | O
# Atributo de clasificación: ENDED.
#
# Ejemplo 3 (Recomendación para Oponente):
#
# Tablero:
# X | O | X
# ---------
#   | X | O
# ---------
#   |   | O
# Atributo de clasificación: 7 (indicando que el oponente debería colocar su ficha en la celda 7).

library(rpart)
library(nnet)
library(e1071)
library(kernlab)

data <- data.frame(
  celda1 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda2 = c("O", "X", "O", "X", "X", "O", " ", " ", " ", " "),
  celda3 = c("X", "O", "X", "O", "O", " ", "X", " ", " ", " "),
  celda4 = c("O", "X", " ", "X", "O", "X", "O", " ", " ", " "),
  celda5 = c("X", "O", "X", "X", " ", "O", " ", "O", " ", " "),
  celda6 = c("O", "X", "O", "X", "O", " ", "X", " ", " ", " "),
  celda7 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda8 = c("O", "X", " ", "X", "O", " ", "X", "O", " ", " "),
  celda9 = c("X", "O", "X", "O", "X", "O", " ", " ", " ", " "),
  turno = c("X", "O", "X", "O", "X", "O", "X", "O", "X", "O"),
  clasificacion = c(5, 7, 9, 6, 1, 8, 3, 7, 9, 5)
)

"Para resolver el problema de determinar en qué celda del tablero el oponente debe 
colocar su ficha en el juego de tres en raya, sigo los siguientes pasos:
1. Creación del DataFrame:
  
    Cada fila del DataFrame representará un estado del tablero.
    Los atributos del DataFrame representarán las características del estado del tablero.
    El atributo de clasificación indicará la recomendación de la celda donde el oponente debe colocar su ficha.

2. Atributos del DataFrame

    Celdas del tablero: Cada celda del tablero se representa como un atributo. Puedes tener 9 atributos. El valor de cada celda puede ser 'X', 'O', o vacío.
    Turno: Un atributo que indica si es el turno del jugador 'X' o del oponente 'O'.
    Evaluación del tablero: Puedes incluir atributos que representen la evaluación del tablero en términos de quién está ganando o si el juego ha terminado.
    
3. Atributo de clasificación

    Un atributo que indica en qué celda el oponente debería colocar su ficha. Puede ser un número del 1 al 9, representando la posición en el tablero.
    
4. Ejemplos:

    Ejemplo 1 (Ganó X):
    
    Tablero:
    X | O | X
    ---------
    O | X | O
    ---------
    X |   | O
    Atributo de clasificación: ENDED.
    
    Ejemplo 2 (Empate):

    Tablero:
    
    X | O | X
    ---------
    O | X | X
    ---------
    O | X | O
    Atributo de clasificación: ENDED.
    
    Ejemplo 3 (Recomendación para Oponente):

    Tablero:
    
    X | O | X
    ---------
      | X | O
    ---------
      |   | O
    Atributo de clasificación: 7 (indicando que el oponente debería colocar su ficha en la celda 7).

5. Modelos:

    Entrenar los modelos (árboles de decisión CART, perceptrón, máquinas de soporte vectorial) utilizando el DataFrame creado.
    Utilizar los modelos para predecir la celda recomendada para el oponente en función del estado actual del tablero.
"
library(rpart)
library(nnet)
library(e1071)
library(kernlab)

dataEx <- data.frame(
  celda1 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda2 = c("O", "X", "O", "X", "X", "O", " ", " ", " ", " "),
  celda3 = c("X", "O", "X", "O", "O", " ", "X", " ", " ", " "),
  celda4 = c("O", "X", " ", "X", "O", "X", "O", " ", " ", " "),
  celda5 = c("X", "O", "X", "X", " ", "O", " ", "O", " ", " "),
  celda6 = c("O", "X", "O", "X", "O", " ", "X", " ", " ", " "),
  celda7 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda8 = c("O", "X", " ", "X", "O", " ", "X", "O", " ", " "),
  celda9 = c("X", "O", "X", "O", "X", "O", " ", " ", " ", " "),
  turno = c("X", "O", "X", "O", "X", "O", "X", "O", "X", "O"),
  clasificacion = c(5, 7, 9, 6, 1, 8, 3, 7, 9, 5)
)


# Árbol de decisión 
t_cart <- proc.time() # Inicia el cronómetro
modelo_cart <- rpart(clasificacion ~ ., data = dataEx, method = "class")
tiempo_cart <- proc.time() - t_cart

# Perceptrón
t_perceptron <- proc.time() # Inicia el cronómetro
modelo_perceptron <- nnet(clasificacion ~ ., data = dataEx, size = 5, linout = TRUE)
tiempo_perceptron <- proc.time() - t_perceptron

# Máquinas de soporte vectorial (SVM)
t_svm <- proc.time() # Inicia el cronómetro
modelo_svm <- svm(clasificacion ~ ., data = dataEx)
tiempo_svm <- proc.time() - t_svm

# Evaluar los modelos en el conjunto de entrenamiento
predicciones_cart <- predict(modelo_cart, newdata = dataEx)
predicciones_perceptron <- predict(modelo_perceptron, newdata = dataEx)
predicciones_svm <- predict(modelo_svm, newdata = dataEx)

# Calcular el ratio de aciertos
aciertos_cart <- sum(predicciones_cart == dataEx$clasificacion) / nrow(dataEx)
aciertos_perceptron <- sum(predicciones_perceptron == dataEx$clasificacion) / nrow(dataEx)
aciertos_svm <- sum(predicciones_svm == dataEx$clasificacion) / nrow(dataEx)

# Mostrar resultados
print("Árbol de Decisión (CART):")
print(aciertos_cart)
print(tiempo_cart)

print("Perceptrón:")
print(aciertos_perceptron)
print(tiempo_perceptron)

print("Máquinas de Soporte Vectorial (SVM):")
print(aciertos_svm)
print(tiempo_svm)

mejor_modelo <- NULL
nombre_mejor_modelo <- ""

if (aciertos_cart > aciertos_perceptron && aciertos_cart > aciertos_svm) {
  mejor_modelo <- modelo_cart
  nombre_mejor_modelo <- "Árbol de Decisión (CART)"
} else if (aciertos_perceptron > aciertos_cart && aciertos_perceptron > aciertos_svm) {
  mejor_modelo <- modelo_perceptron
  nombre_mejor_modelo <- "Perceptrón"
} else {
  mejor_modelo <- modelo_svm
  nombre_mejor_modelo <- "Máquinas de Soporte Vectorial (SVM)"
}

print(paste("El mejor modelo es(", nombre_mejor_modelo, ")"))

#Apartado 4

# Entrenar y guardar el modelo de Máquinas de Soporte Vectorial (SVM)
modelo_final_svm <- svm(clasificacion ~ ., data = dataEx)

# Guardar el modelo en un archivo
save(modelo_final_svm, file = "modelo_svm.rda")

# Imprimir mensaje de confirmación
print("El modelo SVM ha sido entrenado y guardado con exito.")

#APARTADO 5

# Cargar el modelo entrenado
load("modelo_svm.rda")

# Función para predecir la mejor posición en el tablero
predecir_posicion <- function(tablero, modelo, verbose = FALSE) {
  # Convertir el tablero a un data frame
  nuevo_estado <- data.frame(
    celda1 = as.factor(tablero$celda1),
    celda2 = as.factor(tablero$celda2),
    celda3 = as.factor(tablero$celda3),
    celda4 = as.factor(tablero$celda4),
    celda5 = as.factor(tablero$celda5),
    celda6 = as.factor(tablero$celda6),
    celda7 = as.factor(tablero$celda7),
    celda8 = as.factor(tablero$celda8),
    celda9 = as.factor(tablero$celda9),
    turno = as.factor(tablero$turno)
  )
  
  # Realizar la predicción
  prediccion <- predict(modelo, newdata = nuevo_estado)
  
  # Imprimir estado del tablero y clasificación si se activa el modo verbose
  if (verbose) {
    cat("Estado del tablero:\n")
    print(tablero)
    cat("Clasificación del tablero:", prediccion, "\n")
  }
  
  # Devolver la mejor posición predicha
  return(prediccion)
}

# Ejemplo de uso en modo verbose
tablero_actual <- data.frame(
  celda1 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda2 = c("O", "X", "O", "X", "X", "O", " ", " ", " ", " "),
  celda3 = c("X", "O", "X", "O", "O", " ", "X", " ", " ", " "),
  celda4 = c("O", "X", " ", "X", "O", "X", "O", " ", " ", " "),
  celda5 = c("X", "O", "X", "X", " ", "O", " ", "O", " ", " "),
  celda6 = c("O", "X", "O", "X", "O", " ", "X", " ", " ", " "),
  celda7 = c("X", "O", "X", "O", " ", "X", "O", " ", " ", " "),
  celda8 = c("O", "X", " ", "X", "O", " ", "X", "O", " ", " "),
  celda9 = c("X", "O", "X", "O", "X", "O", " ", " ", " ", " "),
  turno = c("X", "O", "X", "O", "X", "O", "X", "O", "X", "O")
)

# Predicción en modo verbose
predecir_posicion(tablero_actual, modelo_final_svm, verbose = TRUE)

#######################APARTADO 6 #####################

jugar_partida <- function(modelo, turno_inicial = "X", verbose = FALSE) {
  tablero <- matrix(" ", nrow = 3, ncol = 3)
  turno <- turno_inicial
  jugadas <- data.frame(matrix("", nrow = 0, ncol = 10,
                               dimnames = list(NULL, c("celda1", "celda2", "celda3", "celda4", "celda5",
                                                       "celda6", "celda7", "celda8", "celda9", "turno"))))
  
  while (TRUE) {
    if (turno == "X") {
      # Jugada del jugador
      cat("Turno del jugador (X)\n")
      print(tablero)
      fila <- as.numeric(readline(prompt = "Ingrese la fila (1-3): "))
      col <- as.numeric(readline(prompt = "Ingrese la columna (1-3): "))
      
      if (tablero[fila, col] == " ") {
        tablero[fila, col] <- "X"
        turno <- "O"
      } else {
        cat("Celda ocupada. Intente de nuevo.\n")
        next
      }
    } else {
      # Jugada del oponente (predicción del modelo)
      nuevo_estado <- data.frame(
        celda1 = as.factor(tablero[1, ]),
        celda2 = as.factor(tablero[2, ]),
        celda3 = as.factor(tablero[3, ]),
        celda4 = as.factor(tablero[4, ]),
        celda5 = as.factor(tablero[5, ]),
        celda6 = as.factor(tablero[6, ]),
        celda7 = as.factor(tablero[7, ]),
        celda8 = as.factor(tablero[8, ]),
        celda9 = as.factor(tablero[9, ]),
        turno = as.factor(turno)
      )
      
      # Realizar predicción
      prediccion <- predict(modelo, newdata = nuevo_estado)
      posicion_predicha <- as.numeric(prediccion)
      
      # Actualizar tablero
      tablero <- as.matrix(tablero)
      tablero[posicion_predicha] <- "O"
      turno <- "X"
    }
    
    # Registrar jugada
    jugada <- c(as.character(tablero), turno)
    jugadas <- rbind(jugadas, jugada)
    
    # Mostrar estado del tablero y clasificación si se activa el modo verbose
    if (verbose) {
      cat("Estado del tablero:\n")
      print(tablero)
      cat("Clasificación del tablero:", predecir_posicion(data.frame(t(tablero)), modelo), "\n")
    }
    
    # Verificar si hay un ganador o empate
    if (hay_ganador(tablero, "X")) {
      cat("¡Ganó el jugador (X)!\n")
      break
    } else if (hay_ganador(tablero, "O")) {
      cat("¡Ganó el oponente (O)!\n")
      break
    } else if (todos_ocupados(tablero)) {
      cat("Empate.\n")
      break
    }
  }
  
  return(jugadas)
}

# Función para verificar si hay un ganador en el tablero
hay_ganador <- function(tablero, jugador) {
  # Filas
  if (any(apply(tablero, 1, function(row) all(row == jugador)))) {
    return(TRUE)
  }
  
  # Columnas
  if (any(apply(tablero, 2, function(col) all(col == jugador)))) {
    return(TRUE)
  }
  
  # Diagonales
  if (all(diag(tablero) == jugador) || all(diag(t(tablero)) == jugador)) {
    return(TRUE)
  }
  
  return(FALSE)
}

# Función para verificar si todas las celdas están ocupadas
todos_ocupados <- function(tablero) {
  return(all(tablero != " "))
}

# # Jugar partida iniciando el jugador (X)
jugadas_jugador <- jugar_partida(modelo_final_svm, turno_inicial = "X", verbose = TRUE)

# Incorporar jugadas del jugador al dataset
if (nrow(jugadas_jugador) > 0) {
  dataEx <- rbind(dataEx, jugadas_jugador)
}

# Jugar partida iniciando el oponente (O)
jugadas_oponente <- jugar_partida(modelo_final_svm, turno_inicial = "O", verbose = TRUE)

# Incorporar jugadas del oponente al dataset
if (nrow(jugadas_oponente) > 0) {
  dataEx <- rbind(dataEx, jugadas_oponente)
}

# Mostrar dataset actualizado
print("Dataset actualizado:")
print(dataEx)
