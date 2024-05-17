# usethis::edit_r_environ()
# Carga de paquetes necesarios
require(googleCloudStorageR)  # Paquete para interactuar con Google Cloud Storage
require(daiR)                 # Paquete para interactuar con Document AI desde R

# Descarga del archivo GIF desde una URL en Internet y guarda localmente
download.file("https://github.com/agusnieto77/Sem-UBA/raw/master/datos/dair_prueba.gif", 
              destfile = "dair_prueba.gif", mode = "wb")

# Subida del archivo GIF a Google Cloud Storage
gcs_upload("dair_prueba.gif")

# Lista los objetos almacenados en el bucket de Google Cloud Storage actual
gcs_list_objects()

# Inicia una tarea asincrónica en Document AI utilizando el archivo GIF
response <- dai_async("dair_prueba.gif", loc = "us")

# Descarga el resultado de la tarea asincrónica en formato JSON y lo guarda localmente
gcs_get_object(gcs_list_objects()$name[1], saveToDisk = "gif.json", overwrite = TRUE)

# Lee el contenido del archivo descargado y lo muestra en la consola
cat(get_text("gif.json", type = "async"))

