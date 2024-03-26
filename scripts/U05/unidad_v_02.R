
# Ejercicio 1 -------------------------------------------------------------

require(cartogram)
require(tmap)
require(maptools)
require(sf)

data(wrld_simpl) # maptools

# Solo america del sur
am_sur <- wrld_simpl[wrld_simpl$SUBREGION == 5, ]

# definimos proyeccion del mapa
am_sur <- spTransform(am_sur, CRS("+init=epsg:3395"))

# Creamos un objeto sf
am_sur_sf <- st_as_sf(am_sur)

# Cartograma de area contigua
am_sur_sf_cont <- cartogram_cont(am_sur_sf, "POP2005", 15)

# Cartograma de area no contigua
am_sur_sf_ncont <- cartogram_ncont(am_sur_sf, "POP2005")

# Cartograma de area no contigua
am_sur_sf_dorling <- cartogram_dorling(am_sur_sf, "POP2005")

# Mapas

map0 <- tm_shape(am_sur) + tm_borders() +
  tm_polygons("POP2005", style="jenks", 
              palette = tmaptools::get_brewer_pal("PiYG", n = 5, contrast = c(0, 0.47), 
                                                  plot=FALSE), legend.show = FALSE) +
  tm_layout(frame = FALSE)

map1 <- tm_shape(am_sur_sf_cont) + 
  tm_polygons("POP2005", style="jenks", 
              palette = tmaptools::get_brewer_pal("PiYG", n = 5, contrast = c(0, 0.47), 
                                                  plot=FALSE), legend.show = FALSE) +
  tm_layout(frame = FALSE)

map2 <- tm_shape(am_sur_sf) + tm_borders() + 
  tm_shape(am_sur_sf_ncont) + 
  tm_polygons("POP2005", style="jenks", 
              palette = tmaptools::get_brewer_pal("PiYG", n = 5, contrast = c(0, 0.47), 
                                                  plot=FALSE), legend.show = FALSE) +
  tm_layout(frame = FALSE)

map3 <- tm_shape(am_sur_sf) + tm_borders() + 
  tm_shape(am_sur_sf_dorling) + 
  tm_polygons("POP2005", style="jenks", 
              palette = tmaptools::get_brewer_pal("PiYG", n = 5, contrast = c(0, 0.47), 
                                                  plot=FALSE)) +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom"))

tmap_arrange(map0, map1, map2, map3, nrow = 2)

# FUENTE: https://cran.r-project.org/web/packages/cartogram/readme/README.html 



# Ejercicio 2 -------------------------------------------------------------

require(tidyverse)
require(sf)
require(rayshader)
require(RColorBrewer)

download.file(url = 'https://catalogo.datos.gba.gob.ar/dataset/33b080d2-e369-4076-acd4-511db0e9bffb/resource/a8bed3ca-2746-4ab1-a390-56f1788431b1/download/radios_censales.zip',
              destfile = './shapes/popba.zip', mode = 'wb')

unzip(zipfile = './shapes/popba.zip', exdir='./shapes/')

popba <- read_sf('./shapes/radios_censales/radios_censales.shp')

colores <- colorRampPalette(rev(brewer.pal(11, "Spectral")))

mapa <- ggplot() +
  geom_sf(data = popba, aes(fill = log10(totalpobl)), show.legend = F) +
  scale_fill_gradientn(colours=colores(8)) 

plot_gg(mapa, multicore = TRUE, width = 7, height = 10)
render_snapshot()
render_movie("./mapas/mapa.mp4", frames = 720, fps = 30, zoom = 0.6, fov = 30)
