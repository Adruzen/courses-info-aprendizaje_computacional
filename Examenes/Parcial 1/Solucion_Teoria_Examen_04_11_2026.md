# Examen Parcial 1 — Aprendizaje Computacional (04/11/2026)

**Asignatura:** Aprendizaje Computacional  
**Grado:** Doble Grado / Grado en Ingeniería Informática / Matemáticas (Universidad de Málaga)  
**Fecha:** 04 de Noviembre de 2026  

---

## Conjunto de Datos

El conjunto de datos consta de 12 observaciones con dos atributos numéricos $X_1$ y $X_2$, y una clase binaria $Y \in \{-1, +1\}$:

| Obs. | $X_1$ | $X_2$ | $Y$ |
| :---: | :---: | :---: | :---: |
| 1 | -2 | -2 | -1 |
| 2 | -2 | 2 | -1 |
| 3 | 2 | -2 | -1 |
| 4 | 2 | 2 | -1 |
| 5 | -1 | 0 | +1 |
| 6 | 1 | 0 | +1 |
| 7 | 0 | -1 | +1 |
| 8 | 0 | 1 | +1 |
| 9 | -0.5 | -0.5 | +1 |
| 10 | -0.5 | 0.5 | +1 |
| 11 | 0.5 | -0.5 | +1 |
| 12 | 0.5 | 0.5 | +1 |

---

## Parte Teórica 1: Justificación de No Linealidad

### Pregunta 1.2: Justifica por qué no es posible encontrar una frontera de decisión lineal que clasifique correctamente todas las observaciones (0.25 puntos)

> [!tip] Explicación intuitiva y geométrica
> Al observar la gráfica de los puntos en el plano $(X_1, X_2)$, se aprecia claramente la disposición de ambas clases:
> 
> 1. **Los puntos de la clase positiva ($+1$)** están agrupados en el **centro** del plano, formando un anillo/círculo interior alrededor del origen $(0,0)$ (con distancias al origen $\le 1$).
> 2. **Los puntos de la clase negativa ($-1$)** están en las cuatro **esquinas exteriores**: $(-2,-2)$, $(-2,2)$, $(2,-2)$ y $(2,2)$.

**¿Por qué no se puede separar con una recta?**

* Una recta en el plano solo puede dividir el espacio en **dos semiplanos** (un lado y el otro).
* Como los puntos de la clase $+1$ están **completamente rodeados** por los 4 puntos de la clase $-1$ en las cuatro direcciones (arriba, abajo, izquierda y derecha):
  * Cualquier recta que tracemos dejará siempre puntos de la clase $-1$ a ambos lados de la misma, o bien dejará puntos de la clase $+1$ mezclados con puntos de la clase $-1$.
  * Para aislar los puntos del centro se necesitaría una curva cerrada (como una circunferencia o elipse: $X_1^2 + X_2^2 \le r^2$) o al menos 4 rectas distintas, pero **nunca una única recta**.

Por tanto, es imposible encontrar una frontera lineal ($w_1 X_1 + w_2 X_2 + b = 0$) que no cometa errores de clasificación. El conjunto de datos es **no separable linealmente**.

---

## Parte Teórica 2: Problema de Optimización Dual SVM (Kernel RBF)

### Pregunta 1.3: Escribir el problema de optimización dual de una SVM (Kernel RBF, $C=10$, $\gamma=0.5$) usando el conjunto de datos anterior. Considera que los vectores soporte son $X_1 = (-2, -2)$, clase $y_1 = -1$ y $X_5 = (-1, 0)$, clase $y_5 = +1$ (0.75 puntos)

Seguimos exactamente el desarrollo y la notación de los apuntes oficiales de la asignatura (*SVM Desarrollo Teórico*):

### 1. Formulación General del Problema Dual (Lagrangiano Dual)

A partir de la función de Lagrange para optimizar el problema de programación:
$$L = \frac{1}{2} \|w\|^2 - \sum_i \alpha_i [y_i (x_i \cdot w + b) - 1]$$

