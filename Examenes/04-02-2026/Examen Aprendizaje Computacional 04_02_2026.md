# Aprendizaje Computacional - Examen 04 de Febrero de 2026

**Dpto. Lenguajes y Ciencias de la Computación**  
**E.T.S.I. en Informática, Universidad de Málaga**  
**Fecha:** 04 de Febrero de 2026  

---

## Problema 1 (5 puntos)

El conjunto de datos **Wine Quality** contiene información sobre diversas características físico-químicas de vinos tintos y blancos. El objetivo es predecir la calidad de un vino en función de sus características, usando el algoritmo de **Random Forest**.

Las características incluyen medidas químicas como la acidez, la concentración de alcohol, la densidad, el pH, entre otras. La calidad del vino se clasifica en una escala de 0 a 10, siendo 0 una calidad muy baja y 10 una calidad muy alta.

Tu tarea es construir un modelo de **Random Forest** para predecir la calidad del vino a partir de las características disponibles.

### Datos:
El conjunto de datos `winequality-red.csv` (que se encuentra en el fichero `wine+quality.zip` que se adjunta) contiene las siguientes columnas:
* `fixed acidity`: Acidez fija (en g/dm³ o g/L).
* `volatile acidity`: Acidez volátil (en g/dm³).
* `citric acid`: Ácido cítrico (en g/dm³).
* `residual sugar`: Azúcar residual (en g/dm³).
* `chlorides`: Cloruros (en g/dm³).
* `free sulfur dioxide`: Dióxido de azufre libre (en mg/dm³).
* `total sulfur dioxide`: Dióxido de azufre total (en mg/dm³).
* `density`: Densidad (en g/cm³).
* `pH`: pH.
* `sulphates`: Sulfatos (en g/dm³).
* `alcohol`: Contenido de alcohol (% vol).
* `quality`: Calidad del vino (puntuación entera entre 0 y 10).

---

### Realiza:

1. **Cargar y explorar los datos (0.15 puntos):**
   * Carga el conjunto de datos `winequality-red.csv` y realiza un análisis exploratorio.
   * Verifica si hay valores faltantes o anómalos en las variables.
   * Visualiza las distribuciones de las características y su relación con la variable objetivo (`quality`).

2. **Preprocesamiento de los datos (0.25 puntos):**
   * Trata los valores faltantes si los hay (puedes rellenar, eliminar o imputar dependiendo del caso).
   * Explora las características más relevantes que pueden influir en la calidad del vino.
   * Normaliza o escala las variables si es necesario, especialmente aquellas con rangos de valores muy diferentes.

3. **División de los datos (0.1 puntos):**
   * Divide el conjunto de datos en un conjunto de entrenamiento (80%) y un conjunto de prueba (20%).

4. **Entrenamiento del modelo Random Forest (0.5 puntos):**
   * Utiliza el conjunto de entrenamiento para entrenar un modelo Random Forest que prediga la calidad del vino.
   * Ajusta los parámetros como `ntree` (número de árboles) y `mtry` (número de variables a considerar por árbol) para optimizar el modelo.

5. **Evaluación del modelo (0.5 puntos):**
   * Realiza predicciones sobre el conjunto de pruebas.
   * Evalúa el rendimiento del modelo (matriz de confusión, accuracy, etc.).

6. **Ajuste de parámetros (0.5 puntos):**
   * Utiliza técnicas de validación cruzada o ajuste de hiperparámetros para encontrar los mejores valores de `ntree`, `mtry`, y otros parámetros del modelo.

7. **Importancia de las variables (0.5 puntos):**
   * Analiza la importancia de las variables utilizando la función `randomForest::importance()` para determinar qué características influyen más en la calidad del vino.

8. **Repite el ejercicio con AdaBoost.M1 (2 puntos):**
   * Implementa y entrena un modelo de ensamble mediante **AdaBoost.M1** (usando librerías como `adabag`).
   * Evalúa y compara sus resultados frente a Random Forest.

---

## Problema 2 (5 puntos)

### Apartado a) (2.5 puntos)
Calcula todos los parámetros ($W$, $b$, vectores soporte, ancho del canal, las tres rectas de separación del canal) de la máquina SVM obtenida a partir del siguiente conjunto de datos que sabemos son **separables linealmente**:

| $X_1$ | $X_2$ | $Y$ |
| :---: | :---: | :---: |
| 1 | 1 | -1 |
| 3 | 3 | 1 |
| 1 | 3 | 1 |
| 3 | 1 | -1 |
| 2 | 2.5 | 1 |
| 3 | 2.5 | -1 |
| 4 | 3 | -1 |

* Dibuja las rectas que conforman el canal así como los vectores soporte.

---

### Apartado b) (2.5 puntos)
Repite el ejercicio con el siguiente conjunto de datos **no separable linealmente**:

| $X_1$ | $X_2$ | $Y$ |
| :---: | :---: | :---: |
| 1 | 1 | -1 |
| 3 | 3 | 1 |
| 1 | 3 | 1 |
| 3 | 1 | -1 |
| 2 | 2.5 | 1 |
| 3 | 2.5 | -1 |
| 4 | 3 | -1 |
| 1.5 | 1.5 | 1 |
| 1 | 2 | -1 |

