
# Corremos el script "scraping.R" -----------------------------------------

source("./scripts/U02/dengue/scraping.R")

# Borramos todas las variables y objetos del entorno de trabajo -----------

rm(list = ls())

# Corremos el script "mineria.R" ------------------------------------------

source("./scripts/U02/dengue/mineria.R")
