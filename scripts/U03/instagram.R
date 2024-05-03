require(rvest)
require(dplyr)

url <- "https://www.instagram.com/accounts/login/"

instagram <- read_html_live(url)

# instagram$view()

input_1 <- "#loginForm > div > div:nth-child(1) > div > label > input"
input_2 <- "#loginForm > div > div:nth-child(2) > div > label > input"
iniciar <- "#loginForm > div > div:nth-child(3) > button"

instagram$type(css = input_1, text = Sys.getenv("USER_I"))
instagram$type(css = input_2, text = Sys.getenv("PASS_I"))
instagram$click(css = iniciar, n_clicks = 1)

ar_mza <- read_html_live("https://www.instagram.com/asamblearesidentes_mza/")

# ar_mza$view()

ar_mza$scroll_by(top = 6000, left = 0)

links <- "._ac7v.xzboxd6.xras4av.xgc1b0m a"

urls_post <- url_absolute(html_attr(ar_mza$html_elements(css = links), "href"), "https://www.instagram.com/asamblearesidentes_mza")

# Función para obtener la fecha del post
obtener_fecha <- function(selector1, selector2) {
  if (length(post_instagram$html_elements(selector1)) > 0) {
    html_attr(post_instagram$html_elements(selector1), "datetime")
  } else if (length(post_instagram$html_elements(selector2)) > 0) {
    html_attr(post_instagram$html_elements(selector2), "datetime")
  } else {
    NA  # Retorna NA si no se encuentra ninguno de los selectores
  }
}

# Función para obtener la fecha del post
obtener_texto <- function(selector) {
  if (length(post_instagram$html_elements(selector)) > 0) {
    html_text(post_instagram$html_elements(selector))
  } else {
    NA  # Retorna NA si no se encuentra ninguno de los selectores
  }
}

post_ar_mza <- tibble()

imagen <- "img.x5yr21d.xu96u03.x10l6tqk.x13vifvy.x87ps6o.xh8yej3"
fecha1 <-  "time.xsgj6o6"
fecha2 <-  "time.x1p4m5qa"
texto <-  "span.x193iq5w.xeuugli.x1fj9vlw.x13faqbe.x1vvkbs.xt0psk2.x1i0vuye.xvs91rp.xo1l8bm.x5n08af.x10wh9bi.x1wdrske.x8viiok.x18hxmgj"
likes <-  "span.html-span.xdj266r.x11i5rnm.xat24cr.x1mh8g0r.xexx8yu.x4uap5.x18d9i69.xkhd6sd.x1hl2dhg.x16tdsg8.x1vvkbs"
coment <- "div.x78zum5.xdt5ytf.x1iyjqo2"

# post_instagram$view()

for (i in urls_post) {
  post_instagram <- read_html_live(i)
  post_ar_mza <- rbind(
    post_ar_mza,
    tibble(
      fecha_post = obtener_fecha(fecha1, fecha2),
      texto_post = obtener_texto(texto),
      likes_post = html_text(post_instagram$html_elements(css = likes)),
      link_image = html_attr(post_instagram$html_elements(css = imagen), "src")[1],
      comentario = html_text(post_instagram$html_elements(css = coment))[2],
      url_post = i
    )
  )
  print(i)
}


# Código para cerrar servidor ----------------------------------------

instagram$session$close()
ar_mza$session$close()
post_instagram$session$close()


# Guardar los datos -------------------------------------------------------

saveRDS(distinct(post_ar_mza, url_post, .keep_all = T), "./scripts/U03/instagram_r.rds")


# Descarga de imágenes ----------------------------------------------------

dir.create("img_isntagram")

links_img <- unique(post_ar_mza$link_image)

nombres_img <- gsub("\\?.*", "", links_img)

for (i in seq_along(links_img)) {
  download.file(links_img[i], paste0("img_isntagram/", basename(nombres_img[i])), mode = "wb")
}
