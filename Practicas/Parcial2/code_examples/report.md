# Отчёт о сборе практических примеров по теме «Мультиклассификаторы и ансамбли» (Часть 2)

## 1. Общие итоги

В ходе полного аудита каталога `FIcheros de CV sin sortear/` (включая `Multiclasificadores (Ensemble)/`, `Ficheros fuera de los temas principales/` и `Clasificadores/`), а также дополнительной проверки `Practicas/Part 2/`, `Examenes/Parte 2/` и `Examenes/04-02-2026/` были собраны **все 18 уникальных R-скриптов преподавателя / курса**, реализующих методы ансамблирования и мультиклассификаторов.

Все скрипты и относящиеся к ним файлы данных скопированы в `Practicas/Parcial2/code_examples/` **без каких-либо изменений содержимого** (побайтовая идентичность подтверждена по SHA-256). При этом многоалгоритмные примеры продублированы в **каждую соответствующую тематическую папку**, чтобы внутри любой темы можно было сразу увидеть весь референсный код в стиле преподавателя. Оригинальные файлы в `FIcheros de CV sin sortear/` и `Practicas/Part 2/` не перемещались и не изменялись.

### Структура тематических папок (`5` тем, `21` папка примеров, `18` уникальных скриптов)

| Тема / Папка | Примеров | Что внутри |
| :--- | :---: | :--- |
| `Bagging/` | 3 | `Mtcars_Bagging_ipred`, `Titanic_Bagging_adabag`, `Ionosphere_Bagging_Boosting_Stacking_Caret` (`treebag`) |
| `Boosting/` | 6 | `Iris_AdaBoost_M1_adabag`, `Iris_AdaBoost_M1_con_SVM` (+ `solution_profe_borrador.R`), `Mtcars_Gradient_Boosting_gbm`, `Titanic_Boosting_adabag`, `Wine_Quality_RF_y_AdaBoost` (`adabag::boosting`), `Ionosphere_Bagging_Boosting_Stacking_Caret` (`C5.0`, `gbm`) |
| `Ensemble_Manual/` | 1 | `Recidiva_Ensemble_Perceptron_Votacion` |
| `RandomForest/` | 6 | `Kyphosis_RandomForest`, `Malicious_URL_RandomForest`, `Titanic_RandomForest`, `Titanic_Simular_RF_con_Rpart`, `Wine_Quality_RF_y_AdaBoost` (`randomForest`), `Ionosphere_Bagging_Boosting_Stacking_Caret` (`rf`) |
| `Stacking/` | 5 | `Iris_Stacking_Nnet_Incompleto`, `Iris_Stacking_Rpart_Nnet_SVM_Manual`, `Iris_Stacking_SVM_Caret`, `Titanic_Stacking_Rpart_SVM_Capa2_Rpart`, `Ionosphere_Bagging_Boosting_Stacking_Caret` (`caretList`) |

### Сводная таблица всех собранных примеров

