1. Calcular la entropia de la tabla (del atributo de la clasificación)
2. Calculamos la ganancia de cada uno de los atributos de la tabla:
$$
G(S,A) = \sum_{v \in \text{Valores}(S)} \frac{|S_{v}|}{| S |} \cdot E(S_{v})
$$
3. Elegimos un atributo de mayor ganancia y hacemos un nodo de árbol que tiene tantos hijos como valores posibles de atributo con mayor ganancia.
4. Para cada hijo de ese nodo construimos nueva tabla, eliminando las filas con otros valores del atributo
5. en cada tabla-hijo comprobamos si hemos cumplido con la condición de parada (p. ej. 75% valores con el mismo valor). En ese caso ponemos el nodo-hoja. Si no, repetimos el algoritmo con la nueva tabla.

