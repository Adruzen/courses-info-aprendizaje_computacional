# Enunciado — Problema 1 (`2026-02-04 — Examen 2ª Convocatoria Ordinaria`)

> **Fuente:** `Examenes/Enunciados - todos examenes.md` (archivo original: `Examen Aprendizaje Computacional 04_02_2026.pdf`, sin cabecera impresa).

### Problema 1 — Wine Quality (Random Forest y AdaBoost.M1)

El conjunto de datos **Wine Quality** contiene información sobre diversas características físico-químicas de vinos tintos y blancos. El objetivo es predecir la calidad de un vino en función de sus características, usando el algoritmo de **Random Forest**.

Las características incluyen medidas químicas como la acidez, la concentración de alcohol, la densidad, el pH, entre otras. La calidad del vino se clasifica en una escala de 0 a 10, siendo 0 una calidad muy baja y 10 una calidad muy alta.

Tu tarea es construir un modelo de **Random Forest** para predecir la calidad del vino a partir de las características disponibles.

**Datos:**

El conjunto de datos **`winequality-red.csv`** (que se encuentra en el fichero `wine+quality.zip` que se adjunta) contiene las siguientes columnas:
- **`fixed acidity`**: Acidez fija (en g/t).
- **`volatile acidity`**: Acidez volátil (en g/t).
- **`citric acid`**: Ácido cítrico (en g/t).
- **`residual sugar`**: Azúcar residual (en g/t).
- **`chlorides`**: Cloruros (en g/t).
- **`free sulfur dioxide`**: Dióxido de azufre libre (en mg/L).
- **`total sulfur dioxide`**: Dióxido de azufre total (en mg/L).
- **`density`**: Densidad (en $\text{g/cm}^3$).
- **`pH`**: pH.
- **`sulphates`**: Sulfatos (en g/t).
- **`alcohol`**: Contenido de alcohol (%).
- **`quality`**: Calidad del vino (entero, de 0 a 10).

**Realiza:**
1. **Cargar y explorar los datos:** **(0.15 puntos)**
   - Carga el conjunto de datos `winequality.csv` y realiza un análisis exploratorio.
   - Verifica si hay valores faltantes o anómalos en las variables.
   - Visualiza las distribuciones de las características y su relación con la variable objetivo (`quality`).
2. **Preprocesamiento de los datos:** **(0.25 puntos)**
   - Trata los valores faltantes si los hay (puedes rellenar, eliminar o imputar dependiendo del caso).
   - Explora las características más relevantes que pueden influir en la calidad del vino.
   - Normaliza o escala las variables si es necesario, especialmente aquellas con rangos de valores muy diferentes.
3. **División de los datos:** **(0.1 puntos)**
   - Divide el conjunto de datos en un conjunto de entrenamiento (80%) y un conjunto de prueba (20%).
4. **Entrenamiento del modelo Random Forest:** **(0.5 puntos)**
   - Utiliza el conjunto de entrenamiento para entrenar un modelo Random Forest que prediga la calidad del vino.
   - Ajusta los parámetros como `ntree` (número de árboles) y `mtry` (número de variables a considerar por árbol) para optimizar el modelo.
5. **Evaluación del modelo:** **(0.5 puntos)**
   - Realiza predicciones sobre el conjunto de pruebas.
   - Evalúa el rendimiento del modelo.
6. **Ajuste de parámetros:** **(0.5 puntos)**
   - Utiliza técnicas de **validación cruzada** o **ajuste de hiperparámetros** para encontrar los mejores valores de `ntree`, `mtry`, y otros parámetros del modelo.
7. **Importancia de las variables:** **(0.5 puntos)**
   - Analiza la importancia de las variables utilizando la función `randomForest::importance()` para determinar qué características influyen más en la calidad del vino.
8. **Repite el ejercicio con Adaboost.M1 (2 puntos)**
