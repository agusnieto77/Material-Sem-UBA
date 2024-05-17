#prueba de prompt API/GPT para deteccion de eventos de conflicto

# devtools::install_github("agusnieto77/ACEP")

require(ACEP)
require(jsonlite)
require(dplyr)

#cargar la clave aqui
# usethis::edit_r_environ()

#comprobar que este bien
# Sys.getenv("OPENAI_API_KEY")

instrucciones <- 'Seleccionar los elementos del texto que describan eventos de conflicto. 
Por eventos de conflicto deben entenderse aquellas acciones en el que un grupo realiza demandas o acciones contra otro.
Excluir las acciones realizadas por autoridades estatales (gobierno, parlamento, poder judicial). 
Estos resultados deberan informarse en datos en formato JSON en donde cada elemento representa
una accion de conflicto. No asignar ningun elemento JSON en caso que el evento sea no conflictivo.
Cada JSON debe contener las siguientes claves:
ID: ID del evento en la base de datos.
Fecha: Fecha del evento.
Descripcion: un resumen de la variable Texto.'

download.file("https://github.com/agusnieto77/Sem-UBA/raw/master/datos/ARGENMEX2000a2008corregido200324.rds",
              destfile = "base.rds", mode = "wb")

base <- readRDS("base.rds")

base <- base %>% filter(fecha >= '2001-01-20' & fecha <= '2001-01-28')

texto_prueba <- paste0("ID: ", base$id_evento, " | ", 
                       "FECHA: ", base$fecha,  " | ",
                       "TEXTO: ", base$texto)

cat(texto_prueba)
str(texto_prueba)


library(stringr)

resultados <- c()

for (i in texto_prueba) { resultados <- append(resultados, acep_gpt(texto = i, instrucciones = instrucciones)) }

resultados

cat(resultados)
