library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(sf)
library(shinydashboard)
st_drivers()

# Load data
#hiv_data <- read.csv("C:/Users/Anarchy/Downloads/HIV_Prevlance percounty.csv" )
kenya_shapefile <- st_read("C:/Users/Anarchy/Downloads/L4H_sample_data/shapefiles/County.shp")

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
      .logo-container {
      position: absolute;
      top: 15px;
      right: 10px;
      z-index:1000;
      }
      .logo-container img {
      height: 171px;
      width: 295px;
      object-fit: contain;
      }
      
    "))
  ),
  
  #Logo
  div(class = "logo-container",
      img(src= "CEMA.jpeg", alt= "Logo")
      ),

  
  # Title
  titlePanel("Kenya Healthcare Dashboard"),
  
  # Navigation tabs at the top
  tabsetPanel(
    id = "navbar",
    type = "tabs",
    
    # Map Tab
    tabPanel("Map", 
             fluidRow(
               column(3,
                      wellPanel(
                        selectInput("county_filter", "Select County:", 
                                    choices = c("All", unique(hiv_data$County)),
                                    selected = "All"),
                        selectInput("hiv_filter", "HIV Prevalence:", 
                                    choices = c("All", sort(unique(hiv_data$`HIV prevalence`))),
                                    selected = "All"),
                        selectInput("worker_filter", "Type of Health Worker:", 
                                    choices = c("All", unique(hiv_data$`Type of Worker`)),
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
                        selectInput("county_filter_bar", "Select County:", 
                                    choices = c("All", unique(hiv_data$County)),
                                    selected = "All"),
                        selectInput("hiv_filter_bar", "HIV Prevalence:", 
                                    choices = c("All", sort(unique(hiv_data$`HIV prevalence`))),
                                    selected = "All"),
                        selectInput("worker_filter_bar", "Type of Health Worker:", 
                                    choices = c("All", unique(hiv_data$`Type of Worker`)),
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
# Server
server <- function(input, output, session) {
  # Reactive data for filters
  filtered_data <- reactive({
    data <- hiv_data
    if (input$county_filter != "All") {
      data <- data[data$County == input$county_filter, ]
    }
    if (input$hiv_filter != "All") {
      data <- data[data$`HIV prevalence` == input$hiv_filter, ]
    }
    if (input$worker_filter != "All") {
      data <- data[data$`Type of Worker` == input$worker_filter, ]
    }
    return(data)
  })
  
  # Render Leaflet Map
  output$kenya_map <- renderLeaflet({
    leaflet(data = kenya_shapefile) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~colorQuantile("YlOrRd", filtered_data()$`HIV prevalence`)(filtered_data()$`HIV prevalence`),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(weight = 5, color = "#666", bringToFront = TRUE),
        label = ~paste("County:", County, "<br>",
                       "Population:", Population, "<br>",
                       "HIV Prevalence:", `HIV prevalence`, "<br>",
                       "Deficit Workers:", Deficit)
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