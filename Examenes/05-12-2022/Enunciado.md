# Aprendizaje Computacional - Examen 05 de Diciembre de 2022

**Dpto. Lenguajes y Ciencias de la Computación**  
**E.T.S.I. en Informática, Universidad de Málaga**  
**Fecha:** 05 de Diciembre de 2022  

**Apellidos:**  
**Nombre:**  
**DNI:**  

---

### Ejercicio 1

1. A partir del conjunto de datos que podemos encontrar en el campus virtual (denominado `ejercicio2SVM.csv`): Determina si es separable linealmente e indica cuál sería la función Kernel más adecuada (indica tipo de función y sus parámetros) **(1 punto)**.

Calcula los siguientes parámetros de la Máquina de Soporte Vectorial que podemos obtener con el dataset anterior y el Kernel elegido:

I. Vectores Soporte. **(0.25 puntos)**  
II. Ancho del canal. **(0.5 puntos)**  
III. Vector de Pesos normal al Hiperplano ($W$). **(0.25 puntos)**  
IV. Vector $B$. **(0.25 puntos)**  
V. La ecuación del Hiperplano y de los planos de soporte positivo y negativo. **(0.75 puntos)**  
VI. Pinta el conjunto de puntos y el Hiperplano. **(0.75 puntos)**  
VII. Clasifica los puntos $(0.5, 0.8)$ y $(0.6, 0.2)$. **(0.25 puntos)**  

---

### Ejercicio 2

2. En el conjunto de datos del Titanic, como sabemos, existen datos faltantes en diferentes atributos que eliminamos en la fase de preprocesamiento. En particular nos vamos a centrar en el atributo edad (`Age`) y nos proponemos evaluar la predicción de los valores faltantes en dicho campo. Para tal fin, entrenaremos un árbol Rpart usando validación cruzada, eliminando los atributos habituales (`Name`, `PassengerId`, `Ticket`, `Cabin`, y `Embarked`). Además, eliminaremos los datos faltantes incluidos los del campo `Age`.

La predicción vamos a realizarla de la siguiente manera: iteramos por el conjunto de datos reservado para entrenamiento (test) y realizamos la predicción (usa tipo vector, `type="vector"`) de la edad (`Age`) de cada uno de los pasajeros del conjunto de entrenamiento/test. Calcularemos la diferencia entre la edad predicha y la edad conocida del pasajero (es decir, la edad que aparece en el campo `Age` de dicho pasajero en el conjunto de test) y la guardaremos en un vector. Por último, obtendremos su media.

Se pide:

I. Realizar un programa en R que cumpla con las especificaciones anteriormente descritas. **(5 puntos)**  
II. Comenta los resultados. **(0.25 puntos)**  
III. ¿Crees que podemos usar esta técnica para tratar los datos faltantes del campo `Age` en Titanic? **(0.25 puntos)**  
IV. ¿Podrías exponer una técnica más eficaz? Describirla brevemente. **(0.25 puntos)**  
