library(pdftools)
library(stringr)
library(tidyverse)
library(lubridate)
library(tidytext)

# Tomo el código para revistas formato 1 (OSAL_1_a_9) y sucesivos
# osal_6

osal_6 <- pdf_text("https://github.com/agusnieto77/Sem-UBA/raw/master/datos/osal6arbramex.pdf")
osal_6 <- tibble(x = unlist(str_split(osal_6, "[\\r\\n]+"))) 

#Creo una nueva columna con los numeros de filas 
#y filtro las filas de Argentina:
osal_6 <- osal_6 %>% mutate(rn = row_number()) %>% filter(rn <= 361)

osal_6$x <- str_trim(osal_6$x)

osal_6 <- osal_6 %>% mutate(x = str_replace_all(x,'[:blank:]+',' '))

osal_6_normalizado <- osal_6 %>% 
  rename(texto = x) %>%
  mutate(pais = 'Argentina') %>%  #a diferencia de Osal_2 aqui recortamos a Argentina, 
  mutate(anio = 2001) %>% 
  mutate(mes = case_when(texto == 'ENERO' ~ 1,
                         texto == 'FEBRERO' ~ 2,
                         texto == 'MARZO' ~ 3,
                         texto == 'ABRIL' ~ 4,
                         texto == 'MAYO' ~ 5,
                         texto == 'JUNIO' ~ 6,
                         texto == 'JULIO' ~ 7,
                         texto == 'AGOSTO' ~ 8,
                         texto == 'SEPTIEMBRE' ~ 9,
                         texto == 'OCTUBRE' ~ 10,
                         texto == 'NOVIEMBRE' ~ 11,
                         texto == 'DICIEMBRE' ~ 12,
                         TRUE ~ 0)) %>%
  filter(texto != 'Argentina') %>%
  filter(texto != 'e r o') %>% 
  filter(texto != 'o') %>% 
  filter(texto != 'l') %>% 
  filter(!is.na(texto)) %>% 
  mutate(dif = Reduce("+", mes, accumulate = T)) %>% 
  mutate(mes = case_when(dif == 9 ~ 9,		
                         dif == 19 ~ 10,		
                         dif == 30 ~ 11,		
                         dif == 42 ~ 12))		%>% 
  filter(!str_detect(texto, 'ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE')) %>% 
  mutate(dia = case_when(str_detect(texto, '[A-Z].+(es|do|go)\\s1 .') ~ 1,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s2 .')  ~ 2,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s3 .') ~ 3,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s4 .') ~ 4,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s5 .') ~ 5,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s6 .') ~ 6,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s7 .') ~ 7,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s8 .') ~ 8,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s9 .') ~ 9,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s10 .') ~ 10,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s11 .') ~ 11,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s12 .') ~ 12,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s13 .') ~ 13,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s14 .') ~ 14,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s15 .') ~ 15,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s16 .') ~ 16,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s17 .') ~ 17,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s18 .') ~ 18,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s19 .') ~ 19,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s20 .') ~ 20,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s21 .') ~ 21,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s22 .') ~ 22,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s23 .') ~ 23,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s24 .') ~ 24,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s25 .') ~ 25,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s26 .') ~ 26,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s27 .') ~ 27,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s28 .') ~ 28,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s29 .') ~ 29,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s30 .') ~ 30,
                         str_detect(texto, '[A-Z].+(es|do|go)\\s31 .') ~ 31,
                         TRUE ~ 0)) %>% ungroup() %>% select(-dif)

for (i in 1:100) { 
  osal_6_normalizado <- osal_6_normalizado %>%  
    mutate(dia = case_when(dia == 0 & lag(dia, n = 1) == 1 ~ 1,
                           dia == 0 & lag(dia, n = 1) == 2 ~ 2,
                           dia == 0 & lag(dia, n = 1) == 3 ~ 3,
                           dia == 0 & lag(dia, n = 1) == 4 ~ 4,
                           dia == 0 & lag(dia, n = 1) == 5 ~ 5,
                           dia == 0 & lag(dia, n = 1) == 6 ~ 6,
                           dia == 0 & lag(dia, n = 1) == 7 ~ 7,
                           dia == 0 & lag(dia, n = 1) == 8 ~ 8,
                           dia == 0 & lag(dia, n = 1) == 9 ~ 9,
                           dia == 0 & lag(dia, n = 1) == 10 ~ 10,
                           dia == 0 & lag(dia, n = 1) == 11 ~ 11,
                           dia == 0 & lag(dia, n = 1) == 12 ~ 12,
                           dia == 0 & lag(dia, n = 1) == 13 ~ 13,
                           dia == 0 & lag(dia, n = 1) == 14 ~ 14,
                           dia == 0 & lag(dia, n = 1) == 15 ~ 15,
                           dia == 0 & lag(dia, n = 1) == 16 ~ 16,
                           dia == 0 & lag(dia, n = 1) == 17 ~ 17,
                           dia == 0 & lag(dia, n = 1) == 18 ~ 18,
                           dia == 0 & lag(dia, n = 1) == 19 ~ 19,
                           dia == 0 & lag(dia, n = 1) == 20 ~ 20,
                           dia == 0 & lag(dia, n = 1) == 21 ~ 21,
                           dia == 0 & lag(dia, n = 1) == 22 ~ 22,
                           dia == 0 & lag(dia, n = 1) == 23 ~ 23,
                           dia == 0 & lag(dia, n = 1) == 24 ~ 24,
                           dia == 0 & lag(dia, n = 1) == 25 ~ 25,
                           dia == 0 & lag(dia, n = 1) == 26 ~ 26,
                           dia == 0 & lag(dia, n = 1) == 27 ~ 27,
                           dia == 0 & lag(dia, n = 1) == 28 ~ 28,
                           dia == 0 & lag(dia, n = 1) == 29 ~ 29,
                           dia == 0 & lag(dia, n = 1) == 30 ~ 30,
                           dia == 0 & lag(dia, n = 1) == 31 ~ 31,
                           TRUE ~ as.numeric(dia)))
}

# con esta línea comprobamos si hay o no 0s
osal_6_normalizado %>% filter(dia == 0) %>% select(dia) %>% as_vector()

osal_6_normalizado <- osal_6_normalizado %>% 
  filter(texto != '/ Enero 2002', 
         texto != 'Cronolog?a',
         texto != 'Argentina',
         texto != '66', texto != '67', texto != '68', texto != '69', 
         texto != '70', texto != '71', texto != '72', texto != '73',
         texto != ' ')

OSAL <- osal_6_normalizado %>% unite('fecha', anio:dia, sep = '-') %>% 
  mutate(fecha = as.Date(fecha)) %>%
  group_by(pais, fecha) %>% summarise(texto = paste0(texto, collapse = ' ')) %>% 
  ungroup() %>% select(pais, fecha, texto) %>% 
  mutate(texto = str_remove_all(texto, '- ')) %>% 
  mutate(texto = str_remove_all(texto, '[A-Z].+(es|do|go)\\s\\d .')) %>%
  mutate(texto = str_remove_all(texto, '[A-Z].+(es|do|go)\\s\\d{2} .')) %>%
  mutate(texto = str_remove_all(texto, '•')) %>%
  mutate(texto = str_remove_all(texto, '^\\s'))