Imponiendo las condiciones de primer orden:
$$\frac{\partial L}{\partial w} = 0 \implies w = \sum_i \alpha_i y_i x_i \qquad \text{y} \qquad \frac{\partial L}{\partial b} = 0 \implies \sum_i \alpha_i y_i = 0$$

Y sustituyendo $w$ en $L$, se obtiene la **expresión del Lagrangiano dual** que se debe maximizar:
$$L = \sum_i \alpha_i - \frac{1}{2} \sum_i \sum_j \alpha_i \alpha_j y_i y_j K(x_i, x_j)$$

sujeto a las restricciones:
$$\sum_i \alpha_i y_i = 0$$
$$0 \le \alpha_i \le C, \quad \forall i$$

donde para el kernel RBF (Gaussiano):
$$K(x_i, x_j) = \exp(-\gamma \|x_i - x_j\|^2) \quad \text{con } \gamma = 0.5 \text{ y } C = 10$$

---

### 2. Aplicación a nuestro caso concreto

Los dos vectores soporte especificados son:
* Punto $A = x_1 = (-2, -2)^T$ con etiqueta $y_1 = -1$ (multiplicador $\alpha_1$ o $\alpha_A$)
* Punto $B = x_5 = (-1, 0)^T$ con etiqueta $y_5 = +1$ (multiplicador $\alpha_2$ o $\alpha_B$)

Para las demás observaciones que no son vectores soporte, $\alpha_i = 0$.

#### 2.1. Cálculo de los valores del kernel:
* $K(x_1, x_1) = \exp(-0.5 \cdot 0) = 1$
* $K(x_5, x_5) = \exp(-0.5 \cdot 0) = 1$
* Distancia euclídea al cuadrado entre $x_1$ y $x_5$:
  $$\|x_1 - x_5\|^2 = (-2 - (-1))^2 + (-2 - 0)^2 = (-1)^2 + (-2)^2 = 1 + 4 = 5$$
* $K(x_1, x_5) = K(x_5, x_1) = \exp(-0.5 \cdot 5) = \exp(-2.5) = e^{-2.5} \approx 0.082085$

---

### 3. Planteamiento explícito de las dos formas vistas en clase

#### Forma A: Formulación de Optimización Cuadrática (función objetivo dual y restricciones)

$$\max_{\alpha_1, \alpha_2} L(\alpha_1, \alpha_2) = \alpha_1 + \alpha_2 - \frac{1}{2} \left[ \alpha_1^2 \cdot (1) + \alpha_2^2 \cdot (1) + 2 \alpha_1 \alpha_2 (-1)(+1) K(x_1, x_5) \right]$$

$$L(\alpha_1, \alpha_2) = \alpha_1 + \alpha_2 - \frac{1}{2} \alpha_1^2 - \frac{1}{2} \alpha_2^2 + e^{-2.5} \alpha_1 \alpha_2$$

sujeto a:
$$\begin{cases}
-\alpha_1 + \alpha_2 = 0 \iff \alpha_1 = \alpha_2 \\
0 \le \alpha_1 \le 10 \\
0 \le \alpha_2 \le 10
\end{cases}$$

---

#### Forma B: Sistema de Ecuaciones en los Vectores Soporte (Método analítico de apuntes)

En los apuntes de clase (*pág. 3, Sistema de Ecuaciones*), los vectores soporte en el margen satisfacen las ecuaciones activas:
1. $\sum_i \alpha_i y_i = 0$
2. $\sum_i \alpha_i y_i K(x_i, X) + b = +1$ (para puntos con $Y = +1$, en nuestro caso $x_5$)
3. $\sum_i \alpha_i y_i K(x_i, X) + b = -1$ (para puntos con $Y = -1$, en nuestro caso $x_1$)

junto con las restricciones impuestas por la constante de penalización $C = 10$:
$$0 \le \alpha_1 \le C \quad \text{y} \quad 0 \le \alpha_2 \le C \qquad (C = 10)$$

