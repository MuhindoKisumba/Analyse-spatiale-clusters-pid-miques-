############################################################
# CARTE SIG RDC (ZONES DE SANTE REELLES)
# Shapefile + Leaflet + Heatmap + Clustering
############################################################

library(shiny)
library(leaflet)
library(sf)
library(DBI)
library(RPostgres)
library(dplyr)
library(leaflet.extras)

# ==============================
# 1. CONNEXION DB
# ==============================
con <- dbConnect(RPostgres::Postgres(),
                 dbname="epidemiologie",
                 host="postgres",
                 user="postgres",
                 password="password")

# ==============================
# 2. CHARGEMENT SHAPEFILE
# ==============================
# Remplace par ton fichier réel (.shp)
zones <- st_read("data/rdc_zones_sante.shp")

# ==============================
# 3. UI
# ==============================
ui <- fluidPage(
  titlePanel("OMS - Carte RDC Zones de Santé"),
  leafletOutput("map", height = "800px")
)

# ==============================
# 4. SERVER
# ==============================
server <- function(input, output, session){
  
  get_data <- reactivePoll(
    3000, session,
    checkFunc = function(){
      dbGetQuery(con, "SELECT MAX(date) FROM cas_epidemio")
    },
    valueFunc = function(){
      dbGetQuery(con, "SELECT * FROM cas_epidemio")
    }
  )
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 23.65, lat = -2.88, zoom = 5) %>%
      
      # Zones de santé
      addPolygons(
        data = zones,
        fillColor = "transparent",
        color = "cyan",
        weight = 1,
        popup = ~NAME
      )
  })
  
  observe({
    df <- get_data()
    
    leafletProxy("map", data = df) %>%
      clearMarkers() %>%
      clearHeatmap() %>%
      
      # Points
      addCircleMarkers(
        ~lon, ~lat,
        radius = ~cas/50,
        color = "red",
        clusterOptions = markerClusterOptions(),
        popup = ~paste(region, "<br>Cas:", cas)
      ) %>%
      
      # Heatmap
      addHeatmap(
        lng = ~lon,
        lat = ~lat,
        intensity = ~cas,
        blur = 20,
        max = 0.05
      )
  })
}

shinyApp(ui, server)
