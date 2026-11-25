library(rpart)
data(iris)

# Creamos el árbol usando entropía como criterio de división
fit_info <- rpart(Species ~ Petal.Length, data = iris,
                  method = "class",
                  parms = list(split = "information"),  # usa entropía
                  cp = 0)

# Igual que antes, definimos los subconjuntos
left  <- iris$Petal.Length < 2.45
right <- !left

# Calculamos proporciones por clase
prop_total <- prop.table(table(iris$Species))
prop_left  <- prop.table(table(iris$Species[left]))
prop_right <- prop.table(table(iris$Species[right]))

# Definimos función de entropía
entropy <- function(p) {
  p <- p[p > 0]  # evitar log(0)
  -sum(p * log2(p))
}

# Calculamos entropías
H_parent <- entropy(prop_total)
H_left   <- entropy(prop_left)
H_right  <- entropy(prop_right)

# Entropía ponderada después del split
pL <- sum(left) / nrow(iris)
pR <- 1 - pL
H_after <- pL * H_left + pR * H_right

# Ganancia de información
gain_info <- H_parent - H_after

#  Mostrar resultados
cat("Entropía nodo raíz:", round(H_parent, 4), "\n")
cat("Entropía izquierda:", round(H_left, 4), "\n")
cat("Entropía derecha:", round(H_right, 4), "\n")
cat("Ganancia de información:", round(gain_info, 4), "\n")
