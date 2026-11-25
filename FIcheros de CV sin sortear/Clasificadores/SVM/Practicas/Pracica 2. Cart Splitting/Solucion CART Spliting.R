datos <- data.frame(
  Superficie = c(50, 60, 70, 80, 90, 100, 110, 120),
  Precio = c(100, 110, 120, 130, 140, 150, 160, 170)
)

rss <- function(y) {
  
  media <- mean(y)
  
  sum((y - media)^2)
}

rss(c(100, 110, 120))

mejor_corte <- function(datos, variable, objetivo) {
  
  x <- datos[[variable]]
  y <- datos[[objetivo]]
  print (x)
  # Valores ordenados
  valores <- sort(unique(x))
  
  # Puntos de corte intermedios
  cortes <- (valores[-1] + valores[-length(valores)]) / 2
  
  resultados <- data.frame(
    corte = cortes,
    rss_izquierda = NA,
    rss_derecha = NA,
    rss_total = NA
  )
  
  for (i in seq_along(cortes)) {
    
    corte <- cortes[i]
    
    izquierda <- y[x <= corte]
    derecha <- y[x > corte]
    
    rss_izq <- rss(izquierda)
    rss_der <- rss(derecha)
    
    resultados$rss_izquierda[i] <- rss_izq
    resultados$rss_derecha[i] <- rss_der
    resultados$rss_total[i] <- rss_izq + rss_der
  }
  
  resultados
}
resultados <- mejor_corte(
  datos,
  "Superficie",
  "Precio"
)
print(resultados)

which.min(resultados$rss_total)
resultados[4, ]