| № | Папка в `code_examples/` | Исходный файл | Алгоритм и пакеты | Данные | `enunciado.md` |
| :-: | :--- | :--- | :--- | :--- | :---: |
| 1 | `Bagging/Mtcars_Bagging_ipred` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Bagging.R` | Bagging для регрессии (`ipred::bagging`, `rpart`, `caret`) | Встроенный `mtcars` | Нет (шаблон) |
| 2 | `Bagging/Titanic_Bagging_adabag` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Boosting-Bagging-Titanic/Bagging - Titanic.R` | Bagging для классификации (`adabag::bagging`, `rpart`) | `train.csv` (скопирован) | Нет (пример) |
| 3 | `Bagging/Ionosphere_Bagging_Boosting_Stacking_Caret` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Bagging Boosting con Caret.R` | Сравнение `treebag`, `rf`, `C5.0`, `gbm`, `caretList` (`caret`, `caretEnsemble`) | Встроенный `Ionosphere` (`mlbench`) | Нет (шаблон) |
| 4 | `Boosting/Iris_AdaBoost_M1_adabag` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Adaboost.M1.R` | AdaBoost.M1 на деревьях глубины 1 (`adabag::boosting`, `caret`, `ggplot2`) | Встроенный `iris` | Нет (шаблон) |
| 5 | `Boosting/Iris_AdaBoost_M1_con_SVM` | `FIcheros de CV sin sortear/.../Adaboost.M1 con SVM.R` **+** `Practicas/Part 2/AdaBoost/Solucion del profe.R` (`solution_profe_borrador.R`) | Ручной AdaBoost.M1 с 10 линейными SVM (`kernlab::ksvm`) | Встроенный `iris` + `alpha y test de Problema 2` (скопирован) | **Да** (`2025-12-01`, Проблема 2) |
| 6 | `Boosting/Mtcars_Gradient_Boosting_gbm` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/boosting.R` | Gradient Boosting (`gbm`, CV) | Встроенный `mtcars` | Нет (шаблон) |
| 7 | `Boosting/Titanic_Boosting_adabag` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Boosting-Bagging-Titanic/Boosting-Titanic.R` | AdaBoost.M1 (`adabag::boosting`, `errorevol`) | `train.csv` (скопирован) | Нет (пример) |
| 8 | `Boosting/Wine_Quality_RF_y_AdaBoost` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/calidad vinos.R` | Random Forest + `importance()` + AdaBoost.M1 (`adabag::boosting`) | `winequality-red.csv` и `wine+quality.zip` (скопированы) | **Да** (`2026-02-04`, Проблема 1) |
| 9 | `Boosting/Ionosphere_Bagging_Boosting_Stacking_Caret` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Bagging Boosting con Caret.R` | Сравнение `C5.0`, `gbm`, `treebag`, `rf`, `caretList` (`caret`, `caretEnsemble`) | Встроенный `Ionosphere` (`mlbench`) | Нет (шаблон) |
| 10 | `Ensemble_Manual/Recidiva_Ensemble_Perceptron_Votacion` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/ensemblePerceptron.R` | Ручной ансамбль перцептронов с голосованием (`nnet`) | `datos_icb.txt` (скопирован) | **Да** (`2018-01-24`, Упр. 1) |
| 11 | `RandomForest/Kyphosis_RandomForest` | `FIcheros de CV sin sortear/Ficheros fuera de los temas principales/Examen Parte 2 01-12-2025/kyphosys con Random forest.R` | Random Forest + `importance()` (`randomForest`, `rpart`) | Встроенный `kyphosis` (`rpart`) | **Да** (`2025-12-01`, Проблема 1) |
| 12 | `RandomForest/Malicious_URL_RandomForest` | `FIcheros de CV sin sortear/Ficheros fuera de los temas principales/Examen Aprendizaje 21-09-2020.pdf/url maliciosa.R` | Random Forest + `importance()` (`randomForest`) | `detect-malicious-URL.csv` (скопирован) | **Да** (`2020-09-21` / `2018-01-23`, Упр. 1) |
| 13 | `RandomForest/Titanic_RandomForest` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/titanic con RF.r` | Random Forest + `importance()` + `varImpPlot()` | `train.csv` (скопирован) | Нет (пример) |
| 14 | `RandomForest/Titanic_Simular_RF_con_Rpart` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Simular RF con RPART.R` | Ручная симуляция RF через `rpart` и отбор $\sqrt{p}$ признаков | `train.csv` (скопирован) | Нет (пример) |
| 15 | `RandomForest/Wine_Quality_RF_y_AdaBoost` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/calidad vinos.R` | Random Forest + `importance()` + AdaBoost.M1 (`adabag::boosting`) | `winequality-red.csv` и `wine+quality.zip` (скопированы) | **Да** (`2026-02-04`, Проблема 1) |
| 16 | `RandomForest/Ionosphere_Bagging_Boosting_Stacking_Caret` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Bagging Boosting con Caret.R` | Сравнение `rf`, `treebag`, `C5.0`, `gbm`, `caretList` (`caret`, `caretEnsemble`) | Встроенный `Ionosphere` (`mlbench`) | Нет (шаблон) |
| 17 | `Stacking/Iris_Stacking_Nnet_Incompleto` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/ensemble.R` | Заготовка 2-уровневого Stacking (слой 1 на `nnet`) | Встроенный `iris` | Нет (черновик) |
| 18 | `Stacking/Iris_Stacking_Rpart_Nnet_SVM_Manual` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Stacking con SVM.R` | Ручной Stacking: `nnet` + `rpart` $\to$ мета-модель `svm` (`e1071`) | Встроенный `iris` | Нет (пример) |
| 19 | `Stacking/Iris_Stacking_SVM_Caret` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Stacking con SVM CARET.R.txt` | Stacking в `caretEnsemble`: `caretList("nnet", "svmRadial")` $\to$ `caretStack("svmRadial")` | Встроенный `iris` | Нет (пример) |
| 20 | `Stacking/Titanic_Stacking_Rpart_SVM_Capa2_Rpart` | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Stacking rpart y Svm + 2 capa RPART.R` | Ручной Stacking: `rpart` + `svm` (`e1071`) $\to$ мета-модель `rpart` | `train.csv` (скопирован из `train - Stacking con clases Archivo.csv`) | Нет (пример) |
| 21 | `Stacking/Ionosphere_Bagging_Boosting_Stacking_Caret` *(дубль)* | `FIcheros de CV sin sortear/Multiclasificadores (Ensemble)/Programas/Bagging Boosting con Caret.R` | Сравнение `caretList`, `C5.0`, `gbm`, `treebag`, `rf` (`caret`, `caretEnsemble`) | Встроенный `Ionosphere` (`mlbench`) | Нет (шаблон) |

---

## 2. Решения по дублированию и классификации неоднозначных файлов

1. **Дублирование многоалгоритмных файлов по всем релевантным темам:**
   - **`calidad vinos.R` (`Wine_Quality_RF_y_AdaBoost`):** содержит как `randomForest`, так и `adabag::boosting` (AdaBoost.M1), поэтому полный набор файлов (`solution.R`, `enunciado.md`, `winequality-red.csv`, `wine+quality.zip`) размещён одновременно в **`RandomForest/`** и в **`Boosting/`**.
   - **`Bagging Boosting con Caret.R` (`Ionosphere_Bagging_Boosting_Stacking_Caret`):** содержит `treebag` (Bagging), `C5.0` и `gbm` (Boosting), `rf` (Random Forest) и `caretList` (подготовка к Stacking). Вместо отдельной папки `Comparacion_Caret/` скрипт продублирован во все **4** соответствующие темы (`Bagging/`, `Boosting/`, `RandomForest/`, `Stacking/`), а папка `Comparacion_Caret/` удалена.
2. **`Simular RF con RPART.R` $\to$ `RandomForest/Titanic_Simular_RF_con_Rpart/`:**  
   Технически использует деревья `rpart`, но методически реализует именно алгоритм **Random Forest** (выбор `round(sqrt(length(atributos)))` случайных признаков на каждое из 10 деревьев и бутстрэп/подвыборка объектов).
3. **`ensemblePerceptron.R` $\to$ `Ensemble_Manual/Recidiva_Ensemble_Perceptron_Votacion/`:**  
   Реализует ручной ансамбль из 10 перцептронов `nnet` с голосованием большинством без пакетов `ipred`/`adabag`/`randomForest` и соответствует Упражнению 1 экзамена `24-01-2018`.
4. **`ensemble.R` $\to$ `Stacking/Iris_Stacking_Nnet_Incompleto/`:**  
   Обучает `nnet` на `iris`, получает предсказания на `train` и формирует `datosirisRart` (заменяя истинную метку `Species` на `predicionNnet` для 2-го слоя `rpart`), но обрывается до обучения второго слоя. Это незавершённый черновик ручного Stacking (того же типа, что `Stacking con SVM.R`).
5. **`Stacking con SVM CARET.R.txt`:**  
   Файл имел расширение `.R.txt` — при копировании переименован в `solution.R` в `Stacking/Iris_Stacking_SVM_Caret/`.

---

## 3. Результаты дополнительного поиска в `Practicas/Part 2/`, `Examenes/Parte 2/` и `Examenes/04-02-2026/`

### 3.1. Проверка `Practicas/Part 2/`
- **Точные дубликаты (уже присутствовали в `FIcheros de CV sin sortear/`):**
  - `Adaboost.M1.R` (`5a8ea1d31ead`) = `Programas/Adaboost.M1.R`
  - `Bagging Boosting con Caret.R` (`cf9fcc92f00b`) = `Programas/Bagging Boosting con Caret.R`
  - `boosting.R` (`e54d1a55671f`) = `Programas/boosting.R`
  - `Stacking con SVM CARET.R` (`a45d17bd6df2`) = `Programas/Stacking con SVM CARET.R.txt`
  - `Stacking con SVM.R` (`027e6f35f21c`) = `Programas/Stacking con SVM.R`
  - `AdaBoost/alpha y test de Problema 2` (`06c96a12cf3d`) = `Examen Parte 2 01-12-2025/alpha y test de Problema 2`
- **Найден новый файл преподавателя:**
  - `Practicas/Part 2/AdaBoost/Solucion del profe.R` (`67fd69494336`) — более ранний черновик решения Проблемы 2 от преподавателя (с комментарием `# Nota: solución es incompleta (el profesor ha dicho algo sobre "faltan votos"?)`, без умножения на `alpha` и с опечаткой `trainSVM <-- datosiris[indicesSVM, ]`). Скопирован без изменений в **`Boosting/Iris_AdaBoost_M1_con_SVM/solution_profe_borrador.R`** рядом с более поздней версией `Adaboost.M1 con SVM.R` (`solution.R`).
