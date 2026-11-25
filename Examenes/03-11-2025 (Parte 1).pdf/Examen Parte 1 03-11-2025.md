# Aprendizaje Computacional - Examen 03 de Noviembre de 2022 (Parte 1)

**Dpto. Lenguajes y Ciencias de la Computación**  
**E.T.S.I. en Informática, Universidad de Málaga**  
**Fecha:** 03 de Noviembre de 2022  

**Apellidos:**  
**Nombre:**  
**DNI:**  

---

### Ejercicio 1 (5 puntos)

1. Calcula los parámetros de una máquina de SVM usando el kernel lineal, a partir de los siguientes puntos:

| Punto | $x$ | $y$ | Clase |
| :---: | :-: | :-: | :---: |
| A | 1 | 2 | +1 |
| B | 2 | -1 | -1 |
| C | 3 | -1 | -1 |
| D | 2 | 3 | +1 |
| E | 3 | -3 | -1 |

a) Realiza los cálculos usando las ecuaciones estudiadas en clase. Debes determinar **(3 puntos)**:

I. Sistema de Ecuaciones para obtener los coeficientes de Lagrange y $b$.  
II. Coeficientes de Lagrange ($\alpha$).  
III. Vector de Pesos normal al Hiperplano ($W$).  
IV. Vector $B$ (término independiente $b$).  
V. Vectores Soporte.  
VI. Ancho del canal.  
VII. La ecuación del Hiperplano y de los planos de soporte positivo y negativo.  
VIII. Función de clasificación.  
IX. Clasificar los puntos que no sean vectores de soporte.  

b) Repite el apartado anterior usando `kernlab`. **(2 puntos)**

---

### Ejercicio 2 (5 puntos)

2. El conjunto de datos GermanCredit (que se adjunta) es una lista de personas que han pedido un crédito así como si este ha sido concedido o no. Consta de 1000 filas y 62 columnas. La variable objetivo es `Class`. Los clientes con buen riesgo crediticio se etiquetan con “Good” y caso contrario, serán “Bad”. Entre las variables principales están: `Duration` (duración del crédito), `Amount` (monto del crédito), `CheckingAccountStatus.lt.0` (1 si la cuenta corriente tiene saldo negativo), entre otras.  
Más información sobre GermanCredit en el dataset de Kaggle (`uciml/german-credit`) o en UCI Machine Learning Repository.

En la tabla siguiente tenemos un subconjunto tanto del número de filas como de columnas:

| Age | Housing.Own | CheckingAccountStatus.lt.0 | Amount | Duration | Purpose.NewCar | Class |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| Joven | 1 | 0 | 5k | 4y | 0 | Bad |
| Adulto | 0 | 1 | 5k | 4y | 0 | Good |
| Adulto | 1 | 0 | 2k | 1y | 0 | Good |
| Adulto | 0 | 1 | 2k | 2y | 1 | Bad |
| Senior | 1 | 1 | 1k | 1y | 0 | Good |

a) Realiza una iteración del algoritmo ID3. Dibuja el nodo raíz, etiquetado con la variable de mayor ganancia y sus arcos también etiquetados. Escribe todos los cálculos detalladamente, al menos en el cálculo de la primera ganancia. **(2 puntos)**

b) Muestra las tablas con las que continuará el algoritmo ID3 en la siguiente iteración. Asocia a cada tabla el arco en el que se encuentra. **(0.5 puntos)**

c) A partir del conjunto de datos GermanCredits completo, usa las siguientes variables: **(2.5 puntos)**
- `Age`
- `Job.Management.SelfEmp.HighlyQualified`
- `Housing.Rent`
- `Housing.ForFree`
- `Housing.Own`
- `SavingsAccountBonds.500.to.1000`
- `CheckingAccountStatus.lt.0`
- `CheckingAccountStatus.0.to.200`
- `Amount`
- `Duration`
- `Purpose.NewCar`
- `Class`

para entrenar un modelo Rpart usando validación cruzada. Calcula el árbol podado y su accuracy. Compara los accuracy del árbol sin podar y podado. Calcula el árbol podado usando 1-SE (*one standard error rule*). Compara el accuracy de los árboles podados con mínimo `xerror` y 1-SE.

