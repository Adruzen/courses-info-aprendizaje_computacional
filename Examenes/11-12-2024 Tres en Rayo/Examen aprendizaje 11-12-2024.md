# Aprendizaje Computacional - Examen 11 de Diciembre de 2024

**Dpto. Lenguajes y Ciencias de la Computación**  
**E.T.S.I. en Informática, Universidad de Málaga**  
**Fecha:** 11 de Diciembre de 2024  

**Apellidos:**  
**Nombre:**  

---

## Problema 1: Modelo Inteligente para Tres en Raya (2.5 puntos)

El juego de **Tres en Raya** es un juego entre dos jugadores: oponente $O$ y jugador $X$, que marcan los espacios de un tablero de $3 \times 3$ alternadamente. El juego finaliza cuando el jugador o su oponente ha colocado sus fichas en una línea, columna o diagonal.

* Una partida ganada por el primer jugador, $X$.
* Una partida que termina en empate.

Se pretende elegir un modelo que en función del estado del tablero indique en qué celda del tablero nuestro oponente ($O$) debe colocar su ficha. Los modelos que vamos a estudiar son:
* **Árboles de decisión CART** (`rpart`)
* **Perceptrón / Redes Neuronales** (`nnet`)
* **Máquinas de Soporte Vectorial** (`e1071` o `kernlab`)

---

### Tareas:

1. **Explicación general (0.25 puntos):**
   * Explica de forma general cómo resolver el problema.

2. **Creación del Data Frame (0.25 puntos):**
   * Realiza el data frame. Para tal fin puedes usar aplicaciones como por ejemplo: [https://papergames.io/es/tres-en-raya](https://papergames.io/es/tres-en-raya) (jugar contra robot) y añadir las jugadas que tiendan a ganar una partida sean del jugador o del oponente.
   * También podemos añadir jugadas que podemos denominar *estudiadas*. Por ejemplo, colocar la ficha en la celda central si todas las celdas están vacías.
   * No es necesario que el data frame sea muy extenso: entre 15 y 20 entradas (2 o 3 partidas).

3. **Análisis y selección del modelo más adecuado (0.5 puntos):**
   * Realiza un análisis y determina el modelo más adecuado. Fíjate tanto en el ratio de aciertos (*accuracy*) como en el tamaño del modelo obtenido (`object.size`) y el tiempo de entrenamiento:
     ```r
     t <- proc.time()  # Inicia el cronómetro
     # NUESTRO CODIGO
     proc.time() - t
     ```

4. **Entrenamiento y guardado del modelo (0.5 puntos):**
   * Realiza un programa en R que entrene el modelo que has decidido en el paso anterior y lo guarde (usa `save`).

5. **Carga y motor de inferencia con modo verbose (1.0 punto):**
   * Realiza un programa en R que cargue (usa `load`) el modelo anterior y, dado el estado del tablero, devuelva dónde colocar la ficha.
   * *Ejemplo:* Si el tablero estuviera vacío y jugara el oponente, una posible salida sería poner la ficha en la celda central del tablero:

```text
Tablero Inicial:           Tablero Final:
+---+---+---+              +---+---+---+
|   |   |   |              |   |   |   |
+---+---+---+     ===>     +---+---+---+
|   |   |   |              |   | O |   |
+---+---+---+              +---+---+---+
|   |   |   |              |   |   |   |
+---+---+---+              +---+---+---+
```

   * El programa tendrá un modo *verbose* que mostrará el estado del tablero junto a la clasificación del mismo.
   * *Nota:* La finalización del juego debemos controlarla nosotros, no se pide realizar un juego completo de tres en raya sino el modelo que lo dote de inteligencia.

---

## Problema 2: Árboles ID3 y SVM con Dataset de Setas (3.0 puntos)

En la tabla adjunta se muestran características de unas setas y si son comestibles o no. Nos hemos fijado en la forma y color del sombrero (`cap-shape` y `cap-color`) y en el grosor y color del tronco (`gill-size` y `gill-color`). El atributo de clasificación es `class`, que indica si la seta es venenosa (`poisonous`) o no (`edible`).

| `cap-shape` | `cap-color` | `gill-size` | `gill-color` | `class` |
| :---: | :---: | :---: | :---: | :---: |
| convex | brown | narrow | black | poisonous |
| convex | yellow | broad | black | edible |
| bell | white | broad | brown | edible |
| convex | white | narrow | brown | poisonous |
| convex | yellow | broad | brown | edible |
| bell | white | broad | brown | edible |
| convex | white | narrow | pink | poisonous |

---

### Tareas:

1. **Árbol de Decisión ID3 manual (1.5 puntos):**
   * Encuentra la etiqueta del nodo raíz y las tablas necesarias para continuar al siguiente nivel, usando el algoritmo ID3 visto en clase.
   * Desarrolla las fórmulas completas de entropía, entropía condicional y ganancias, al menos en la primera variable.
   * Muestra el árbol con sus etiquetas tanto en el nodo raíz como en los arcos, así como la tabla asociada a cada arco.

2. **Máquina de Soporte Vectorial con `kernlab` (1.5 puntos):**
   * A partir del dataframe anterior y usando el paquete `kernlab`, entrena una máquina de soporte vectorial y obtén los siguientes parámetros:
     * Ancho del canal
     * Término independiente $b$
     * Vector de Pesos normal al Hiperplano $W$
     * La ecuación del Hiperplano y de los planos de soporte positivo y negativo
   * Realiza la predicción de una seta con las siguientes características:
     `cap-shape = bell`, `cap-color = white`, `gill-size = broad`, `gill-color = black`
     *(citadas en el mismo orden que los atributos de la tabla adjunta)*.
   * ¿Podrías comerte la seta?

---

## Problema 3: Detección de Ataques DDoS con Random Forest (4.5 puntos)

El conjunto de datos que se adjunta al examen (`Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv`) se corresponde con tráfico de red considerado normal o benigno (clasificado como `BENIGN`) y tráfico que se considera forma parte de un ataque de denegación de servicio (clasificado como `DDOS`).

Los atributos del dataset son el puerto destino, duración del flujo, tiempo mínimo y máximo entre paquetes, entre otras características. Cada paquete del dataset está clasificado como tráfico legal (`BENIGN`) o ilegal (`DDOS`) con el atributo de decisión `Label`.

---

### Tareas:

1. **Entrenamiento de Random Forest y ajuste de hiperparámetros (1.5 puntos):**
   * Entrena un modelo que permita predecir el tipo de tráfico a partir del dataframe descrito anteriormente. Usa `randomForest`.
   * Encuentra los valores adecuados de los parámetros `ntree` y `mtry`.

2. **Predicción con Validación Cruzada (0.5 puntos):**
   * A partir del modelo obtenido anteriormente, realiza una predicción usando validación cruzada.

3. **Importancia de las Variables (0.5 puntos):**
   * Calcula la importancia de las variables (mediante `importance()` y `varImpPlot()`).

4. **Selección de características por impureza de Gini (2.0 puntos):**
   * Entrena de nuevo el modelo en las mismas condiciones del apartado 1 modificando la fórmula de tal forma que intervengan únicamente las variables con `MeanDecreaseGini > 7`.
   * ¿Con cuál de los dos modelos te quedarías? Justifica la respuesta.

