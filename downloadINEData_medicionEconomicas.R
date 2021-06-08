rm(list=ls())
options(scipen = 999)
library(rvest)
library(tidyverse)
library(purrr)
library(stringr)
library(jsonlite)

# Change your working directory here to the folder in which you want the data downloaded.
setwd("/home/bscuser/Escritorio/mobility/")

######## Direct links to the JSON files ###########
# Data comes from: https://www.ine.es/experimental/defunciones/experimental_defunciones.htm

###########################################################################################################
###########################################################################################################

# Defunciones semanales, acumuladas y variación interanual del acumulado. Total nacional y CCAA. 2000-2021
defuncionesSemanales_CCAA <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/35177?tip=AM&"

# Defunciones semanales, acumuladas y variación interanual del acumulado. Total nacional y provincias. 2000-2021
defuncionesSemanales_provincias <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/35176?tip=AM&"

# Defunciones semanales acumuladas y variación interanual del acumulado. Islas. 2000-2021
defuncionesSemanales_Islas <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/35178?tip=AM&"

# Defunciones semanales, acumuladas y diferencia absoluta del acumulado por sexo y edad. Total nacional y comunidades autónomas. 2019-2021
defuncionesSemanales_SexoEdad_CCAA <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/35179?tip=AM&"

# Defunciones semanales, acumuladas y diferencia absoluta del acumulado por sexo y edad. Total nacional y provincias. 2019-2021
defuncionesSemanales_SexoEdad_provincias <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/36166?tip=AM&"

###########################################################################################################
###########################################################################################################

# Distribución del gasto en destino realizado por los visitantes extranjeros en sus visitas a España

# Distribución del gasto en destino realizado en cada comunidad autónoma según país de residencia
gastosExtranjeros_CCAA_1 <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/37670?tip=AM&"

# Distribución del gasto en destino de cada país de residencia según comunidad autónoma
gastosExtranjeros_CCAA_2 <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/37671?tip=AM&"

# Gasto medio diario por visitante según comunidad autónoma y país de residencia
gastosMedioDiario_CCAA <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/37672?tip=AM&"

# Gasto medio por visitante según comunidad autónoma y país de residencia
gastosMedioPorVisitante_CCAA <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/37673?tip=AM&"

# Gasto en destino según comunidad autónoma y país de residencia
gastoDestino_CCAA <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/39367?tip=AM&"

# NOTE: Did not collect annual data ( https://www.ine.es/dynt3/inebase/index.htm?padre=7459 )

###########################################################################################################
###########################################################################################################

# Estimación Mensual de Nacimientos

# Nacimientos mensuales, acumulados y variación interanual del acumulado. Total nacional y CCAA
nacimientosMensuales_CCAA_variacion <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/46678?tip=AM&"

# Nacimientos mensuales, acumulados y variación interanual del acumulado. Total nacional y provincias
nacimientosMensuales_Provincias_variacion <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/46679?tip=AM&"

# Nacimientos mensuales, acumulados y diferencia absoluta interanual del acumulado. Total nacional y CCAA
nacimientosMensuales_CCAA_diferenciaAbsoluta <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/46680?tip=AM&"

# Nacimientos mensuales, acumulados y diferencia absoluta interanual del acumulado. Total nacional y provincias
nacimientosMensuales_Provincias_diferenciaAbsoluta <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/46681?tip=AM&"

###########################################################################################################
###########################################################################################################


JSON_INE_Links <- as.character(mget(ls()))

lnk <- JSON_INE_Links[1]

x <- fromJSON(lnk)


