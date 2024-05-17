
devtools::install_github("agusnieto77/ACEP")

library(ACEP)
library(dplyr)

diccionario <- acep_load_base(acep_diccionarios$dicc_confl_sismos)

print(diccionario)

download.file("https://github.com/agusnieto77/Sem-UBA/raw/master/datos/ARGENMEX2000a2008corregido200324.rds",
              destfile = "baseARMEX.rds", mode = "wb")

baseARMEX <- readRDS("baseARMEX.rds")

baseARMEX$detect <- acep_detect(baseARMEX$texto, diccionario, u = 1, tolower = TRUE)

baseARMEX %>% count(detect)

noconflictos <- baseARMEX %>% filter(detect == 0)

head(noconflictos$texto, 50)
