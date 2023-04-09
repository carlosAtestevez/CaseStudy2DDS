
#Libraries
library(shiny)
library(colourpicker)
library(tidyverse)
library(dbplyr)
library(caret)
library(e1071)
library(maps)
library(usmap)
library(RANN)
library(shiny)
library(RCurl)
library(aws.s3)

#Initialization
lst_type_plot = c("Histogram","Boxplot")
df_usa_states_0 = usmapdata::centroid_labels("states")
df_usa_states_1 = df_usa_states_0$full
df_usa_states_1 = append(df_usa_states_1,"ALL")

ui <- fluidPage(
  tags$figure(
    align = "left",
    tags$img(
      src = "dds_logo.png",
      width = 200,
      alt = "Picture of an astragalus (bone die)"
    ),
    tags$figcaption("")
  ),
  titlePanel("Beer study across the United States"),
  tabsetPanel(id="tabset",
              tabPanel("Amazon S3 data loading",icon = icon("aws"),
                       passwordInput("cpinKey","Inroduce Key id"),
                       passwordInput("cpinAcKey","Introduce Access Key"),
                       textInput("ctxBucket","Bucket name"),
                       checkboxInput("cchS3IMG","Store plots S3"),
                       checkboxInput("cchS3","Use Amazon S3")
                       
              ),
               tabPanel("Manual data loading",
                        fileInput("cflBeers","Select beer's file",accept = c(".csv", ".tsv")),
                        fileInput("cflBreweries","Select breweries's file",accept = c(".csv", ".tsv")),
                        numericInput("cnrKnn","Knn Imputation(N)",min=5,max=30,value = 20),
                        checkboxInput("cchDS","Activate data cleansing IBU and ABV")
               ),
               tabPanel("IBU hist/box",
                        fluidRow(
                        column(3,"Parameters plot",
                        selectInput("ccsTypePlot","Select type of plot",lst_type_plot),
                        colourInput("cciCoIBU","Select the color",value = "blue"),
                        sliderInput("cslBrIBU","Select number of breaks",min=1,max=1000,value = 100),
                        sliderInput("cslWdIBU","Select Bin width",min=0.1,max=10,value = 0.1)),
                        column(6,"Filters",
                        selectInput("cseStates","Select the state",df_usa_states_1,selected = "ALL")))
               ),
               tabPanel("ABV hist/box", 
                        fluidRow(
                        column(3,"Parameters plot",
                        selectInput("ccsTypePlotABV","Select type of plot",lst_type_plot),
                        colourInput("cciCoABV","Select the color",value = "green"),
                        sliderInput("cslBrABV","Select number of breaks",min=1,max=1000,value = 100),
                        sliderInput("cslWdABV","Select Bin width",min=0.1,max=10,value = 0.1)),
                        column(6,"Filters",
                               selectInput("cseStatesABV","Select the state",df_usa_states_1,selected = "ALL")))
               ),
           tabPanel("ABV vs IBU", 
           checkboxInput("cchAddLineal","Add linear regression line"),
           selectInput("cseStatesAI","Select the state",df_usa_states_1,selected = "ALL")
           ),
           tabPanel("MAP", 
                    numericInput("cnrNrBrew","Number of important breweries",min=1,max=20,value = 5)
           )
           
  ),
  
  h4("Section for plotting"),
  fluidRow(
    column(2,"",plotOutput("ploIBU")),
    column(2,"",plotOutput("ploABV")),
    column(3,"",plotOutput("ploABVIBU")),
    column(5,"",plotOutput("ploAdd"))
    ),
    fluidRow(
      column(12,"",verbatimTextOutput("outSection"))
    ),
    tableOutput("tbOut")
  )
  

