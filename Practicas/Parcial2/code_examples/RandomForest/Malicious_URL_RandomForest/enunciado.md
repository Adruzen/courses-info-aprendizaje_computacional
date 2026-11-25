# Enunciado — Ejercicio 1 (`2020-09-21 — PARTE ENSAMBLES` / `2018-01-23`)

> **Fuente:** `Examenes/Enunciados - todos examenes.md` — `2020-09-21 — Examen de Aprendizaje Computacional (Clasificadores y Ensambles)` (`PARTE ENSAMBLES — Ejercicio 1`, archivo: `Examen Aprendizaje 21-09-2020.pdf`). *(Nota: exactamente el mismo enunciado aparece también como `Ejercicio 1` en `2018-01-23 — Examen Parte Ensambles`, archivo `Examen  23-01-2019.pdf`.)*

### Ejercicio 1 — URL maliciosa (Random Forest y Stacking)

La URL maliciosa, también conocido como sitio web malicioso, es una amenaza común y grave para la ciberseguridad. La URL maliciosa atraaen a los usuarios confiados a ser víctimas de estafas (monetarías pérdida, robo de información privada e instalación de malware), y causan pérdidas de miles de millones de euros cada año. Por tanto, es necesario detectar y actuar sobre tales amenazas de manera oportuna. Tradicionalmente, esta detección se realiza principalmente mediante el uso de listas negras.. Sin embargo, las listas negras no pueden ser exhaustivas, y carecen de la capacidad para detectar nuevas URL maliciosas generadas. Otra técnica que se esta usando es machine lerarning para clasificar las url entre maliciosas o no. Se pide:

a) Crear un ramdom forest usando el dataset `detect-malicious-URL .csv` ( que podeis encontrar en el campus virtual). Usa validación cruzada para entrenamiento y predicción. Calcula el accuracy.

b) Crea un stacking (por votación y sin pesos) con los clasificadores pobres que considere que mejore o al menos iguale el accuracy del ramdom forest.
