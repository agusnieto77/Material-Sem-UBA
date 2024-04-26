# Cargar las bibliotecas necesarias
require(rvest)
require(stringr)

# Definir la URL de búsqueda en el sitio web del CONICET
url <- "https://ri.conicet.gov.ar/discover?rpp=110&etal=0&query=direccion+escolar&group_by=none&page=1"

# Leer el contenido HTML de la URL
html <- read_html(url)

# Extraer los elementos HTML que contienen los enlaces de interés
elementos <- html_elements(html, "div.artifact-title a")

# Obtener los enlaces completos a partir de los elementos encontrados
href <- html_attr(elementos, "href")
links_completos <- url_absolute(href, "https://ri.conicet.gov.ar/")

# Definir un selector CSS para identificar la ubicación del resumen en la página individual de cada publicación
selector <- '.item-summary-view-metadata'

# Leer el texto correspondiente al resumen de cada publicación y guardarlo en un vector
resumenes <- c()
for (i in links_completos) {
  html_conicet <- read_html(i)
  resumenes <- append(resumenes, html_text(html_element(html_conicet, selector)))
}

# Limpiar los resúmenes eliminando partes no deseadas, como el encabezado y las palabras clave
resumenes_limpios <- gsub("^.*Resumen|Palabras clave.*$|", "", resumenes)
resumenes_limpios <- str_trim(resumenes_limpios)

# Guardar los resúmenes limpios en un archivo "resumenes_limpios.rds"
saveRDS(resumenes_limpios, "resumenes_limpios.rds")
