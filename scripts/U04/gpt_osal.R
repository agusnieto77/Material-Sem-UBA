#prueba de prompt API/GPT para deteccion de eventos de conflicto

# devtools::install_github("agusnieto77/ACEP")

require(ACEP)
require(jsonlite)
require(dplyr)

#cargar la clave aqui
# usethis::edit_r_environ()

#comprobar que este bien
# Sys.getenv("OPENAI_API_KEY")


instrucciones <- 'Seleccionar los párrafos que describan eventos de conflicto, en donde al menos un grupo realiza demandas o acciones contra otro.
Excluir del texto donde se informa sobre datos, elecciones, o resoluciones realizadas por autoridades de instituciones estatales o religiosas.'

download.file("https://github.com/agusnieto77/Sem-UBA/raw/master/datos/ARGENMEX2000a2008corregido200324.rds",
              destfile = "base.rds", mode = "wb")

base <- readRDS("base.rds")

base <- base %>% filter(fecha >= '2001-01-20' & fecha <= '2001-01-28')

texto_prueba <- paste0("ID: ", base$id_evento, 
                       sep = " | ", 
                       base$fecha, 
                       sep = " | ",
                       "Texto: ", base$texto)

cat(texto_prueba)
str(texto_prueba)


library(stringr)

resultados <- c()

for (i in texto_prueba) { 
  resultados <- append(
    resultados, 
    acep_gpt(texto = i, 
             instrucciones = instrucciones,
             url = "https://api.openai.com/v1/chat/completions", 
             modelo = "gpt-3.5-turbo-0125")
    ) 
  }

cat(resultados)

resultados

# df_resultados <- bind_rows(lapply(resultados, fromJSON, simplifyDataFrame = TRUE))[[1]]
