require(rvest)
require(dplyr)
require(ACEP)
require(ggplot2)

url <- "https://www.fonds-soziokultur.de/gefoerderte-projekte/allgemeine-projektfoerderung.html"

html <- read_html(url)

db <- tibble(
  ganador = html_text2(html_elements(html, ".project-item h5")),
  ciudad = gsub("^.+, ", "", html_text2(html_elements(html, "p.project-applicant")))
)

(cuenta <- head(arrange(count(db, ciudad), desc(n)), n = 10))

acep_token_plot(db$ciudad, u = 10)

ggplot(cuenta) + 
  geom_bar(aes(x = reorder(ciudad, n), y = n), stat = "identity") + 
  labs(title = "Aquí el título", x = "Ciudades", y = "Frecuencia") +
  theme_bw()