Sustituyendo los valores concretos de $x_1$ y $x_5$:
$$\begin{cases}
-\alpha_1 + \alpha_2 = 0 \\
-\alpha_1 K(x_1, x_5) + \alpha_2 K(x_5, x_5) + b = +1 \implies -\alpha_1 e^{-2.5} + \alpha_2 (1) + b = 1 \\
-\alpha_1 K(x_1, x_1) + \alpha_2 K(x_5, x_1) + b = -1 \implies -\alpha_1 (1) + \alpha_2 e^{-2.5} + b = -1
\end{cases}$$
$$\text{sujeto a: } 0 \le \alpha_1 \le 10, \quad 0 \le \alpha_2 \le 10$$

---

### 4. Solución del Sistema

De la primera ecuación: $\alpha_1 = \alpha_2 = \alpha$. Sustituyendo en las otras dos:
$$\begin{cases}
\alpha(1 - e^{-2.5}) + b = 1 \\
-\alpha(1 - e^{-2.5}) + b = -1
\end{cases}$$

Sumando ambas ecuaciones:
$$2b = 0 \implies b = 0$$

Restando la segunda de la primera:
$$2\alpha(1 - e^{-2.5}) = 2 \implies \alpha = \frac{1}{1 - e^{-2.5}} \approx \frac{1}{1 - 0.082085} \approx \mathbf{1.0894}$$

Comprobación de la cota $C$:
$$0 < 1.0894 \le 10 \quad (\text{cumple } 0 \le \alpha_i \le C)$$

**Solución final:**
$$\alpha_1 = 1.0894, \quad \alpha_2 = 1.0894, \quad b = 0$$

---

## Parte Teórica 3: Algoritmo ID3

### Enunciado: Usa ID3 para encontrar el atributo del nodo raíz a partir del conjunto de datos descrito a continuación (1 punto)

| Obs. | $X_1$ | $X_2$ | $Y$ |
| :---: | :---: | :---: | :---: |
| 3 | 2 | -2 | -1 |
| 4 | 2 | 2 | -1 |
| 5 | -1 | 0 | +1 |
| 6 | 1 | 0 | +1 |
| 7 | 0 | -1 | +1 |

Total de ejemplos: $N = 5$.  
Distribución de clases en el conjunto global $S$:
* $p_+ = P(Y = +1) = \frac{3}{5} = 0.6$ (obs. 5, 6, 7)
* $p_- = P(Y = -1) = \frac{2}{5} = 0.4$ (obs. 3, 4)

---

### 1. Entropía del Conjunto Global $H(S)$

$$H(S) = - \sum_{c \in \{+1, -1\}} p_c \log_2(p_c) = - \left( \frac{3}{5} \log_2\frac{3}{5} + \frac{2}{5} \log_2\frac{2}{5} \right)$$

Calculando con logaritmos base 2:
* $\log_2(0.6) = \frac{\ln(0.6)}{\ln(2)} \approx \frac{-0.510826}{0.693147} \approx -0.736966$
* $\log_2(0.4) = \frac{\ln(0.4)}{\ln(2)} \approx \frac{-0.916291}{0.693147} \approx -1.321928$

$$H(S) = - [0.6 \cdot (-0.736966) + 0.4 \cdot (-1.321928)] = - [-0.442179 - 0.528771] = 0.97095 \text{ bits}$$

---

### 2. Evaluación del Atributo $X_1$

Los valores que toma $X_1$ en el conjunto son:
* $X_1 = 2$: observaciones 3 y 4. Ambas tienen $Y = -1$.
  * Tamaño: $|S_{X_1=2}| = 2$.
  * Clases: 0 de $+1$, 2 de $-1$ (puro).
  * Entropía: $H(S_{X_1=2}) = 0$.
* $X_1 = -1$: observación 5. Tiene $Y = +1$.
  * Tamaño: $|S_{X_1=-1}| = 1$.
  * Clases: 1 de $+1$, 0 de $-1$ (puro).
  * Entropía: $H(S_{X_1=-1}) = 0$.
