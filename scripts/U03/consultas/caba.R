require(rvest)

urls <- paste0("https://www.estadisticaciudad.gob.ar/eyc/?cat=135&paged=", 1:20)

links <- data.frame()

for (i in urls) {
  html <- read_html(i)
  links <- rbind(
    links,
    data.frame(
      titulo = html_text2(html_elements(html, ".entry-title h2")),
      link = html_attr(html_elements(html, ".entry-title h2 a"), "href")
    )
  )
  print(i)
}

links <- unique(links)

link <- unique(links$link)

links_xlsx <- c()

for (i in link) {
  links_xlsx <- append(links_xlsx, html_attr(html_element(read_html(i), "a.file-custom-field"),"href"))
  print(i)
}

links$links_xlsx <- links_xlsx
links$archivo <- basename(links_xlsx)

dir.create("doc_xlsx")

for (i in links_xlsx) {
  download.file(url = i, destfile = paste0("doc_xlsx/",basename(i)), mode = "wb")
  print(i)
}
