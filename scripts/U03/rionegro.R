rn_url <- "https://www.rionegro.com.ar/economia/?utm_source=menu_footer"

require(rvest)
require(RSelenium)

read_html(rn_url) |> html_elements(".news__title")





servidor <- rsDriver(browser = "firefox", port = 3332L, chromever = "108.0.5359.22")
cliente <- servidor$client             
cliente$navigate(rn_url) 

rn_html <- cliente$getPageSource()[[1]]

rn_html <- read_html(rn_html)

rn_elementos <- html_elements(rn_html, ".news__title")

titulos_rn <- html_text2(rn_elementos)

links_rn <- html_elements(rn_html, ".news__title a") |> html_attr("href")

notas <- data.frame()

for (i in links_rn) {
  html <- read_html(i)
  notas <- rbind(notas, 
                 data.frame(
                   fecha = html_element(html, ".newsfull__time") |> html_text2(),
                   titulo = html_element(html, ".newsfull__title") |> html_text2(),
                   bajada = html_element(html, ".newsfull__excerpt") |> html_text2(),
                   imagen = html_element(html, ".attachment-nota-gallery.size-nota-gallery.wp-post-image") |> html_attr("src"),
                   link = i
                 )
                  )
}
