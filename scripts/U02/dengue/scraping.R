# Librerías ---------------------------------------------------------------

require(RSelenium)
require(rvest)

# Inicio de servidor y sesión en twitter ----------------------------------

# usethis::edit_r_environ()
# ó
# Sys.setenv(USER = "@xxxxxxxxxxx")
# Sys.setenv(PASS = "xxxxxxxxxxxx")

url <- "https://twitter.com/i/flow/login"

servidor <- rsDriver(browser = "firefox", port = 6789L, chromever = "108.0.5359.22")
cliente <- servidor$client             
cliente$navigate(url) 

Sys.sleep(5)

input_1 <- "/html/body/div/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div/div/div/div[5]/label/div/div[2]/div/input"
input_2 <- "/html/body/div/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[1]/div/div/div[3]/div/label/div/div[2]/div[1]/input"
clic__1 <- "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div/div/div/div[6]/div"
imput_3 <- "/html/body/div/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[1]/div/div[2]/label/div/div[2]/div/input"
iniciar <- "/html/body/div/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[2]/div/div[1]/div/div/div/div"

username <- cliente$findElement(using = "xpath", input_1)
username$sendKeysToElement(list(Sys.getenv("USER")))

clic <- cliente$findElement(using = "xpath", value = clic__1)
clic$clickElement() 

Sys.sleep(5)

passwd <- cliente$findElement(using = "xpath", value = input_2)
passwd$sendKeysToElement(list(Sys.getenv("PASS")))

iniciar_sesion <- cliente$findElement(using = "xpath", iniciar)
iniciar_sesion$clickElement() 

Sys.sleep(5)

# Para hacer scroll -------------------------------------------------------

down_arrow_plus <- list(key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow", 
                        key = "down_arrow", key = "down_arrow")

# Código para resultados de búsquedas ----------------------------------------

usuarix <- "div.css-175oi2r div.css-1rynq56.r-8akbws.r-krxsd3.r-dnmrzs.r-1udh08x.r-bcqeeo.r-qvutc0.r-37j5jr.r-a023e6.r-rjixqe.r-16dba41.r-bnwqim"

cliente$navigate("https://twitter.com/search?q=dengue") 

Sys.sleep(5)

tweets_r <- c()
down_arrow <- list()

for (i in 1:20) {
  X <- cliente$getPageSource()[[1]]
  X_html <- read_html(X)
  tweets_r <- append(tweets_r, 
                     html_text2(html_elements(
                       X_html, css = usuarix)))
  down_arrow <- append(down_arrow, down_arrow_plus)
  scroll <- cliente$findElement("css", "body")
  scroll$sendKeysToElement(down_arrow)
  message("Iteración: ", i)
  Sys.sleep(1.5)
}

(tweets_r <- unique(tweets_r))


# Código para cerrar servidor ----------------------------------------

cliente$close()
servidor$server$stop()


# Guardar los datos -------------------------------------------------------

saveRDS(tweets_r, "./scripts/U02/dengue/data/tweets_r.rds")
