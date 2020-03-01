library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)

cars_data <- as_tibble(mtcars) %>% 
    tibble::add_column(car_name = rownames(mtcars)) %>%
    select(car_name, hp, mpg)

p <- ggplot(cars_data, aes(x = hp, y = mpg)) + 
    geom_point(shape = 21, fill = "white") + 
    geom_text_repel(aes(label = car_name), size = 4)

b <- ggplot(cars_data, aes(x = 1, y = hp, group = 1)) +
    geom_boxplot(width = 0.25) +
    scale_x_continuous("", breaks = NULL) + 
    coord_flip()


model_0 <- lm(mpg ~ hp, data = cars_data)
model_1 <- lm(mpg ~ poly(hp, 2), data = cars_data)

y_0 <- predict(model_0)
y_1 <- predict(model_1)
pred_data_0 <- tibble(x = cars_data$hp, y = y_0)
pred_data_1 <- tibble(x = cars_data$hp, y = y_1)

model_0_line <-
    geom_line(data = pred_data_0, aes(x = x, y = y_0), color = "red")
model_1_line <-
    geom_line(data = pred_data_1, aes(x = x, y = y_1), color = "blue")

shinyServer(function(input, output) {
    
    hp <- reactive({input$hp_slider})
    
    output$plot <- renderPlot({
        
        hp_pred <- predict(model_0, newdata = data.frame(hp = hp()))
        hp_poly_pred <- predict(model_1, newdata = data.frame(hp = hp()))
        
        model_0_point <-
            geom_point(
                data = data.frame(hp = hp(), pred_mpg = hp_pred),
                aes(x = hp, y = hp_pred),
                color = "red",
                size = 4,
                shape = 22, 
                fill = "red"
            )
        model_1_point <-
            geom_point(
                data = data.frame(hp = hp(), pred_mpg = hp_poly_pred),
                aes(x = hp, y = hp_poly_pred),
                color = "blue",
                size = 4,
                shape = 22, 
                fill = "blue"
            )
        
        data_table <- reactive({
            sel_points <-
                brushedPoints(cars_data, input$brush1, xvar = "hp", yvar = "mpg")
        })
        
        if (nrow(data_table()) != 0) {
            output$df_title <- renderText("Selected Cars Data")
            output$sel_points <- renderTable({data_table()})
        } else {
            output$df_title <- renderText("No Selected Cars!")
            output$sel_points <- NULL
        }
        
        if (input$model1_line) {
            if (input$model2_line) {
                p <- p + model_0_line + model_0_point + model_1_line + model_1_point
            } else {
                p <- p + model_0_line + model_0_point
            }
        } else {
            p <- p
        }
        p
    })
    
    output$boxplot_hp <- renderPlot({
        b <-
            b + geom_point(
                aes(y = input$hp_slider),
                color = "red",
                size = 3,
                shape = 22
            )
        b
    })
    
})
