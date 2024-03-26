
# Parte I - Paquete -------------------------------------------------------

require(rvest)

# Parte II - La Nación ----------------------------------------------------

# Definimos una url

url <- 'https://www.lanacion.com.ar/politica/'

# Creamos un set de objetos vacíos

# Links
links <- c()

# Variables
fechas    <- c()
titulares <- c()
notas     <- c()
hipers    <- c()

# DataFrame
la_nacion <- data.frame()

# Corremos el for para extraer los links de la url
links <- append(links, read_html(url) |> html_elements('.com-title.--font-primary.--l.--font-medium a, .com-title.--font-primary.--twoxl.--font-medium a, .com-title.--font-primary.--xs.--font-medium a') |> html_attr('href')) |> url_absolute(url)

links_df <- data.frame(links = links)

links <- links_df |> dplyr::filter(stringr::str_detect(links, "politica"))

links <- links$links[2:35]

# Corremos el for para extraer el contenido de los primeros 9 links escrapeados con el for anterior
for(link in links[1:8]){
  fechas    <- append(fechas,    read_html(link) |> html_element('.com-date.--twoxs') |> html_text2())
  titulares <- append(titulares, read_html(link) |> html_element('.com-title.--font-primary.--sixxl.--font-extra') |> html_text2())
  notas     <- append(notas,     read_html(link) |> html_element('.com-paragraph') |> html_text2() |> list())
  hipers    <- append(hipers, link)
}
titulares <- unique(titulares)
# Corremos el for para extraer el contenido de los primeros 9 links escrapeados con  el for anterior y crear un data.frame
for(i in 1:length(links[1:8])) {la_nacion <- rbind(la_nacion, data.frame(fecha=fechas[i], titular=titulares[i], nota=paste0(notas[[i]], collapse = ' | '), hiper=hipers[i]))}

# Imprimir
la_nacion
