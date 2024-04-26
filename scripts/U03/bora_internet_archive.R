# INSTALAMOS LA LIBRERIA internetarchive
# devtools::install_github("ropensci/internetarchive", build_vignettes = TRUE)

# CARGAMOS LAS LIBRERIAS
require(internetarchive)
require(dplyr)
require(stringr)

# CREAMOS EL OBJETO 'parámetros' PARA LA BUSQUEDA
(                                                           # abrimos la impresión en consola del objeto que vamos a crear
  parametros <-                                             # asignamos un nombre al objeto que vamos a crear
    c(                                                      # abrimos el vector
      'collection' = 'boletinoficialdelarepublicaargentina',# definimos la colección
      "subject" = "boletin",                                # definimos el tópico
      "mediatype" = "texts"                                 # definimos el tipo de objeto
    )                                                       # cerramos el vector
)                                                           # cerramos la impresión en consola del objeto creado 

# BUSCAMOS LOS BORA

boletines <- ia_search(     # abrimos la función de búsqueda
  terms = parametros,       # ingresamos el objeto con los parámetros
  num_results = 55941,      # determinamos la cantidad de devoluciones de la búsqueda
  page = 1,                 # definimos la pagina que queremos que nos muestre en la consola
  print_url = TRUE,         # pedimos que imprima en consola la url de la búsqueda
  print_total = TRUE        # pedimos que nos muestre el total de ítems existentes que refieren a la palabra buscada
)

boletines # imprimimos el vector

# Crear un directorio para guardar los archivos descargados
dir.create("scripts/U03/BORA")

# BAJAR LOS ARCHIVOS QUE NECESITAMOS PARA LA INVESTIGACION
(                                 # abrimos la impresión en consola del objeto que vamos a crear
  tabla_periodicos <-             # asignamos un nombre al objeto que vamos a crear
    tibble(                       # abrimos la tabla
      ia_search(                  # abrimos la función de búsqueda
        terms = parametros,       # ingresamos el objeto con los parámetros
        num_results = 20,         # determinamos la cantidad de devoluciones de la búsqueda
        page = 1,                 # definimos la pagina que queremos que nos muestre en la consola
        print_url = TRUE,         # pedimos que imprima en consola la url de la búsqueda
        print_total = TRUE        # pedimos que nos muestre el total de ítems existentes que refieren a la palabra buscada
      ) %>%                       # pipe
        ia_get_items() %>%        # aplicamos una función para obtener los metadatos de los elementos encontrados
        ia_files() %>%            # accedemos a la lista de archivos asociados a elementos del ia
        filter(                   # aplicamos un filtro para quedarnos solo con un valor
          type == "pdf"           # filtramos aquellos valores que son iguales a 'pdf'
        ) %>%                     # pipe
        group_by(id               # aplicamos función para agrupar
        ) %>%                     # pipe
        filter(                   # función filtrar
          str_detect(             # función detectar
            file, '_text')        # parámetros
        ) %>%                     # pipe
        ia_download(              # aplicamos la función de ia para descargar los documentos
          dir = paste0(           # llamamos la función de pegado para indicar el directorio
            getwd(),              # indicamos cual es el directorio de trabajo
            "/scripts/U03/BORA"), # indicamos cual es la carpeta para las descargas
          overwrite = FALSE       # establecemos que no sobrescriba archivos
        ) %>%                     # pipe
        glimpse()                 # aplicamos función para mostrar las variables en sentido horizontal 
    )                             # cerramos la tabla
)                                 # cerramos la impresión en consola del objeto que vamos a crear
