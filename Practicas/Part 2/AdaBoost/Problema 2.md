# Problema 2: Variante de AdaBoost.M1 con SVM como clasificadores débiles

> **Asignatura**: Aprendizaje Computacional — Universidad de Málaga (UMA)  
> **Fecha de examen / referencia**: 01 de diciembre de 2025  

---

## Enunciado

Se desea implementar una variante del algoritmo **AdaBoost.M1** utilizando **máquinas de vectores de soporte (SVM)** como clasificadores débiles, en lugar de los árboles de decisión habitualmente utilizados.

Por simplicidad, vamos a usar los pesos ($\alpha$) que se adjuntan en el fichero `alpha y test de Problema 2`.

El dataset que vamos a utilizar es `iris`, transformándolo de forma que tenga solo 2 clases (`virginica` con valor **-1** y `versicolor` con valor **1**).

En cuanto a los SVM que vamos a usar como clasificadores débiles, los vamos a entrenar con el **kernel lineal** y **bajo costo** (`cost = 0.1`) y un subconjunto de entrenamiento diferente para cada SVM.

La predicción se realizará con los datos `test1` y `test2` (que se encuentran en el fichero aludido anteriormente) para todos los SVM. La predicción final será la predicción de los clasificadores débiles multiplicados por los pesos ($\alpha$) obtenidos del fichero `alpha y test de problema 2`. El número de SVM que vamos a usar en el ensamble es de **10**.

### Se pide:

1. **Realizar el preprocesamiento de iris** tal y como se indica en la descripción del problema. *(0.25 puntos)*
2. **Entrenar un clasificador boosting**, usando validación cruzada. El número de clasificadores débiles es 10. *(0.75 puntos)*
3. **Realiza una predicción con el conjunto de test y muestra el accuracy.** Muestra los pesos de instancias (*weights*) y dibuja unos de los árboles (por ejemplo, el primero). *(0.75 puntos)*
4. **Entrena el ensemble** tal y como se indica en la descripción del problema. *(2 puntos)*
5. **Realiza una predicción del ensamble anterior** usando `test1` y `test2`. Muestra la predicción. *(1 punto)*
6. **Comenta los resultados obtenidos y cualquier suposición** que hayas hecho en el desarrollo del problema. Añade el comentario en el fichero `.R` del ejercicio. *(0.25 puntos)*
