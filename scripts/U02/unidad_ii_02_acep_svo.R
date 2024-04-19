# Instalación del paquete ACEP desde GitHub
# install.packages("devtools")
# devtools::install_github("agusnieto77/ACEP")

# Cargar el paquete ACEP
require(ACEP)


# Ejemplo simple ----------------------------------------------------------

# Analizar la estructura sujeto-verbo-objeto (SVO) de una frase
# Aquí analizamos la frase "La CGT declaró una huelga general."
ejemplo_svo <- acep_svo(acep_postag("La CGT declaró una huelga general.")$texto_tag)$acep_list_svo

# Visualizar el resultado en una ventana de datos
View(ejemplo_svo)

# Ejercicio con 50 párrafos del OSAL --------------------------------------

# Leer los datos de un archivo CSV que contiene 50 párrafos
svo <- readr::read_csv("https://raw.githubusercontent.com/agusnieto77/Sem-UBA/master/datos/svo.csv")

# Visualizar la estructura de los datos
svo
svo$texto


# Aplicar una función para etiquetado POS, lematización, tokenización -----

postag_text <- acep_postag(svo$texto)

# Mostrar la estructura de los datos resultantes
str(postag_text)

# data.frame con el etiquetado POS y las relaciones de dependencia
texto_tag <- postag_text$texto_tag

# data.frame con el etiquetado POS y Reconocimientos de Entidades Nombradas (NER)
texto_tag_entity <- postag_text$texto_tag_entity

# data.frame con Entidades Nombradas
texto_only_entity <- postag_text$texto_only_entity

# data.frame con Entidades Nombradas de Localización
texto_only_entity_loc <- postag_text$texto_only_entity_loc

# data.frame con el etiquetado POS y el sujeto sintáctico de la oración
texto_nounphrase <- postag_text$texto_nounphrase

# data.frame con el sujeto sintáctico de la oración
texto_only_nounphrase <- postag_text$texto_only_nounphrase

View(texto_tag)
View(texto_tag_entity)
View(texto_only_entity)
View(texto_only_entity_loc)
View(texto_nounphrase)
View(texto_only_nounphrase)


# Aplicamos una función para extraer tripletes SVO --------

svo_text <- acep_svo(texto_tag)

# data.frame con el etiquetado POS y las relaciones de dependencia (simplificado)
acep_annotate_svo <- svo_text$acep_annotate_svo

# data.frame con identificación de sujeto, verbo y predicado e identificación de verbos auxiliares, sutantivos en el predicado, etc.
acep_pro_svo <- svo_text$acep_pro_svo

# data.frame con identificación de sujeto, verbo y predicado (simplificado)
acep_list_svo <- svo_text$acep_list_svo

# data.frame con identificación de sujeto y predicado
acep_sp <- svo_text$acep_sp

# data.frame con lemmas
acep_lista_lemmas <- svo_text$acep_lista_lemmas

# data.frame con oraciones no procesadas (oraciones pasivas, unimembres, tácitas)
acep_no_procesadas <- svo_text$acep_no_procesadas

# Visualizar los resultados en ventanas de datos
View(acep_annotate_svo)
View(acep_pro_svo)
View(acep_list_svo)
View(acep_sp)
View(acep_lista_lemmas)
View(acep_no_procesadas)
