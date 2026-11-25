# Enunciado — Ejercicio 1 (`2018-01-24 — Examen Parte 3`)

> **Fuente:** `Examenes/Enunciados - todos examenes.md` (cabecera del examen: `Aprendizaje Computacional` — `24 de Enero de 2018` — `PARTE 3`, archivo original: `Exemen Parte 3 24-01-2018.pdf`).

### Ejercicio 1 — Ensemble (perceptrón multicapa y rpart) en recidiva

Un ensemble consiste en entrenar una serie de clasificadores pobres (por ejemplo, arboles de decisión o perceptron multicapa) con un subconjunto escogido aleatoriamente del dataset. Se realiza una predicción con cada uno de los clasificadores y se obtiene como salida del ensemble la clase más votada (es decir, la clase con mayor número de ocurrencias).

a) Realiza un programa en R que implemente el algoritmo descrito usando perceptron multicapa (busca el número más adecuado de neuronas en la capa oculta). Usa el dataset de la recidiva.

b) Modifica el programa anterior usando arboles de decisión como el clasificador pobre. Usa el mismo dataset que en el apartado anterior.

c) Compara ambos algoritmos. ¿Por cuál de ellos te decidirías?

**Sugerencia:**

Para poder manjar una lista de clasificadores puedes usar el código siguiente:

```r
library(rpart)
df<-data.frame(x=c(1,2,3,3,3), y=factor(c("a", "a", "b", "a",
"b")),z=c(5,4,4,2,5))

mytree1<-rpart(y ~ x+z , data = df, minbucket = 1, minsplit=1)
mytree2<-rpart(y ~ x+z , data = df, minbucket = 1, minsplit=2)
mytree3<-rpart(y ~ x+z , data = df, minbucket = 1, minsplit=3)

lista1<- list(mytree1, mytree2)
lista2<- list(mytree3)
w <- c(lista1,lista2)
w[[1]]
plot(w[[3]])
```

Dicho código crea tres clasificadores y dos listas que concatena en una única lista. `w[[1]]` hace referencia a `mytree1` y `plot(w[[3]])` dibuja el árbol `mytree3`.