- **Исключённый студенческий/ассистентский файл:**
  - `Practicas/Part 2/AdaBoost/problema_2_solucion.R` (`3316dfa8a6ef`) — подробное студенческое/учебное решение, написанное при подготовке практики, а не оригинальный код преподавателя, поэтому в референсную базу `code_examples/` не включалось.

### 3.2. Проверка `Examenes/Parte 2/` и `Examenes/04-02-2026/`
- `Examenes/Parte 2/RandomForest/Malicios URL/url maliciosa - solucion del professor.R` (`8ecb54f58679`) и `detect-malicious-URL.csv` (`df2e4c05dde6`) — точные дубликаты файлов из `FIcheros de CV sin sortear/Ficheros fuera de los temas principales/Examen Aprendizaje 21-09-2020.pdf/`.
- `Examenes/04-02-2026/wine+quality-profesor.R` (`af5c09d51039`) — точный дубликат `wine+quality.R.txt` (одиночное дерево `rpart` с `1-SE`, не ансамбль).
- `Examenes/04-02-2026/mahWine.r` (`c89dc1269ed4`) — учебное/студенческое решение с одиночным деревом `rpart` (не ансамбль и не код преподавателя).

---

## 4. Проблемы с поиском условий (`enunciado.md`) и полнотой решений

