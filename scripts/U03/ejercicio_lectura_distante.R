# Carga de paquetes necesarios
require(dplyr)              # Paquete para manipulación de datos
require(ggplot2)            # Paquete para visualización de datos
require(lubridate)          # Paquete para manejo de fechas
require(ACEP)               # Paquete para análisis de contenido en español
require(ggwordcloud)        # Paquete para crear nubes de palabras
require(quanteda)           # Paquete para análisis de texto cuantitativo
require(quanteda.textstats) # Paquete para estadísticas de texto en quanteda
require(quanteda.textplots) # Paquete para visualización de texto en quanteda
require(rwhatsapp)          # Paquete para análisis de datos de WhatsApp
require(tidyr)              # Paquete para manipulación de datos
require(stringr)            # Paquete para manipulación de cadenas de texto
require(purrr)              # Paquete para programación funcional
require(ggimage)            # Paquete para visualización de imágenes en ggplot

# Lectura de datos desde un archivo .rds
post_al_mza <- readRDS("post_al_mza.rds")

# Muestra la estructura de los datos
glimpse(post_al_mza)

# Preprocesamiento de datos: manipulación de fechas y caracteres
post_al_mza <- post_al_mza %>% 
  mutate(fecha_norm = as.Date(fecha_post),  # Normaliza la fecha del post
         likes_post = as.integer(gsub(",", "", likes_post)),  # Convierte likes_post a entero
         num_char = nchar(texto_post)) %>%  # Cuenta el número de caracteres en el texto del post
  filter(num_char > 1) %>%                  # Filtra los registros con más de un caracter
  mutate(año = year(fecha_norm),            # Extrae el año de la fecha normalizada
         mes = month(fecha_norm),            # Extrae el mes de la fecha normalizada
         año_mes = floor_date(fecha_norm, unit = "months"))  # Extrae el año y mes de la fecha normalizada

# Conteo de frecuencia de post por año y mes
post_al_mza %>% count(año_mes) %>%
  filter(!is.na(año_mes)) %>% 
  ggplot() + 
  geom_line(aes(x=año_mes, y=n), size = 0.6) +  # Grafica la frecuencia de post por año y mes
  scale_x_date(date_breaks = "2 month", date_labels = "%b-%y") +  # Formato de las etiquetas en el eje x
  labs(y="frecuencia de post", x=NULL) +  # Etiquetas de los ejes
  annotate("label", x=as.Date("2020-12-30"), y=82, label="Sanción Ley IVE", color="darkgreen", size=4) +  # Anotación en el gráfico
  theme_minimal() +  # Tema del gráfico
  theme(axis.text.x = element_text(angle=90, vjust = 0.5, hjust=1))  # Ajustes en el texto del eje x

# Limpieza de texto: unión de texto por año
texto_limpio <- post_al_mza %>% filter(!is.na(año_mes)) |>
  group_by(año) %>% summarise(texto = paste(texto_post, collapse = " "))

# Tokenización y análisis de frecuencia de términos
acep_token(texto_limpio$texto) %>% 
  left_join(texto_limpio %>% 
              mutate(texto_id = row_number()) %>% 
              select(texto_id, año), by = "texto_id") %>% 
  as_tibble() -> textos_tokens

# Generación de nubes de palabras
set.seed(1234)
textos_tokens %>% group_by(año) %>% 
  count(tokens) %>% filter(tokens != "hs") |>
  top_n(20) %>% ungroup() %>% 
  filter(año < 2024) %>% 
  ggplot(aes(label = tokens, size = log10(n), colour = n)) +
  geom_text_wordcloud_area() +
  scale_size_area(max_size = 20) +
  facet_wrap(~año, ncol = 3, scales = "free") +
  theme_bw() +
  scale_color_gradient(low = "darkgreen", high = "green") +
  theme(text = element_text(size=22)) -> nubes

# Visualización de nubes de palabras
nubes

# Calcular la frecuencia de bigramas y visualizarlos en un gráfico de barras
textstat_frequency(dfm(tokens_ngrams(tokens(acep_cleaning(texto_limpio$texto)), n = 2))) %>%
  head(20) %>%
  ggplot() +
  geom_bar(aes(x=reorder(feature, frequency), y=frequency), fill = "white",
           color = "grey30", stat = "identity", show.legend = F) +
  labs(x = NULL, y = NULL) +
  coord_flip() +
  theme_classic() +
  theme(text = element_text(size = 14))

# Convertir la matriz dfm a una matriz de término-documento
matriz_term_doc <- as.matrix(dfm(tokens_ngrams(tokens(acep_cleaning(texto_limpio$texto)), n = 2)))

# Calcular las frecuencias de bigramas
frecuencias_bigrams <- colSums(matriz_term_doc)

# Crear un data frame con las frecuencias de bigramas
tabla_frecuencias_bigrams <- data.frame(Bigram = names(frecuencias_bigrams), Frecuencia = frecuencias_bigrams)

# Ordenar la tabla de frecuencias por frecuencia descendente
tabla_frecuencias_bigrams <- tabla_frecuencias_bigrams[order(-tabla_frecuencias_bigrams$Frecuencia), ]

