library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(sf)
library(shinydashboard)
library(MetBrewer)
#st_drivers()

# Load data
raw_sf_data <- sf::st_read("./data/county_shapefiles/ken_admbnda_adm1_iebc_20191031.shp")
results_hr_deficits_by_county_and_cadre <- readRDS("./outputs/results_hr_deficits_by_county_and_cadre.rds")


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
                        
                      ),
                      #Bar graph added below the filters
                      plotOutput("county_bar_graph", height = "600px", width = "500px")
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
                                      "Hours Available per Year" = "hours_available_per_year",
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
  # Reactive value to store the selected county
  selected_county <- reactiveVal(NULL)
  
  # Reactive data for map
  map_data <- reactive({
    data <- results_hr_deficits_by_county_and_cadre
    
    # Filter by District
    if (input$District_filter != "All") {
      data <- data[data$district == input$District_filter, ]
    }
    
    # Handle Cadre filtering
    if (input$Cadre == "All") {
      # Sum across all cadres
      aggregated_data <- data %>%
        group_by(district) %>%
        summarise(value = sum(.data[[input$Indicator]], na.rm = TRUE))
    } else {
      # Filter for specific cadre
      data <- data[data$cadre == input$Cadre, ]
      aggregated_data <- data %>%
        group_by(district) %>%
        summarise(value = sum(.data[[input$Indicator]], na.rm = TRUE))
    }
    
    # Aggregate data by district
    aggregated_data <- data %>%
      group_by(district) %>%
      summarise(value = sum(.data[[input$Indicator]], na.rm = TRUE))
    
    # Merge with shapefile
    map_sf <- raw_sf_data %>%
      left_join(aggregated_data, by = c("ADM1_EN" = "district")) 
    # Keep only regions within Kenya
    #map_sf <- map_sf %>%
    #filter(!is.na(value)) # Ensure only valid data for Kenya remains
    return(map_sf)
  })
  
  # Render Leaflet Map
  output$kenya_map <- renderLeaflet({
    mapdata <- map_data()
    
    # Color palette
    lim <- max(abs(mapdata$value), na.rm = T)
    pal <- colorNumeric(
      palette = c(met.brewer("Demuth",11)), 
      domain = c(-lim,lim) # mapdata$value #
    )
    
    
    #Create Leaflet map 
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
      ) %>%
      #Add Legend
      addLegend(
        pal = pal,
        values = ~value,
        title = input$Indicator,
        position = "bottomright"
      )
  })
  
  
  # Update selected county on map click
  observeEvent(input$kenya_map_shape_click, {
    selected_county(input$kenya_map_shape_click$id)
  })
  
  # Reactive data for bar graph
  bar_graph_data <- reactive({
    req(input$kenya_map_shape_click$id)  # Ensure a county is selected
    data <- results_hr_deficits_by_county_and_cadre %>%
      filter(district == input$kenya_map_shape_click$id) %>%
      group_by(cadre) %>%
      summarise(deficit_in_number_per_year = sum(deficit_in_number_per_year, na.rm = TRUE))
    return(data)
  })
  
  # Render the bar graph
  output$county_bar_graph <- renderPlot({
    # Retrieve the selected county from the input
    selected_county <- input$kenya_map_shape_click$id  # Adjust the input ID based on your UI setup
    
    data <- bar_graph_data()
    ggplot(data, aes(y = reorder(cadre, -deficit_in_number_per_year), x = deficit_in_number_per_year, fill = "red")) +
      geom_bar(stat = "identity") +
      labs(title = "Deficit in Number per Year by Cadre", x = "Deficit", y = "", subtitle = selected_county) +

      theme_minimal() +
      scale_y_discrete(label = function(x) str_wrap(x, width=20)) + 
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 16),  # Rotate x-axis labels for better readability
        axis.text.y = element_text(size = 12),
        legend.position = "none",  # Remove the legend
        plot.subtitle = element_text(size = 16, face = "bold", hjust = 0.5),
        plot.title = element_text(size = 16, face = "bold"),  # Increase title font size
        axis.title.x = element_text(size = 14),  # Adjust x-axis label font size
        axis.title.y = element_text(size = 14)   # Adjust y-axis label font size
      )
  }, height = 500, width = 450)  # Increased height and width for better visualization
  
}

# Run App
shinyApp(ui, server)