### 4.1. Примеры без экзаменационного условия
Для следующих учебных шаблонов и примеров с занятий в `Examenes/Enunciados - todos examenes.md` нет отдельного экзаменационного условия:
- `Bagging/Mtcars_Bagging_ipred` (`Bagging.R`), `Boosting/Mtcars_Gradient_Boosting_gbm` (`boosting.R`), `Boosting/Iris_AdaBoost_M1_adabag` (`Adaboost.M1.R`), `Ionosphere_Bagging_Boosting_Stacking_Caret` (`Bagging Boosting con Caret.R`). *(Примечание: `Adaboost.M1.R` полезен как шаблон для п. 2–3 Проблемы 2 экзамена `2025-12-01` на `iris`.)*
- Учебные примеры по `Titanic`: `Titanic_Bagging_adabag`, `Titanic_Boosting_adabag`, `Titanic_RandomForest`, `Titanic_Simular_RF_con_Rpart`, `Titanic_Stacking_Rpart_SVM_Capa2_Rpart`.
- Учебные примеры Stacking на `iris`: `Iris_Stacking_Nnet_Incompleto`, `Iris_Stacking_Rpart_Nnet_SVM_Manual`, `Iris_Stacking_SVM_Caret`.

### 4.2. Неполные решения экзаменационных задач
- **`RandomForest/Malicious_URL_RandomForest` (`url maliciosa.R`):** решает только пункт **a)** (Random Forest по `label ~ url`), пункт **b)** (Stacking без весов) отсутствует.
- **`RandomForest/Kyphosis_RandomForest` (`kyphosys con Random forest.R`):** реализует только сравнение с Random Forest и `importance()`, тогда как первая часть Проблемы 1 экзамена `2025-12-01` (ансамбль из 3 перцептронов `nnet` с голосованием) отсутствует.
- **`Ensemble_Manual/Recidiva_Ensemble_Perceptron_Votacion` (`ensemblePerceptron.R`):** реализует только пункт **a)** (`nnet`) Упражнения 1 экзамена `2018-01-24`, без пунктов **b)** (`rpart`) и **c)**.
- **`Boosting/Iris_AdaBoost_M1_con_SVM` (`Adaboost.M1 con SVM.R` + `solution_profe_borrador.R`):** покрывает пункты **4–5** Проблемы 2 (`2025-12-01`), а пункты 2–3 (`adabag::boosting` с CV) вынесены преподавателем в шаблон `Adaboost.M1.R`.

