
# Parte I - Paquete -------------------------------------------------------

require(rvest)

# Parte II - La Nación ----------------------------------------------------

# Definimos una url

url <- 'https://www.lanacion.com.ar/politica/'

# Creamos un set de objetos vacíos

# Variables
fechas    <- c()
titulares <- c()
notas     <- c()
hipers    <- c()

# DataFrame
la_nacion <- data.frame()

# Corremos el for para extraer los links de la url
links <- read_html(url) |> 
  html_elements('.com-title.--xs a, h2.com-title.--font-primary.--l.--font-medium a') |> 
  html_attr('href') |> url_absolute(url)

# Corremos el for para extraer el contenido de los primeros 32 links escrapeados con el for anterior
for(link in links){
  html <- read_html(link)
  fechas    <- append(fechas,    html |> html_elements('.com-date.--twoxs') |> html_text2())
  titulares <- append(titulares, html |> html_elements('h1.com-title') |> html_text2())
  notas     <- append(notas,     html |> html_elements('.com-paragraph') |> html_text2() |> paste(collapse = "\n\n"))
  hipers    <- append(hipers, link)
}

# Corremos el for para extraer el contenido de los primeros 32 links escrapeados con  el for anterior y crear un data.frame
for(i in links) {
  la_nacion <- rbind(
    la_nacion, 
    data.frame(
      fecha=read_html(i) |> html_elements('.com-date.--twoxs') |> html_text2(), 
      titular=read_html(i) |> html_elements('h1.com-title') |> html_text2(),
      nota=read_html(i) |> html_elements('.com-paragraph') |> html_text2() |> paste(collapse = "\n\n"),
      link=i
      ))
}

# Imprimir
la_nacion