# Seleccionar las 15 primeras filas de la tabla de frecuencias de bigramas
ley_IVE <- select(tabla_frecuencias_bigrams, Frecuencia)

# Imprimir las primeras 15 filas de la tabla de frecuencias de bigramas
head(ley_IVE, n = 15)

# Crear una matriz de documentos-términos con tokenización
dfmat_ig <- dfm(tokens(gsub("#"," #",texto_limpio$texto), remove_punct = TRUE))
head(dfmat_ig)  # Mostrar las primeras filas de la matriz
class(dfmat_ig) # Mostrar la clase de la matriz

# Seleccionar términos que comienzan con # (#hashtags)
dfmat_tag <- dfm_select(dfmat_ig, pattern = "#*")
toptag <- names(topfeatures(dfmat_tag, 50)) # Obtener los 50 principales #hashtags
head(toptag) # Mostrar los primeros #hashtags seleccionados

# Crear una matriz de co-ocurrencia de #hashtags
fcmat_tag <- fcm(dfmat_tag)
head(fcmat_tag) # Mostrar las primeras filas de la matriz de co-ocurrencia

# Seleccionar subconjunto de #hashtags más frecuentes
fcmat_topgat <- fcm_select(fcmat_tag, pattern = toptag)

# Visualizar la red de co-ocurrencia de #hashtags más frecuentes
textplot_network(fcmat_topgat, min_freq = 0.1, edge_alpha = 0.1, edge_size = 4,
                 edge_color = "purple",
                 vertex_labelsize = log10((Matrix::rowSums(fcmat_topgat)*12)+5),
                 vertex_color = "purple",
                 vertex_labelfont = if (Sys.info()["sysname"] == "Raleway Medium") "Raleway Medium" else NULL,
                 vertex_size = 1,
                 vertex_labelcolor = "grey10")

# Seleccionar términos que comienzan con @ (usuarixs)
dfmtat_users <- dfm_select(dfmat_ig, pattern = "@*")
topuser <- names(topfeatures(dfmtat_users, 50)) # Obtener lxs 50 principales usuarixs
head(topuser) # Mostrar lxs primerxs usuarixs seleccionadxs

# Crear una matriz de co-ocurrencia de usuarixs
fcmat_users <- fcm(dfmtat_users)
head(fcmat_users) # Mostrar las primeras filas de la matriz de co-ocurrencia

# Seleccionar subconjunto de usuarixs más frecuentes
fcmat_users <- fcm_select(fcmat_users, pattern = topuser)

# Visualizar la red de co-ocurrencia de usuarixs más frecuentes
textplot_network(fcmat_users, min_freq = 0.1, edge_alpha = 0.1, edge_size = 4,
                 edge_color = "purple",
                 vertex_labelsize = log10((Matrix::rowSums(fcmat_topgat)*12)+5),
                 vertex_color = "purple",
                 vertex_labelfont = if (Sys.info()["sysname"] == "Raleway Medium") "Raleway Medium" else NULL,
                 vertex_size = 1,
                 vertex_labelcolor = "grey10")

# Limpieza de texto con ACEP
ig_limpios <- acep_cleaning(texto_limpio$texto, other_sw = c("si", "hoy", "van", "día", "hs", "años"))

# Tokenización del texto limpio
(tokens <- acep_token(ig_limpios))

# Análisis de frecuencia de términos
(tabla <- acep_token_table(tokens$tokens, u = 15))

# Visualización del análisis de frecuencia
acep_token_plot(tokens$tokens, u = 15)

# Búsqueda de emojis en los mensajes de texto
post_al_mza_emojis <- lookup_emoji(post_al_mza, text_field = "texto_post")

# Preparación de datos para visualización de emojis más utilizados
plotEmojis <- post_al_mza_emojis %>% 
  unnest(emoji, emoji_name) %>% 
  mutate( emoji = str_sub(emoji, end = 1)) %>% 
  mutate( emoji_name = str_remove(emoji_name, ":.*")) %>% 
  count(emoji, emoji_name) %>%
  top_n(20, n) %>% 
  arrange(desc(n)) %>%
  mutate(
    emoji_url = 
      map_chr(emoji, 
              ~paste0("https://abs.twimg.com/emoji/v2/72x72/", 
                      as.hexmode(utf8ToInt(.x)),".png")) 
  )

# Visualización de emojis más utilizados
plotEmojis %>% 
  ggplot(aes(x=reorder(emoji_name, n), y=n)) +
  geom_col(aes(fill=n), show.legend = FALSE, width = .2) +
  geom_point(aes(color=n), show.legend = FALSE, size = .5) +
  geom_image(aes(image=emoji_url), size=.04) +
  scale_fill_gradient(low="#2b83ba",high="#d7191c") +
  scale_color_gradient(low="#2b83ba",high="#d7191c") +
  ylab("Número de veces que el emoji fue usado") +
  xlab("Emoji y significado") +
  ggtitle("Emojis más utilizados") +
  coord_flip() +
  theme_minimal()

# FUENTES
# https://rpubs.com/mgsaavedraro/911783
# https://quanteda.io/articles/pkgdown/examples/twitter.html