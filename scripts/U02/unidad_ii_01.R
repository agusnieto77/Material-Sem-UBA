
library(rvest)

# OSAL toda la colección
url <- 'https://libreria.clacso.org/coleccion.php?cl=48&c=6#listado_publicaciones'

# Leer el HTML de la página
webpage <- read_html(url)

# Extraer los enlaces a los archivos PDF
pdf_links <- webpage %>%
  html_elements("a[href$='.pdf']") %>%
  html_attr("href")

# Crear directorio para los pdfs
dir.create("osal")

# Descargar los archivos PDF
for (link in pdf_links) {
  # Nombre del archivo PDF
  filename <- basename(link)
  # Descargar el archivo PDF
  download.file(link, destfile = paste0("osal/", filename), mode = "wb")
}
