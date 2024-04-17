
# Cargamos los tweets -----------------------------------------------------

tweets <- readRDS("./scripts/U02/dengue/data/tweets.rds")

# Cargamos las librerías --------------------------------------------------

require(ACEP)

# Limpieza de texto con ACEP ----------------------------------------------

tweets_limpios <- acep_cleaning(tweets, other_sw = c("si", "dengue"))


# Tokenización ------------------------------------------------------------

(tokens <- acep_token(tweets_limpios))

# Análisis de frecuencia --------------------------------------------------

(tabla <- acep_token_table(tokens$tokens, u = 15))

# Visualización -----------------------------------------------------------

acep_token_plot(tokens$tokens, u = 15)
