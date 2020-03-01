library(shiny)

shinyUI(fluidPage(
    titlePanel(tags$h1(
        "Explore the relationship between HP and MPG"
    )),
    
    sidebarLayout(
        sidebarPanel(
            sliderInput(
                "hp_slider",
                label = "What is the hp of the car?",
                min = 52,
                max = 335,
                value = 70
            ),
            
            checkboxInput("model1_line", label = "Show Simple Regression Line", value = FALSE),
            checkboxInput("model2_line", label = "Show Polynomial Regression Line", value = FALSE),
            textOutput("df_title"),
            tableOutput("sel_points")
        ),
        mainPanel(
            tags$h3("HorsePower Boxplot"),
            plotOutput("boxplot_hp", height = 150),
            tags$h3("Regression Plot"),
            plotOutput("plot", brush = brushOpts("brush1"), height = 500)
        )
    )
))
