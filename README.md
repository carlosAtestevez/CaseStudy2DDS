EDA analysis about Employee Attrition by DDSAnalytics
================
Carlos Estevez
SMU University
2023-03-03

## Introduction

DDSAnalytics is a company dedicated to conducting data analysis in different areas aiming to help different organizations to streamline their processes and improve their relationship with their business partnes including customers, vendors, and employees.

In this EDA project DDSAnalytics will conduct an analysis for the Frito-lay organization about employee attrition. The Frito-Lay organization has a problem of attrition and they want to identify the reasons behind it. We will investigate the different parameters correlated to attrition and build a model to predict it

## Content of the project

* <strong>Datasets</strong>: CaseStudy2-data.csv
* <strong>Codebook</strong>: codebook.csv
* <strong>Markdown file</strong>: CaseStudy2DDS.RMD
* <strong>CSS format</strong>: bootstrap.csv(Part of the Markdown)
* <strong>Presentation</strong>: DDSAnalytics Presentation.ppt
* <strong>Knitt file</strong>: CaseStudy2DDS.html
* <strong>Shinny App</strong>: <a href="https://estevez.shinyapps.io/EmployeeAttritionDDS/">Shinny Application</a>

## Datasets
* CaseStudy: In this dataset we have information about Employee Attrition. 
870 observations and 36 variables. 


## Glosary
* Employee Attrition: It is the gradual reduction in employee numbers
* Chi-Square test: It is used in statistics to test the independence of two event
* Oversampling: It is used to balance the dataset in terms of classes and classifications


## Convention

* Name of variables
  + Global DataFrame: df_(Description)
  + Local DataFrame: dfl_(Description)
  + Numeric variable: nr_(Description)
  + String variable: st_(Description)
  + Model: Name of the model_(Description)

## Steps to run the analysis(RMD file)

### Install the following libraries
* tidyverse
* stringr
* caret
* plotly
* ggthemes
* GGally
* class
* e1071
* maps
* usmap
* aws.s3)
* smotefamily

You can use install.packages("library")

### Dowload the CSV source file and update local path

* Update local path: Go to the section "LoadindLocalFile"
in the RMD file and replace the path of the working directory
by your local path in your PC

## Usage

You need to execute each chunk one by one in sequence. It is important
because there are many part of the code that depends on previous Chunks

The project has the folowing Chunks:

* <strong>Libraries</strong>: Loading the libraries. After installing the needed libraries listed previously ,
  you must run this chunk in order to load the libraries
  
* <strong>LoadindLocalFile</strong>: Loading data from CSV file(set the working directory)

* <strong>ConnectingAmazonS3</strong>: We can also load the data from amazon S3.
If we use this option we don't need to execute the previus section.

* <strong>DataManipulation</strong>: We perform oversampling and other numerical conversions
+ Random oversampling involves randomly duplicating examples from the minority class and adding them to the training dataset
* <strong>DataExploration</strong>: We analyze the different parameters related to Attrition
* <strong>DeterminingVariableImportance</strong>: We use Chi-Square to reinforce the feature analysis
+ A chi-square test is used in statistics to test the independence of two events. Given the data of two variables, we can get observed count O and expected count E. Chi-Square measures how expected count E and observed count O deviates each other
+ More information: <a href="https://towardsdatascience.com/chi-square-test-for-feature-selection-in-machine-learning-206b1f0b8223">More information</a>

* <strong>KnnModel</strong>: We build the KNN model to predict Attrition
* <strong>NaiveBayes</strong>: We build the Naive Bayes Model
* <strong>LogisticRegression</strong>: We build the logistic regression model
* <strong>FeatureConSelection</strong>: We perform feature correlation to find
the variables correlated to MonthlyIncome
* <strong>LinearRegressionModel</strong>: We build the linear regression model to
predict the MonthlyIncome


# Shiny Application

<a href="https://estevez.shinyapps.io/EmployeeAttritionDDS/">Shinny Application</a>


## Codebook

The codebook is a CSV file. You will find the most important variables
that we use in the analysis.

# Contacts

* cestevez@smu.com





