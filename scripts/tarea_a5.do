* A5 — Do-file de limpieza y descriptivos en Stata
* Módulo IV · Semana 12 · **Actividad formativa — sin nota, entrega obligatoria
* Fundamentos de Programación para Análisis Económico · UdeC-EAN


* Cambio de directorio al personal
cd "C:\Users\anton\Desktop\U\Semestre 8\Fundamentos de Programacion\Tareas\A5"

* Confirmar directorio
pwd

* Confirmar que los datos se encuentra en el directorio
confirm file "data/raw/casen_reducido.csv"
confirm file "data/processed/casen.dta"

* ============================================================
* 1. Encabezado y bitácora
* ============================================================

* ============================================================
* A5 — Limpieza y descriptivos de CASEN
* Autor: [Tomás Troncoso]      Fecha: [2026-11-17]
* ============================================================

clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_a5.log", replace text

* ============================================================
* 2. Carga los datos
* ============================================================

import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe
summarize

* ============================================================
* 3. Crea variables con `generate` y `replace`
* ============================================================

* La experiencia potencial de Mincer
generate experiencia   = edad - educ - 6         // Nueva Variable
replace  experiencia   = 0 if experiencia < 0    // modificar la que ya existe

generate mujer = (genero == "F")
tabulate mujer

* ============================================================
* 4. Etiqueta (la cultura de Stata)
* ============================================================

label variable experiencia "Experiencia potencial (años)"

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl
tabulate mujer

* ============================================================
* 5. Cuidado con los missing
* ============================================================

count if missing(ingreso)

* Resultado de 5 personas sin datos en ingreso.

summarize ingreso

* Resultados -> Obs: 55 

count if ingreso > 500000

* Resultados -> 46

* Comentario: 
* En Stata, el missing (.) es un número más grande que cualquier otro,  así que "count if ingreso> 500000" las incluye.

* Por otro lado, "summarize ingreso" excluye automáticamente los NAs (.), ya que los comandos estadísticos de Stata vienen programados por defecto para operar únicamente sobre observaciones válidas.

* Para que "count if" pueda ser valido hay que seguir la siguiente regla:
*   Regla: toda condición con > o >= sobre una variable con missing lleva
*   & !missing(variable).

count if ingreso > 500000 & !missing(ingreso)

* Resultados -> 41: omitiendo los NAs presentes

* ============================================================
* 6. Descriptivos
* ============================================================

* summarize de las variables numéricas
summarize ingreso educ edad experiencia


*    Variable |        Obs        Mean    Std. dev.       Min        Max
*-------------+---------------------------------------------------------
*     ingreso |         55    655290.9    209912.4     180000    1093000
*        educ |         60    12.73333    3.328697          6         20
*        edad |         60    44.51667    15.15959         20         70
* experiencia |         60    25.78333     15.3182          0         53



* tabulate de una categórica (`sector` o `region`)
tabulate sector


*       sector |      Freq.     Percent        Cum.
*--------------+-----------------------------------
*  Agricultura |         13       21.67       21.67
*     Comercio |          6       10.00       31.67
* Construcción |          5        8.33       40.00
*    Educación |          8       13.33       53.33
*    Industria |         11       18.33       71.67
*    Servicios |         17       28.33      100.00
*--------------+-----------------------------------
*        Total |         60      100.00



* Un `tabulate` cruzado o un `summarize ... if` por grupo
tabulate sector mujer, row

*              |         mujer
*       sector |    Hombre      Mujer |     Total
*--------------+----------------------+----------
*  Agricultura |         6          7 |        13 
*              |     46.15      53.85 |    100.00 
*--------------+----------------------+----------
*     Comercio |         2          4 |         6 
*              |     33.33      66.67 |    100.00 
*--------------+----------------------+----------
* Construcción |         3          2 |         5 
*              |     60.00      40.00 |    100.00 
*--------------+----------------------+----------
*    Educación |         3          5 |         8 
*              |     37.50      62.50 |    100.00 
*--------------+----------------------+----------
*    Industria |         7          4 |        11 
*              |     63.64      36.36 |    100.00 
*--------------+----------------------+----------
*    Servicios |        10          7 |        17 
*              |     58.82      41.18 |    100.00 
*--------------+----------------------+----------
*        Total |        31         29 |        60 
*              |     51.67      48.33 |    100.00



* `correlate` entre `ingreso`, `educ` y `experiencia`.
correlate ingreso educ experiencia

* Resultados: Con obs = 55

*             |  ingreso     educ experi~a
*-------------+---------------------------
*     ingreso |   1.0000
*        educ |   0.6767   1.0000
* experiencia |  -0.0875  -0.1171   1.0000



* guarda un resultado con `scalar`

summarize ingreso
scalar media_ingreso = r(mean)
display "El ingreso promedio de la muestra: " %9.0fc media_ingreso

summarize ingreso if genero == "F"
scalar media_f = r(mean)
summarize ingreso if genero == "M"
scalar media_m = r(mean)
display "Brecha de ingreso medio (M - F): " %9.0fc media_m - media_f

scalar list media_ingreso
scalar list media_f media_m


* ============================================================
* 7. Cierra la bitácora e interpreta
* ============================================================

log close

* Interpretación final: 
* El ingreso promedio es de $655.291 pesos, existiendo una brecha favorable 
* hacia los hombres, quienes perciben en promedio $37.311 pesos más que las mujeres. 
* Por otro lado, el sector Servicios es el más representativo con un 28,33%.
* Finalmente, un mayor nivel educativo se asocia positivamente con mayores 
* ingresos (correlación de 0,6767), mientras que la experiencia potencial muestra 
* una leve asociación negativa con el ingreso en esta muestra.