### 4.3. Экзаменационные задачи по ансамблям без готового кода в репозитории
В `Examenes/Enunciados - todos examenes.md` отсутствуют готовые решения в `FIcheros de CV sin sortear/` и `Practicas/Part 2/` для:
- `2024-12-11` — Проблема 3 (DDoS-трафик `Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv` с Random Forest и фильтром `MeanDecreaseGini > 7`; датасет также отсутствует);
- `2022-02-03` — Упр. 3 (ручной Boosting на 2D-графике) и Упр. 4 (ансамбль 3 SVM с полиномиальным ядром на `Kyphosis`);
- `2022-01-19` — Упр. 1–3 (ручной Boosting, `importance` в RF, ансамбль 2 деревьев `rpart` vs `AdaBoost` на `Kyphosis`);
- `2018-01-23` — Упр. 2–3 и `2018-01-24` — Упр. 2–3 (ручной Boosting на сетке 100×100, `importance` и анализ кода `randomForest`);
- `2015-01-22` — Упр. 5–6.

---

## 5. Технические замечания по данным и исходному коду (файлы НЕ менялись)

1. **Жёсткие Windows-пути к данным:** в 8 скриптах прописаны пути `"C:/Users/Usuario_UMA/Downloads/..."` или `"C:/train.csv"`. Сами файлы данных лежат рядом в папках примеров.
2. **Данные для `Wine_Quality_RF_y_AdaBoost`:** в `FIcheros de CV sin sortear/` был только архив `wine+quality.zip`, а распакованный `winequality-red.csv` взят из `Examenes/04-02-2026/` — в обе копии (`RandomForest/` и `Boosting/`) положены оба файла.
3. **Идентификация `train - Stacking con clases Archivo.csv`:** по SHA-256 (`7d118fef8b6c`) побайтово совпадает с Kaggle Titanic `train.csv`; скопирован как `train.csv`.
4. **Бинарный файл `alpha y test de Problema 2`:** бинарный R-файл (`load("alpha y test de Problema 2")`), содержащий `alpha`, `test1`, `test2`. Скрипт `Adaboost.M1 con SVM.R` не вызывает `load(...)` и объединяет `setosa` и `virginica` в `"-1"` вместо фильтрации только `virginica` и `versicolor`.
5. **Пропущенные библиотеки и опечатки в оригиналах:**
   - `titanic con RF.r`: не загружает `library(randomForest)` (только `rpart`) и берёт срез `data_titanic[1:10,]`.
   - `calidad vinos.R`: вызывает `confusionMatrix(...)` без `library(caret)`.
   - `Stacking con SVM CARET.R.txt`: содержит несуществующий `library(ins)`.
   - `Solucion del profe.R` (`solution_profe_borrador.R`): содержит `trainSVM <-- datosiris[indicesSVM, ]` (минус после `<-`, инвертирующий признаки!) и обрывается до умножения на `alpha`.
   - `ensemblePerceptron.R`: `1:numeroPerceptrones-1` даёт `0:9`, внутри цикла обучает на `dtrain` вместо `dtrain1`, а голоса суммирует по всему вектору теста сразу.
   - `Simular RF con RPART.R`: присвоение `data_titanic2$Survived <- as.factor(data_titanic$Survived)` не совпадает по числу строк.
   - `Stacking rpart y Svm + 2 capa RPART.R`: использует `data_titanic[1:10,]` и `type="vector"`.

---

## 6. Проверенные и исключённые файлы (не являются ансамблями)

- `Ficheros fuera de los temas principales/Examen 2ª Convocatoria Ordinaria 04-02-2026/wine+quality.R.txt` (и `Examenes/04-02-2026/wine+quality-profesor.R`) — используют **только одно дерево `rpart`** с правилом `1-SE`.
- `Ficheros fuera de los temas principales/Tres en Raya/Solucion Problema Tres en Raya.txt` — обучает по отдельности одиночные `rpart`, `nnet` и `svm`.
- `Ficheros fuera de los temas principales/GermanCredit/`, `Tune Con Rpart/` и все скрипты в `Clasificadores/` — одиночные модели из Части 1 курса или тюнинг одиночной модели через `caret::train`.
