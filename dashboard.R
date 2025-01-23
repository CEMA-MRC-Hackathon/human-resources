library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(sf)
library(shinydashboard)
#st_drivers()

# Load data
raw_sf_data <- sf::st_read("./data/county_shapefiles/ken_admbnda_adm1_iebc_20191031.shp")
results_hr_deficits_by_county_and_cadre <- readRDS("~/human-resources/outputs/results_hr_deficits_by_county_and_cadre.rds")


# Rename district values to match the shapefile names
results_hr_deficits_by_county_and_cadre <- results_hr_deficits_by_county_and_cadre %>%
  mutate(
    district = case_when(
      district == "Elgeyo Marakwet" ~ "Elgeyo-Marakwet",
      district == "Muranga" ~ "Murang'a",
      district == "Tharaka Nithi" ~ "Tharaka-Nithi",
      TRUE ~ district # Retain other values as is
    )
  )

# Verify the changes
unique(results_hr_deficits_by_county_and_cadre$district)
unmatched <- setdiff(raw_sf_data$ADM1_EN, results_hr_deficits_by_county_and_cadre$district)
print(unmatched)


# UI
ui <- fluidPage(
  # Custom CSS for nav tabs
  tags$head(
    tags$style(HTML("
      .nav-tabs {
        margin-bottom: 15px;
        background-color: #ecf0f5;
        border-bottom: 2px solid #3c8dbc;
      }
      .nav-tabs > li > a {
        padding: 10px 15px;
        color: #444;
      }
      .nav-tabs > li.active > a {
        background-color: #3c8dbc !important;
        color: white !important;
      }
      .logo-container img {
        height: 50px;
        width: 300px;
        object-fit: contain;
        display: block;
        margin: auto;
      }
      .header-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 15px;
        background-color: #ecf0f5;
        border-bottom: 2px solid #3c8dbc;
      }
      .title-container {
        font-size: 24px;
        font-weight: bold;
        color: #3c8dbc;
      }
    "))
  ),
  
  # Header with title and logo
  div(class = "header-container",
      div(class = "title-container",
          "Kenya Healthcare Dashboard"
      ),
      div(class = "logo-container",
          img(src = "CEMA.jpeg", alt = "Logo")
      )
  ),
  
  # Navigation tabs at the top
  tabsetPanel(
    id = "navbar",
    type = "tabs",
    
    # Map Tab
    tabPanel("Map", 
             fluidRow(
               column(3,
                      wellPanel(
                        selectInput("District_filter", "Select District:", 
                                    choices = c("All", unique(results_hr_deficits_by_county_and_cadre$district)),
                                    selected = "All"),
                        selectInput("Disease_filter", "Select Disease:", 
                                    choices = "HIV",
                                    selected = "HIV"),
                        selectInput("Indicator", "Select Indicator:", 
                                    choices = c(
                                      "Hours Needed per Year" = "hours_needed_per_year",
                                      "Number of Workers" = "number", 
                                      "Hours Available per Year" = "hours_avaialable_per_year",
                                      "Deficit in Hours per Year" = "deficit_in_hours_per_year",
                                      "Deficit in Number per Year" = "deficit_in_number_per_year"
                                    ),
                                    selected = "hours_needed_per_year"),
                        selectInput("Cadre", "Select Cadre:", 
                                    choices = c("All", unique(results_hr_deficits_by_county_and_cadre$cadre)),
                                    selected = "All")
                      )
               ),
               column(9,
                      leafletOutput("kenya_map", height = "800px")
               )
             )
    ),
    
    # Graph Tab
    tabPanel("Graph",
             fluidRow(
               column(3,
                      wellPanel(
                        selectInput("District_filter", "Select District:", 
                                    choices = c("All", unique(results_hr_deficits_by_county_and_cadre$district)),
                                    selected = "All"),
                        selectInput("Disease_filter", "Select Disease:", 
                                    choices = "HIV",
                                    selected = "HIV"),
                        selectInput("Indicator", "Select Indicator:", 
                                    choices = c(
                                      "Hours Needed per Year" = "hours_needed_per_year",
                                      "Number of Workers" = "number", 
                                      "Hours Available per Year" = "hours_avaialable_per_year",
                                      "Deficit in Hours per Year" = "deficit_in_hours_per_year",
                                      "Deficit in Number per Year" = "deficit_in_number_per_year"
                                    ),
                                    selected = "hours_needed_per_year"),
                        selectInput("Cadre", "Select Cadre:", 
                                    choices = c("All", unique(results_hr_deficits_by_county_and_cadre$cadre)),
                                    selected = "All")
                      )
               ),
               column(9,
                      plotOutput("bar_graph", height = "800px")
               )
             )
    ),
    
    # About Tab
    tabPanel("About",
             fluidRow(
               column(12,
                      h2("About this Dashboard"),
                      h3("Goal"),
                      p("Sustainable investment for health workforce (How to project recruitment model for healthcare workers based on evidence)/How to optimize the health workforce in kenya towards achieving UHC"),
                      h3("Objective"),
                      p("The objective is to: To create a proof-of-concept county-level dashboard, initially for a single disease: HIV, that combines 1) the burden of disease with 2) the healthcare human time-resources required to treat each case, to quantify the total time needed by cadre of healthworker, then compares this need to the current healthcare human time-resources available, to quantify the extent of current unmet needs.")
               )
             )
    ),
    
    # Methodology Tab
    tabPanel("Methodology",
             fluidRow(
               column(12,
                      h2("Methodology"),
                      p("Detailed explanation of data collection and analysis methods used in this dashboard.")
               )
             )
    ),
    
    # Contact Tab
    tabPanel("Contact",
             fluidRow(
               column(12,
                      h2("Contact Information"),
                      p("For questions or feedback about this dashboard, please contact us at:"),
                      p("Email: example@healthdashboard.org"),
                      br(),
                      h3("Team"),
                      tags$ul(
                        tags$li("Moses K. Muriithi - University of Nairobi"),
                        tags$li("John Ojal - KEMRI-Wellcome Trust Research Programme"),
                        tags$li("Jackline Mosinya Nyaberi - JKUAT-School of Public Health, Kenya"),
                        tags$li("Peninna Mwongeli Nzoka - MoH"),
                        tags$li("George Kamundia - CEMA"),
                        tags$li("Francis Ondicho Motiri - MoH"),
                        tags$li("Sabine L. van Elsland - MRC Imperial"),
                        tags$li("Lilith Whittles - MRC Imperial")
                      )
               )
             )
    )
  )
)
# In Server
server <- function(input, output, session) {
  # Reactive data for map
  map_data <- reactive({
    data <- results_hr_deficits_by_county_and_cadre
    
    # Filter by District
    if (input$District_filter != "All") {
      data <- data[data$district == input$District_filter, ]
    }
    
    # Filter by Cadre
    if (input$Cadre != "All") {
      data <- data[data$cadre == input$Cadre, ]
    }
    
    # Aggregate data by district
    aggregated_data <- data %>%
      group_by(district) %>%
      summarise(value = sum(.data[[input$Indicator]], na.rm = TRUE))
    
    # Merge with shapefile
    map_sf <- raw_sf_data %>%
      left_join(aggregated_data, by = c("ADM1_EN" = "district"))
    
    return(map_sf)
  })
  
  # Render Leaflet Map
  output$kenya_map <- renderLeaflet({
    mapdata <- map_data()
    
    # Color palette
    pal <- colorNumeric(
      palette = "YlOrRd", 
      domain = mapdata$value
    )
    
    leaflet(mapdata) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(value),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5, 
          color = "#666", 
          bringToFront = TRUE
        ),
        label = ~paste(
          "District:", ADM1_EN, 
          "<br>", input$Indicator, ":", round(value, 2)
        ),
        # Popup with detailed information
        popup = ~{
          district_details <- results_hr_deficits_by_county_and_cadre %>%
            filter(district == ADM1_EN) %>%
            select(cadre, hours_needed_per_year, number, 
                   hours_avaialable_per_year, deficit_in_hours_per_year, 
                   deficit_in_number_per_year) %>%
            mutate(across(where(is.numeric), round, 2))
          
          # Create HTML table
          table_html <- paste(
            "<table border='1' style='width:100%'>",
            "<tr><th>Cadre</th><th>Hours Needed</th><th>Number</th>",
            "<th>Hours Available</th><th>Deficit (Hours)</th><th>Deficit (Number)</th></tr>",
            apply(district_details, 1, function(row) {
              paste0("<tr>", 
                     paste0("<td>", row, "</td>", collapse = ""),
                     "</tr>")
            }),
            "</table>"
          )
          
          table_html
        }
      )
  })

  
  # Render Bar Graph
  output$bar_graph <- renderPlot({
    data <- filtered_data() %>%
      group_by(County) %>%
      summarise(
        Total_Deficit = sum(Deficit),
        Total_Workers = sum(`Current Workers`)
      )
    
    ggplot(data, aes(x = reorder(County, Total_Deficit), y = Total_Deficit, fill = County)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Deficit vs Current Healthcare Workers", x = "County", y = "Number of Workers") +
      theme_minimal() +
      coord_flip()
  })
}

# Run App
shinyApp(ui, server)