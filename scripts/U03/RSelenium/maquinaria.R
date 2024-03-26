
# RSelenium ---------------------------------------------------------------

require(RSelenium)
require(rvest)
require(tidygeocoder)
require(dplyr)
require(sf)
require(ggplot2)
require(ggimage)
require(leaflet)
require(leaflet.extras)

servidor <- rsDriver(browser = "firefox", port = 2312L, chromever = "108.0.5359.22")
cliente <- servidor$client              
cliente$navigate("https://www.caseih.com/argentina/es-ar/Pages/Dealer-Locator.aspx") 

cookies <- cliente$findElement(using = "xpath", '//*[@id="CybotCookiebotDialogBodyButtonAccept"]')
cookies$clickElement()

provincia <- cliente$findElement(using = "xpath", '/html/body/form[1]/div[3]/div/div/div/div/section[1]/div/div[1]/div/div/a/div/div[2]/select/option[2]')
provincia$clickElement()

html <- cliente$getPageSource()[[1]]
html <- read_html(html)

datos_completos <- html |> html_elements('.column.column2') |> html_text2()
direcciones <- html |> html_elements('li.dealer-item > div:nth-child(2) > div:nth-child(2)') |> html_text2()
localidades <- html |> html_elements('li.dealer-item > div:nth-child(2) > div:nth-child(4)') |> html_text2()
localidades <- gsub(" ,.*", "", localidades)

maquinas_geocoor <-
  geo(
    street  = direcciones,
    city    = localidades,
    state   = rep('Buenos Aires', length(direcciones)),
    country = rep('Argentina', length(direcciones)),
    method  = 'osm'
  )

print(maquinas_geocoor, n = 22)

googlemaps <- html |> html_elements('.directions.font-cta') |> html_attr('href')
coordenadas <- gsub("^https.*=", "", googlemaps)

maquinas_df <- tibble(
  empresa = html |> html_elements('li.dealer-item > div:nth-child(2) > div:nth-child(1)') |> html_text2(),
  direccion = direcciones,
  localidad = localidades,
  contacto = html |> html_elements('li.dealer-item > div:nth-child(2) > div:nth-child(5)') |> html_text2(),
  lat = as.numeric(gsub(",.*", "", coordenadas)),
  lon = as.numeric(gsub(".*,", "", coordenadas)),
  link_map = googlemaps
)

xlsx::write.xlsx(maquinas_df, 'data/maquinas_df_.xlsx')
saveRDS(maquinas_df, 'data/maquinas_df.rds')

cliente$close()
cliente$open()
servidor$server$stop()

download.file(url = 'https://infra.datos.gob.ar/catalog/modernizacion/dataset/7/distribution/7.34/download/provincias.zip',
              destfile = './shapes/provincias.zip', mode = 'wb')

unzip(zipfile = './shapes/provincias.zip', exdir='./shapes/')

provincias <- read_sf('./shapes/provincias/provincias.shp') |> filter(OBJECTID == 447)

ggplot(provincias) +
  geom_sf() +
  geom_point(aes(y = lat, x = lon), data = maquinas_df)

ggplot(provincias) +
  geom_sf() +
  geom_image(aes(y = lat, x = lon), data = maquinas_df, 
             image='https://www.r-project.org/logo/Rlogo.png', size=.05)

ggplot(provincias) +
  geom_sf() +
  geom_image(aes(y = lat, x = lon), data = maquinas_df, 
             image='https://cdn-icons-png.flaticon.com/512/517/517602.png', size=.05)

ggplot(provincias) +
  geom_sf(fill = '#EAFAF1') +
  geom_image(aes(y = lat, x = lon), data = maquinas_df, 
             image='https://cdn-icons-png.flaticon.com/512/517/517500.png', size=.04) +
  labs(x=NULL,y=NULL) +
  theme_bw()

maquinas_df$descripcion <- paste(
  '<b>Nombre: </b>', maquinas_df$empresa, '<br>',
  '<b>Dirección: </b>', maquinas_df$direccion, '<br>',
  sep = '')

leaflet(maquinas_df) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addHeatmap(lng =~lon, lat=~lat,
             blur = 20, max = 0.05, radius = 15 )

leaflet(maquinas_df) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addMarkers(lng = ~lon, lat = ~lat,  popup = maquinas_df$descripcion)


cosechadoraicon <- iconList(
  cosechadora = makeIcon('./images/517500.png',
                         './images/517500@2x.png', 40, 40)
)

leaflet(maquinas_df) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addMarkers(lng = ~lon, lat = ~lat,  
             popup = maquinas_df$descripcion, 
             icon = ~cosechadoraicon)