* $X_1 = 1$: observación 6. Tiene $Y = +1$.
  * Tamaño: $|S_{X_1=1}| = 1$.
  * Clases: 1 de $+1$, 0 de $-1$ (puro).
  * Entropía: $H(S_{X_1=1}) = 0$.
* $X_1 = 0$: observación 7. Tiene $Y = +1$.
  * Tamaño: $|S_{X_1=0}| = 1$.
  * Clases: 1 de $+1$, 0 de $-1$ (puro).
  * Entropía: $H(S_{X_1=0}) = 0$.

#### Entropía Condicional de $X_1$:
$$H(S \mid X_1) = \sum_{v \in \{2, -1, 1, 0\}} \frac{|S_v|}{|S|} H(S_v) = \frac{2}{5}(0) + \frac{1}{5}(0) + \frac{1}{5}(0) + \frac{1}{5}(0) = 0 \text{ bits}$$

#### Ganancia de Información de $X_1$:
$$\operatorname{Gain}(S, X_1) = H(S) - H(S \mid X_1) = 0.97095 - 0 = 0.97095 \text{ bits}$$

---

### 3. Evaluación del Atributo $X_2$

Los valores que toma $X_2$ en el conjunto son:
* $X_2 = -2$: observación 3. Tiene $Y = -1$.
  * Tamaño: $|S_{X_2=-2}| = 1$.
  * Clases: 0 de $+1$, 1 de $-1$ (puro).
  * Entropía: $H(S_{X_2=-2}) = 0$.
* $X_2 = 2$: observación 4. Tiene $Y = -1$.
  * Tamaño: $|S_{X_2=2}| = 1$.
  * Clases: 0 de $+1$, 1 de $-1$ (puro).
  * Entropía: $H(S_{X_2=2}) = 0$.
* $X_2 = 0$: observaciones 5 y 6. Ambas tienen $Y = +1$.
  * Tamaño: $|S_{X_2=0}| = 2$.
  * Clases: 2 de $+1$, 0 de $-1$ (puro).
  * Entropía: $H(S_{X_2=0}) = 0$.
* $X_2 = -1$: observación 7. Tiene $Y = +1$.
  * Tamaño: $|S_{X_2=-1}| = 1$.
  * Clases: 1 de $+1$, 0 de $-1$ (puro).
  * Entropía: $H(S_{X_2=-1}) = 0$.

#### Entropía Condicional de $X_2$:
$$H(S \mid X_2) = \sum_{v \in \{-2, 2, 0, -1\}} \frac{|S_v|}{|S|} H(S_v) = \frac{1}{5}(0) + \frac{1}{5}(0) + \frac{2}{5}(0) + \frac{1}{5}(0) = 0 \text{ bits}$$

#### Ganancia de Información de $X_2$:
$$\operatorname{Gain}(S, X_2) = H(S) - H(S \mid X_2) = 0.97095 - 0 = 0.97095 \text{ bits}$$

---

### 4. Conclusión y Selección del Nodo Raíz

Ambos atributos $X_1$ y $X_2$ particionan el conjunto de datos de forma perfecta (entropía condicional 0 y ganancia máxima igual a $H(S) = 0.97095$ bits).

* **Si se selecciona $X_1$ como nodo raíz:**
  * Si $X_1 = 2 \implies Y = -1$
  * Si $X_1 = -1 \implies Y = +1$
  * Si $X_1 = 1 \implies Y = +1$
  * Si $X_1 = 0 \implies Y = +1$
* **Criterio de parsimonia (número de ramas):**
  * $X_1$ tiene 4 ramas distintas ($2, -1, 1, 0$).
  * $X_2$ tiene 4 ramas distintas ($-2, 2, 0, -1$).
  * En $X_1$, la clase negativa queda completamente agrupada bajo una única rama ($X_1 = 2$). Por tanto, **$X_1$** es la variable preferida y más compacta para el nodo raíz.

