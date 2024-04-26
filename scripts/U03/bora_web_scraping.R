# https://archive.org/details/boletinoficialdelarepublicaargentina
# Cargar la biblioteca rvest
require(rvest)

# Definir las partes de las URLs
raiz <- "https://archive.org/download/"
identificador <- "Boletin_Oficial_Republica_Argentina_"
secciones <- c("1ra_seccion_", "2da_seccion_", "3ra_seccion_")
id_sec <- paste0(raiz, identificador, secciones)

# Crear un vector de fechas desde "1901-01-01" hasta "1910-12-31"
fechas <- seq(as.Date("1901-01-01"), as.Date("1910-12-31"), by = "day")

# Filtrar las fechas excluyendo los sábados y domingos
fechas <- fechas[!weekdays(fechas) %in% c("sábado", "domingo")]

# Crear las URLs para descargar los archivos PDF
urls <- c()
for (i in id_sec) {urls <- append(urls, paste0(i, fechas, "/", fechas, ".pdf"))}

# Crear un directorio para guardar los archivos descargados
dir.create("bora")

# Descargar 10 archivos PDF aleatorios
for (url in sample(urls, 10)) {download.file(url, destfile = paste0("bora/", basename(url)), mode = "wb")}

# Descargar 10 archivos PDF aleatorios con manejo de errores
for (url in sample(urls, 10)) {
  tryCatch({
    download.file(url, destfile = paste0("bora/", basename(url)), mode = "wb")
  }, error = function(e) {
    cat("Error al descargar:", url, "\n")
    cat("Mensaje de error:", conditionMessage(e), "\n")
  })
}
