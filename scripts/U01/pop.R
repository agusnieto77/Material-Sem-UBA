# Ordenar y Clasificar (Parte 2)

# Trabajar con tidyr

# Bajamos y cargamos los datos con las funciones 'download.file' y 
# 'read.table' del paquete 'utils', paquete base de r

# Descarga datos población mundial

url <- "https://raw.githubusercontent.com/carpentries-incubator/open-science-with-r/gh-pages/data/gapminder_wide.csv"

file <- file.path(".", basename(url))

download.file(url, file)

poblacion <- read.table(file, 
                        header = TRUE, 
                        sep = ',', 
                        stringsAsFactors = FALSE,
                        encoding = "UTF-8")

head(poblacion)

library(readr)
gapminder_wide <- read_csv("gapminder_wide.csv")
View(gapminder_wide)

# Vemos su estructura de datos

utils::str(poblacion)

# Transformamos la base a formato largo

# Transformamos la base de datos a formato largo con las funciones 'gather' del paquete tidyr.

# Cargamos tidyr

require(tidyr)

poblacion_long <- poblacion %>% 
  gather(obs_anio,                 # nombramos la nueva columna para la nueva variable
         valor,                    # nombre de la nueva variable con los valores de las viejas variables 
         -continent,               # (-) identificamos qué variables queremos excluir del proceso 'gather'
         -country)                 # (-) identificamos qué variables queremos excluir del proceso 'gather'

poblacion_long <- poblacion %>% 
  pivot_longer(c(-continent, -country), 
               names_to = "obs_anio", 
               values_to = "valor")

head(poblacion_long)

# Vemos su estructura de datos

utils::str(poblacion_long)

# Separar para crear nuevas columnas

# Separamos la observacion del año con la función separate del paquete tidyr

# Separamos la observacion del año
gap_long <- 
  poblacion_long %>% 
  separate(obs_anio, 
           into = c("obs", "anio"), 
           sep = "_") %>% 
  mutate(anio = as.integer(anio))

head(gap_long)

# Vemos su estructura de datos

utils::str(gap_long)

# Separamos para darle la estrcutura deseada

# Usamos la función spread del paquete tidyr

gap_normal <- gap_long %>% spread(obs, valor)

gap_normal <- gap_long %>% pivot_wider(names_from = obs, values_from = valor)

head(gap_normal)

# Vemos su estructura de datos

utils::str(gap_normal)

# Algo de tablas para visualización y consultas... """

# install.packages(c('DT','gapminder'))
require(gapminder)
require(DT)

data("gapminder")
tabla02 <- datatable(gapminder)
html <- "tabla02.html"
saveWidget(tabla02, html)
