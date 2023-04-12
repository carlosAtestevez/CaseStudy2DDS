
#Libraries
library(class)
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
library(shinyFeedback)
  

#Initialization
lst_cmb_data = c("Amazon S3 Dataset" = "ddset","Manual file"="manfile")
lst_mar_st = c("Single"="3","Married"="2","Divorced"="1")
lst_over_st = c("Yes","No")

ui <- fluidPage(
  tags$figure(
    align = "left",
    tags$img(
      src = "https://imgtr.ee/images/2023/04/09/naEil.png",
      width = 150,
      alt = "DDSAnalytics"
    ),
    tags$figcaption("")
  ),
  tags$h3(
    tags$strong(tags$span(style="color:#e67300","Data analysis about Employee Attrition by DDSAnalytics"))),
  tags$h6(tags$span(style="color:darkblue","Created by Carlos Estevez, email:cestevez@smu.edu")),
  tags$hr(),
  tabsetPanel(id="tabset",
              tabPanel("Loading data",icon = icon("cloud-arrow-up"),
                       radioButtons("crbLoadData","Select type of loading",lst_cmb_data),
                       shinyFeedback::useShinyFeedback(),
                       fileInput("cflAttrFile","Select attrition file",accept = c(".csv", ".tsv")),
                       checkboxInput("cobOverbalancing","Consider overbalancing",value = TRUE),
                       actionButton("btnLoadData","Load data"),
                       tags$hr(),
                       verbatimTextOutput("cboLoadData"),
                       tags$hr(),
                       tags$h4(tags$strong("Plots and Charts")),
                       fluidRow(
                         column(4,"",plotOutput("plotOver")),
                         column(4,"",plotOutput("plotJobLevel")),
                         column(4,"",plotOutput("plotJobLevelMonth")),
                         
                       )
              ),
               tabPanel("Models set-up(KNN and NB)",icon = icon("microchip"),
                        numericInput("cniKnn","KNN Iterations",min=5,max=100,value = 20),
                        sliderInput("cslKnnPer","Percentage Training data",min=50,max=90,value = 75),
                        tags$h5(tags$strong("KNN parameters")),
                        checkboxInput("cchMI","MonthlyIcome",value = TRUE),
                        checkboxInput("cchYC","YearsAtCompany",value = TRUE),
                        checkboxInput("cchOV","Overtime",value = TRUE),
                        checkboxInput("cchSO","StockOptionLevel",value = TRUE),
                        checkboxInput("cchJS","JobSatisfaction",value = TRUE),
                        checkboxInput("ccMS","MaritialStatus",value = TRUE),
                        checkboxInput("cchJL","JobLevel",value = TRUE),
                        actionButton("btnLRunKnn","Run model",icon = icon("bolt") ),
                        tags$hr(),
                        tags$h3(tags$strong("KNN results:")),
                        fluidRow(
                          column(4,"",verbatimTextOutput("cvboRunModel")),
                          column(4,"",dataTableOutput("ctoRunModel")),
                          column(4,"",plotOutput("ploKnnModel"))
                        ),
                        tags$hr(),
                        tags$h3(tags$strong("Naive Bayes results:")),
                        fluidRow(
                          column(12,"",verbatimTextOutput("cvboNaive"))
                        ),
                        tags$hr(),
                        tags$h3(tags$strong("Logistic Regression")),
                        fluidRow(
                          column(12,"",verbatimTextOutput("cvboLog"))
                        )
                        
               ),
              tabPanel("Attrition predictor",icon = icon("user-tie"),
                       fluidRow(column(4,"",
                       numericInput("cnrKnn1","Default K",value=3),
                       textInput("ctxName","Employee's name",value = "<Default>"),
                       radioButtons("ccmbOverTime","Over time",lst_over_st),
                       sliderInput("cniMonthIncome","Monthly Income",min=1,max=50000,value=5000),
                       sliderInput("cniStockOp","Stock Option Level(0-->Lowest,3-->Highest)",min=0,max=3,value=1),
                       sliderInput("cniJobLevel","Job Level(1-->Highest,5-->Lowest)",min=1,max=5,value=3),
                       radioButtons("ccmbMaritial","Maritial Status",lst_mar_st),
                       sliderInput("cniYearsCompany","Years at the company",min=1,max=50,value=15),
                       sliderInput("cniJobSatis","Job Satisfaction",min=1,max=4,value=2),
                       actionButton("btnLRunKnnSimul","Run simulation",icon = icon("bolt") ),
                       tags$hr()),
                       column(8,"",
                              tags$h3(tags$strong("Will the employee leave the company?")),
                              tableOutput("ctoRunSimul")),
                       )
              ),
              tabPanel("Monthly Income prediction",icon = icon("sack-dollar"),
                       fluidRow(column(4,"",
                                       textInput("ctxNameR","Employee's name",value = "<Default>"),
                                       sliderInput("cniJobLevelR","Job Level(1-->Lowest,5-->Highest)",min=1,max=5,value=3),
                                       sliderInput("cniYearsCompanyR","Years at the company",min=1,max=50,value=15),
                                       sliderInput("cniYearsCTotalR","Total working years",min=1,max=50,value=15),
                                       actionButton("btnLRunRegre","Run Linear Regression model",icon = icon("bolt") ),
                                       tags$hr()),
                                column(8,"",
                                       tags$h3(tags$strong("Regression Results")),
                                       tableOutput("ctoRunReg"),
                                       plotOutput("plotRegression")),
                                
                       )
              )
  )
)


