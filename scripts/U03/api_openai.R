# Requerir bibliotecas
require(ACEP)
require(jsonlite)
require(dplyr)

# Cargamos los textos
textos <- readLines("https://raw.githubusercontent.com/agusnieto77/Sem-UBA/master/datos/textos.txt")

# Definir instrucciones para el procesamiento del texto
instrucciones_01_en <- "Its task is to identify vessel arrivals in the text as units of analysis and generate a JSON including only 13 keys: 
'id', 'date_news', 'date_arrival', 'vessel_type', vessel_nacionality, 'vessel_name', 'tonnage', 'role', 'captain_name', 'port_departure', 'date_departure', 'commodities', 'consignee'.
The values of the 13 keys must be the product of clean extractions from the text.
None of the values entered should be nested in a list.
    'id': Unique identifier of the text in numeric format. It is repeated for all arrivals and is the first to appear.
    'date_news': 'yyyy-mm-dd' format of the arrival date. The same value is repeated for all actions and is the first date to appear.
    'date_arrival': 'yyyy-mm-dd' format of the date of the protest action. The same value is repeated for all arrivals and is the first date displayed.
    'vessel_type': Identifies the type of vessel.
    'vessel_nacionality': Identifies the flag of the vessel. It can be 'nacional', 'n.' ['n' == 'nacional'], 'francesa', 'inglés', 'inglesa', 'oriental', etc.
    'vessel_name': Name of the vessel.
    'tonnage' describes the total tonnage of the vessel [is integer].
    'role': classify according to these tags: 'capitán', 'patrón'. [cap. == capitán, p. == patrón]. 
    'captain_name': identifies the proper name of the person driving the vessel.
    'port_departure': Describes from which port the vessel departed (this is the first port named in the sentence, it must always be 1 only, it cannot be more than 1).
    'date_departure': Extract the date of departure of the vessel. It can be day or day and month. Examples: 'el 7 de Enero', 'el 21', 'el 1º'. 
    'commodities': describe the cargo carried. Where there is more than one cargo, separate with ';'.
    'consignee': Identifies the names of the consignees which are always preceded by an 'á' or 'al' ['al patrón', for example]. When more than one separate with ';'.
Missing values must be completed with an NA."

# Procesar notas del documento
# Crea un nuevo objeto tibble vacío
df_sao_gpt <- tibble()
# Ciclo for
for (i in seq_along(textos)) {
  condicion_cumplida <- FALSE
  message(paste("Procesando ID:", i))
  while (!condicion_cumplida) {
    salida <- tryCatch(fromJSON(toJSON(acep_gpt(texto = textos[i], 
                                                instrucciones = instrucciones_01_en,
                                                gpt_api = "sk-proj-zYT0rctIyWsy6hJAad0pT3BlbkFJlsayyHmI4Ms2bVd2RZ5M"))), 
                       error = function(e) NULL)
    
    if (length(lapply(salida, fromJSON, simplifyDataFrame = TRUE)[[1]]) == 13) {
      salida_ok <- lapply(salida, fromJSON, simplifyDataFrame = TRUE)[[1]]
      df_sao_gpt <- rbind(df_sao_gpt, salida_ok)
      condicion_cumplida <- TRUE
    } else {
      
      salida <- tryCatch(fromJSON(toJSON(acep_gpt(texto = textos[i], 
                                                  instrucciones = instrucciones_01_en,
                                                  gpt_api = "sk-proj-zYT0rctIyWsy6hJAad0pT3BlbkFJlsayyHmI4Ms2bVd2RZ5M"))), 
                         error = function(e) NULL)
    }
  }
  
}
