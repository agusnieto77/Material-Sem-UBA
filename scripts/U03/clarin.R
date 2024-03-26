urls_clarin <- paste0("https://www.clarin.com/politica/page/", 1:10)

require(rvest)

links <- c()

for (i in urls_clarin) {
  links <- append(links, read_html(i) |> html_elements("article a") |> html_attr("href") |> url_absolute("https://www.clarin.com"))
}

notas <- data.frame()

for (n in links) {
  html <- read_html(n)
  notas <- rbind(notas, 
                 data.frame(
                   fecha = html_element(html, ".createDate") |> html_text2(),
                   titulo = html_element(html, ".storyTitle") |> html_text2(),
                   bajada = html_element(html, ".storySummary") |> html_text2(),
                   imagen = html_element(html, ".image-container img") |> html_attr("src"),
                   link = n
                 )
  )
}
