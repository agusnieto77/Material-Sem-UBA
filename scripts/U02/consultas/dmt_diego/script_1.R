require(rvest)

urls <- c("https://repositorio.utdt.edu/handle/20.500.13098/6788/recent-submissions?offset=0", 
         "https://repositorio.utdt.edu/handle/20.500.13098/6788/recent-submissions?offset=7")

links <- c()

for (url in urls) {
  links <- append(links, 
                  read_html(url) |> 
                    html_elements(".artifact-title a") |> 
                    html_attr("href") |> 
                    url_absolute("https://repositorio.utdt.edu"))
}

links_pdfs <- c()

i <- 1  # Índice para iterar sobre los enlaces

while (i <= length(links)) {
  tryCatch({
    pdf_link <- read_html(links[i]) |>
      html_elements(xpath = '//*[@id="aspect_artifactbrowser_ItemViewer_div_item-view"]/div/div/div[1]/div[1]/div[2]/div/div/a') |>
      html_attr("href") |>
      url_absolute("https://repositorio.utdt.edu")
    
    links_pdfs <- append(links_pdfs, pdf_link)
    Sys.sleep(5)
    print(links[i])
    i <- i + 1  # Incrementar el índice solo si la solicitud es exitosa
  }, error = function(e) {
    # Manejo del error 429 (demasiadas solicitudes)
    if (grepl("HTTP error 429", e$message)) {
      cat("Demasiadas solicitudes. Esperando y reiniciando desde el enlace:", links[i], "\n")
      Sys.sleep(15)  # Espera 15 segundos antes de intentar de nuevo
    } else {
      stop(e)  # Si es otro tipo de error, lanza una excepción
    }
  })
}

dir.create("utdt_pdfs")

nombres <- paste0("./utdt_pdfs/", gsub("Block%206_|%20|\\?sequence=1&isAllowed=y", "", basename(links_pdfs)))

i <- 1

while (i <= length(links_pdfs)) {
  tryCatch({
    download.file(links_pdfs[i], destfile = nombres[i], mode = "wb")
    print(paste("Descargado:", nombres[i]))
    Sys.sleep(5)
    i <- i + 1  # Incrementar el índice solo si la solicitud es exitosa
  }, error = function(e) {
    # Manejo del error 429 (demasiadas solicitudes)
    if (grepl("no fue posible abrir|429 Unknown Error", e$message)) {
      cat("Demasiadas solicitudes. Esperando y reiniciando desde el enlace:", links[i], "\n")
      Sys.sleep(15)  # Espera 15 segundos antes de intentar de nuevo
    } else {
      stop(e)  # Si es otro tipo de error, lanza una excepción
    }
  })
}
