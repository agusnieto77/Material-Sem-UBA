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

# Análisis de frecuencia de bigramas
textstat_frequency(dfm(tokens_ngrams(tokens(acep_cleaning(texto_limpio$texto)), n = 2))) %>% 
  head(20) %>% 
  ggplot() +
  geom_bar(aes(x=reorder(feature, frequency), y=frequency), fill = "white",
           color = "grey30", stat = "identity", show.legend = F) +
  labs(x = NULL, y = NULL) +
  coord_flip() +
  theme_classic() +
  theme(text = element_text(size = 14))

# Continuación del análisis de bigramas, limpieza de texto con ACEP
# Tokenización, análisis de frecuencia y visualización de términos
# Análisis de emojis
# FUENTES
# https://rpubs.com/mgsaavedraro/911783
# https://quanteda.io/articles/pkgdown/examples/twitter.html