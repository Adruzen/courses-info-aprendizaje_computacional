# Enunciado — Problema 1 (`2025-12-01 — Examen Parte 2`)

> **Fuente:** `Examenes/Enunciados - todos examenes.md` (cabecera del examen: `Aprendizaje Computacional` — `01 de diciembre de 2025`, archivo original: `Aprendizaje Computacional 01_12_2025.pdf`).

### Problema 1 — Ensemble de perceptrones (nnet) vs Random Forest en Kyphosis

El conjunto de datos `Kyphosis` (disponible con el paquete `Rpart`) nos indica si, tras una operación en la columna vertebral, una muestra de 81 niños presenta o no deformaciones en la columna vertebral (columna `Kyphosis`). El resto de columnas son:
- **`Age`**: Año en meses.
- **`Number`**: Número de la vértebra involucrada.
- **`Start`**: Número de la primera vértebra involucrada.

Realiza un ensemble con tres perceptrones (paquete `nnet`) en el primer nivel y votación en el segundo. Estudia el número de neuronas adecuado. Cada uno de los perceptrones debemos entrenarlos con dos atributos distintos y usando validación cruzada: la parte de entrenamiento de los perceptrones se obtiene aleatoriamente reservando un 75% de los datos para cada perceptrón. **(2.5 puntos)**

Compara el accuracy del ensemble anterior con un Random Forest. Calcula la importancia de los atributos. **(2.5 punto)**
