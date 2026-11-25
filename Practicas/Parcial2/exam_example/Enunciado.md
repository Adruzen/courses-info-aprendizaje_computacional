# Aprendizaje Computacional. 25/11/2026

En este ejercicio vamos a estudiar el reto de Klagge, denominado Spaceship Titanic (https://www.kaggle.com/competitions/spaceship-titanic/overview). En dicho reto, que se inspira en el Titanic, debemos predecir si un pasajero desaparece o no de una nave espacial. Los atributos del conjunto de datos:

| Variable | Descripción |
| :--- | :--- |
| `PassengerId` | Identificador del pasajero |
| `HomePlanet` | Planeta de origen |
| `CryoSleep` | Si estaba en criosueño |
| `Cabin` | Cabina |
| `Destination` | Destino |
| `Age` | Edad |
| `VIP` | Si es VIP |
| `RoomService` | Gastos en servicio de habitaciones |
| `FoodCourt` | Gastos en restaurantes |
| `ShoppingMall` | Gastos en tiendas |
| `Spa` | Gastos en spa |
| `VRDeck` | Gastos en realidad virtual |
| `Transported` | Variable objetivo. `TRUE`: pasajero transportado. `FALSE`: pasajero no transportado |

La competición se ha solucionado de diferentes maneras puedes ver en el apartado Code. Los modelos propuestos han llegado a un accuracy de como máximo 0.96539 usando los datos de test.

En nuestro caso vamos a usar los datos de train tanto para entrenamiento como para test y usaremos como referencia el accuracy anterior.

Observa que hay datos faltantes. También, que existen atributos que se pueden reducir a uno. Y al contrario. Toma las decisiones que consideres necesarias en la fase de preprocesamiento.

Se pide:

1. Justifica las decisiones que tomas con los atributos del conjunto de datos. **(0.5 puntos)**
2. Implementa un Random Forest con `ntry=4` y 50 árboles. Calcula el accuracy con los datos de test y muestra la importancia de las variables. **(2 puntos)**
3. Modifica el Random Forest anterior eliminando la variable de menor peso. Calcula el accuracy y comentalo con respectos al accuracy del apartado anterior ¿Cuál modelo usarías? **(1.5 puntos)**
4. Implementa un Adabosst.M1 cuyos árboles tengan las características similares al apartado 2 y compara ambos accuracy. **(2 puntos)**
5. Implementa un ensemble con filosofía Adaboost.M1 cuyo modelo débil son 50 máquinas SVM (kernel RBF con parámetros elegidos por el alumnos, por ejemplo usando `tune`). Usa el paquete `kenrlab`. La predicción se realizará por el método de votación mayoritaria ponderada (*Weighted Majority Voting*). No es necesario calcular `alpha`, obtenlo del adaboost del apartado 4. **(3 puntos)**
