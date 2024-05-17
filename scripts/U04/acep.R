# Cargamos la librería
require(ACEP)

# Cargamos la base de notas de la Revista Puerto con la función acep_load_base()
rev_puerto <- acep_load_base(acep_bases$rp_mdp) |> tibble::tibble()

# Cargamos el diccionario de conflictos de SISMOS
dicc_confl_sismos <- acep_load_base(acep_diccionarios$dicc_confl_sismos)

# Con la función acep_frec() contamos la frecuencia de palabras de cada nota
# y creamos una nueva columna llamada  n_palabras
rev_puerto$n_palabras <- acep_frec(rev_puerto$nota)

# Imprimimos en pantalla la base con la nueva columna de frecuencia de palabras
head(rev_puerto)

# Ahora con la función acep_count() contamos la frecuencia de menciones de
# términos del diccionario de conflictividad de SISMOS de cada nota y
# creamos una nueva columna llamada  conflictos.
rev_puerto$conflictos <- acep_count(rev_puerto$nota, dicc_confl_sismos)

# Imprimimos en pantalla la base con la nueva columna de
# menciones del diccionario de conflictividad
head(rev_puerto)

# Ahora con la función acep_int() calculamos un índice de intensidad de
# la conflictividad y creamos una nueva columna llamada  intensidad
rev_puerto$intensidad <- acep_int(
  rev_puerto$conflictos,
  rev_puerto$n_palabras,
  3)

# Imprimimos en pantalla la base con la nueva columna de intensidad
head(rev_puerto)

# Ahora con la función acep_db() aplicamos las tres funciones en un solo paso
rp_procesada <- acep_db(rev_puerto, rev_puerto$nota, dicc_confl_sismos, 3)

# Imprimimos en pantalla la base con las tres columna creadas
head(rp_procesada)

# Ahora con la función acep_sst() elaboramos un resumen estadístico
rp_re <- acep_sst(rp_procesada[, c("fecha", "n_palabras", "conflictos", "intensidad")], st = "anio", u = 4)

# Imprimimos en pantalla la base con las métricas de conflictividad
head(rp_re)

# Ahora con la función acep_plot_st() elaboramos un gráfico de barras
# con menciones del diccionario de conflictividad
acep_plot_st(rp_re$st, rp_re$frecm,
             t = "Evolucion de la conflictividad en el sector pesquero argentino",
             ejex = "A\u00f1os analizados",
             ejey = "Menciones del diccionario de conflictos",
             etiquetax = "horizontal")

# Ahora con la función acep_plot_rst() elaboramos una visualización resumen.
# con cuatro gráficos de barras
acep_plot_rst(rp_re, tagx = "vertical")
