library(rpart)
data(iris)

# Creamos el árbol completo sin poda
fit <- rpart(Species ~ Petal.Length, data = iris, method = "class", cp = 0)

rpart.plot(fit)


# Dividimos los datos como lo hace el primer split
left  <- iris$Petal.Length < 2.45
right <- !left

# Calculamos proporciones de clases en cada grupo
prop_total <- prop.table(table(iris$Species))
prop_left  <- prop.table(table(iris$Species[left]))
prop_right <- prop.table(table(iris$Species[right]))

# Calculamos índice de Gini en cada nodo
gini <- function(p) 1 - sum(p^2)
gini_parent <- gini(prop_total)
gini_left   <- gini(prop_left)
gini_right  <- gini(prop_right)

# Calculamos impureza ponderada después del split
pL <- sum(left) / nrow(iris)
pR <- 1 - pL
gini_after <- pL * gini_left + pR * gini_right

# Ganancia (reducción de impureza)
gain <- gini_parent - gini_after

# Mostramos resultados
cat("Gini nodo raíz:", round(gini_parent, 4), "\n")
cat("Gini izquierda:", round(gini_left, 4), "\n")
cat("Gini derecha:", round(gini_right, 4), "\n")
cat("Reducción de impureza (gain):", round(gain, 4), "\n")
