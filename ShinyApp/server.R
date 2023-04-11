server <- function(input, output, session) {
  #Loading data
  loading_data_s3 = reactive({
    v_type_upd = input$crbLoadData
    if(v_type_upd=="ddset"){
      Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIA5HRB7XJNIOKHMHYK",
                 "AWS_SECRET_ACCESS_KEY" = "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",
                 "AWS_DEFAULT_REGION"="us-east-2")
    }else{
      v_key = as.character(input$cpinKey)
      v_akey = as.character(input$cpinAcKey)
      v_buck = input$ctxBucket
      Sys.setenv("AWS_ACCESS_KEY_ID" = v_key,
                 "AWS_SECRET_ACCESS_KEY" = v_akey,
                 "AWS_DEFAULT_REGION"="us-east-2")
    }
    
    
    #Retrieving three datasets
    obj_main_ds = get_object("CaseStudy2-data.csv", bucket = "ddsproject1")
    df_std_1=read.csv(text = rawToChar(obj_main_ds), sep=",", header = TRUE)
    df_std_1
  })
  
  loading_file = reactive({
    fileAttrFile = input$cflAttrFile
    # showNotification(fileAttrFile$datapath)
    # v_count = str_count(fileAttrFile$datapath)
    
   #  
    if(is.null(fileAttrFile)){

      shinyFeedback::feedbackDanger("cflAttrFile",TRUE,"Select a file!")
   }
    
    req(fileAttrFile)
    ext_file <- tools::file_ext(fileAttrFile$datapath)
    df_att_file = read.csv(fileAttrFile$datapath,header = TRUE)
    df_att_file
  })
  
  load_data_over = reactive({
    vl_ind_over = input$cchOV
    
    showNotification("Loading data...")
    Sys.sleep(1)
    v_load_option = input$crbLoadData
    if(v_load_option=="ddset"){
      showNotification("Loading from Amazon S3...")
      df_raw_data = loading_data_s3()
    }else{
      showNotification("Loading file...")
      df_raw_data = loading_file()
    }
    
    if(vl_ind_over==TRUE){
      vlnr_len_0 = nrow(df_raw_data )
      df_nos = filter(df_raw_data ,Attrition == "No")
      df_yeses = filter(df_raw_data ,Attrition == "Yes")
      vlnr_len_no = nrow(df_nos) 
      vlnr_len_yeses = nrow(df_yeses)
      vlnr_balance = vlnr_len_no - vlnr_len_yeses
      df_add_yeses = df_yeses[sample(seq(1,vlnr_len_yeses,1),vlnr_balance,replace = TRUE),]
      df_new_yeses = rbind(df_yeses,df_add_yeses)
      df_raw_data_over = rbind(df_new_yeses,df_nos)
    }else{
      df_raw_data_over = df_raw_data
    }
    
    
    #Categorical variables to Factor
    df_raw_data_over$BusinessTravel = factor(df_raw_data_over$BusinessTravel)
    df_raw_data_over$MonthlyIncomeScaled = scale(df_raw_data_over$MonthlyIncome)
    #df_raw_data_over$MonthlyIncomeScaled = df_raw_data_over$MonthlyIncome/1000
    df_raw_data_over$Attrition = factor(df_raw_data_over$Attrition)
    df_raw_data_over$Department = factor(df_raw_data_over$Department)
    df_raw_data_over$Education = factor(df_raw_data_over$Education)
    df_raw_data_over$EducationField = factor(df_raw_data_over$EducationField)
    df_raw_data_over$EnvironmentSatisfaction = factor(df_raw_data_over$EnvironmentSatisfaction)
    df_raw_data_over$Gender = factor(df_raw_data_over$Gender)
    df_raw_data_over$JobLevel0 = factor(df_raw_data_over$JobLevel)
    df_raw_data_over$JobLevel = factor(df_raw_data_over$JobLevel,levels = c(5,4,3,2,1),
                                       labels = c("Senior management","Middle management","First-level management","Intermediate or experienced","Entry-level"))
    df_raw_data_over$JobRole = factor(df_raw_data_over$JobRole)
    df_raw_data_over$JobInvolvement = factor(df_raw_data_over$JobInvolvement)
    df_raw_data_over$JobSatisfaction = factor(df_raw_data_over$JobSatisfaction)
    df_raw_data_over$MaritalStatus = factor(df_raw_data_over$MaritalStatus)
    df_raw_data_over$OverTime = factor(df_raw_data_over$OverTime)
    df_raw_data_over$RelationshipSatisfaction = factor(df_raw_data_over$RelationshipSatisfaction)
    df_raw_data_over$Over18 = factor(df_raw_data_over$Over18)
    df_raw_data_over$StockOptionLevel = factor(df_raw_data_over$StockOptionLevel)

    # #Categorical variables to numeric
    df_raw_data_over$JobSatisfactionN = factor(df_raw_data_over$JobSatisfaction)
    df_raw_data_over$EnvironmentSatisfactionN = factor(df_raw_data_over$EnvironmentSatisfaction)
    df_raw_data_over$OverTimeN = as.numeric(df_raw_data_over$OverTime)
    df_raw_data_over$MaritalStatusN = as.numeric(df_raw_data_over$MaritalStatus)
    df_raw_data_over$JobRoleN = as.numeric(df_raw_data_over$JobRole)
    df_raw_data_over$JobLevelN = as.numeric(df_raw_data_over$JobLevel)
    df_raw_data_over$JobLevelN2 = as.numeric(df_raw_data_over$JobLevel0)
    df_raw_data_over$GendeN = as.numeric(df_raw_data_over$Gender)
    df_raw_data_over$BusinessTravelN = as.numeric(df_raw_data_over$BusinessTravel)
    df_raw_data_over$AttritionN = as.numeric(df_raw_data_over$Attrition)
    df_raw_data_over$StockOptionLevelN = as.numeric(df_raw_data_over$StockOptionLevel)
    df_raw_data_over$JobInvolvementN = as.numeric(df_raw_data_over$JobSatisfactionN)

    #Continuous variables to numeric
    df_raw_data_over$MonthlyIncome = as.numeric(df_raw_data_over$MonthlyIncome)
    df_raw_data_over$DistanceFromHome = as.numeric(df_raw_data_over$DistanceFromHome)
    df_raw_data_over$YearsInCurrentRole = as.numeric(df_raw_data_over$YearsInCurrentRole)
    df_raw_data_over$YearsAtCompany = as.numeric(df_raw_data_over$YearsAtCompany)
    df_raw_data_over$YearsWithCurrManager = as.numeric(df_raw_data_over$YearsWithCurrManager)
    df_raw_data_over$EmployeeNumber = as.numeric(df_raw_data_over$EmployeeNumber)
    df_raw_data_over$TotalWorkingYears = as.numeric(df_raw_data_over$TotalWorkingYears)
    df_raw_data_over$Age = as.numeric(df_raw_data_over$Age)
    df_raw_data_over
    
    
  })
  
  reactive_load_data=eventReactive(input$btnLoadData,{
    df_raw_data_over = load_data_over()
    df_raw_data_over
  })
  
  run_knn_model = reactive({
    df_raw_data_over = load_data_over()
    df_data_model_0 = select(df_raw_data_over,Attrition,MonthlyIncomeScaled,YearsAtCompany,
                             OverTimeN,JobLevelN,JobSatisfactionN,MaritalStatusN,StockOptionLevelN)
    nr_percentage = input$cslKnnPer
    nr_len = nrow(df_data_model_0)
    nr_len = nrow(df_data_model_0)
    df_samples = sample(1:nr_len,round(nr_len*(nr_percentage/100)))
    df_lst_train = df_data_model_0[df_samples,]
    df_lst_test = df_data_model_0[-df_samples,]
    
    #Iterations
    lst_ki_index = as.numeric(input$cniKnn)
    lst_knn_data = data.frame(K=numeric(lst_ki_index) ,Accuracy=numeric(lst_ki_index) )
    #Finding the best K
    withProgress({
        for(ki in 1:lst_ki_index){
          knn_results = knn(df_lst_train[,c(2:8)], df_lst_test[,c(2:8)], df_lst_train$Attrition, k = ki, prob = TRUE)
          table_result = table(knn_results,df_lst_test$Attrition)
          co_matrix  = confusionMatrix(table_result)
          lst_knn_data$K[ki] = ki
          lst_knn_data$Accuracy[ki] = round(co_matrix$overall[1],2)
        }
      incProgress(1/lst_ki_index)
    })
    arrange(lst_knn_data,desc(nr_percentage))
    
  })
  
  run_knn_simul = reactive({
    df_raw_data_over = load_data_over()
    # df_data_model_0 = select(df_raw_data_over,Attrition,MonthlyIncomeScaled,YearsAtCompany,
    #                          OverTimeN,JobLevelN,JobSatisfactionN,MaritalStatusN,StockOptionLevelN)
    df_data_model_0 = select(df_raw_data_over,Attrition,MonthlyIncomeScaled,
                             OverTimeN,JobLevelN2,StockOptionLevelN,MaritalStatusN,YearsAtCompany)
    
    
    vl_monthly_inc = as.numeric(input$cniMonthIncome)
    vl_monthly_inc_scale = (vl_monthly_inc- mean(df_raw_data_over$MonthlyIncome))/sd(df_raw_data_over$MonthlyIncome)
    #vl_monthly_inc_scale = vl_monthly_inc / 1000
    vl_years_company = as.numeric(input$cniYearsCompany)
    vl_over_time = input$ccmbOverTime
    if(vl_over_time=="Yes"){
      vl_over_timen = 2
    }else{
      vl_over_timen = 1
    }
    vl_job_lev = as.numeric(input$cniJobLevel)
    vl_job_sat = as.numeric(input$cniJobSatis)
    vl_stock = as.numeric(input$cniStockOp)
    vl_mat_st = input$ccmbMaritial
    if(vl_mat_st=="Divorced"){
      vl_mat_stn = 1
    }
    if(vl_mat_st=="Married"){
      vl_mat_stn = 2
    }
    if(vl_mat_st=="Single"){
      vl_mat_stn = 3
    }
    
    
    ds_predict_model_0 = data.frame(MonthlyIncomeScaled=vl_monthly_inc_scale,
                                    OverTimeN=vl_over_timen,JobLevelN2=vl_job_lev,StockOptionLevelN=vl_stock,
                                    MaritalStatusN = vl_mat_st,YearsAtCompany=vl_years_company
                                    )
    
    # 
    # ds_predict_model_0 = data.frame(MonthlyIncomeScaled=vl_monthly_inc_scale,
    #                                 YearsAtCompany = vl_years_company,
    #                                 OverTimeN=vl_over_timen,
    #                                 JobLevelN=vl_job_lev,
    #                                 JobSatisfactionN=vl_job_sat,
    #                                 MaritalStatusN=vl_mat_st,
    #                                 StockOptionLevelN=vl_stock)
    # knn_nattr = knn(df_data_model_0[,c(2:8)], ds_predict_model_0, df_data_model_0$Attrition, k = 3,prob = TRUE)
    # 

     knn_nattr = knn(df_data_model_0[,c(2:7)], ds_predict_model_0, df_data_model_0$Attrition, k = input$cnrKnn1,prob = TRUE)
    
     data_res_knn = data.frame(Name = input$ctxName,Result_Knn=knn_nattr,Probability=mean(attributes(knn_nattr)$prob))
     ds_predict_model_0$Result = knn_nattr
     ds_predict_model_0$Probability = mean(attributes(knn_nattr)$prob)
    
     data_res_knn
  })
  
  event_run_knn_model =  eventReactive(input$btnLRunKnn,{
    showNotification("Running model...")
    run_knn_model()
  })
  event_run_simul = eventReactive(input$btnLRunKnnSimul,{
    showNotification("Running simulation...")
    data_result = run_knn_simul()
    # v_msg = data_result$Result
    # if(v_msg=="Yes"){
    #   v_msg = "The chance of attrition is really high!"
    # }else{
    #   v_msg = "The chance of attrition is low"
    # }
    # showModal(modalDialog(
    #   title = "Algorithm result",
    #   v_msg
    # ))
    data_result
  })
  
  output$cboLoadData=renderPrint({
    
    df_raw_data_over = reactive_load_data()
    nr_obs = nrow(df_raw_data_over)
    nr_obs_yes = nrow(df_raw_data_over %>% filter(Attrition=="Yes"))
    nr_obs_no = nrow(df_raw_data_over %>% filter(Attrition=="No"))
    df_raw_data_vo = data.frame(obs=nr_obs,yes_obs=nr_obs_yes,no_obs=nr_obs_no)
    
    vl_ind_over = input$cchOV
    if(vl_ind_over == TRUE){
      showNotification("Oversampling perfomed...")
    }
    str_format = sprintf("Total observations: %i,Yes(s):%i,No(s):%i",df_raw_data_vo$obs,df_raw_data_vo$yes_obs,
                         df_raw_data_vo$no_obs)
    str_format
  })
  
  output$ctoRunModel = renderDataTable({
    event_run_knn_model()
  })
  output$ploKnnModel=renderPlot({
    pl_data_model = event_run_knn_model()
    pl_data_model %>% ggplot(aes(x=K,y=Accuracy,fill=K))+geom_bar(stat="identity")+
      scale_y_continuous(labels=scales::percent)+labs(title="KNN Model K-values",
                                                      x="K",y="Percentage(%)")
    
  })
  
  output$ctoRunSimul=renderTable({
    event_run_simul()
    
    
  })
  output$ploSimul=renderPlot({
    df_raw_data_over = load_data_over()
    df_raw_data_over %>% ggplot(aes(x=MonthlyIncome))+geom_histogram()
  })
  
  

  
  
  run_regression_model = reactive({
    df_raw_data_over = load_data_over()
    
    vl_job_level = as.numeric(input$cniJobLevelR)
    vl_years_company = as.numeric(input$cniYearsCompanyR)
    vl_total_company = as.numeric(input$cniYearsCTotalR)
    
    df_train_lm = select(df_raw_data_over,MonthlyIncome,JobLevelN2,YearsAtCompany,TotalWorkingYears)
    df_std_mi = data.frame(JobLevelN2 = input$cniJobLevelR,YearsAtCompany=vl_years_company,
                           TotalWorkingYears=vl_total_company)
    
    df_test_lm = select(df_std_mi,JobLevelN2,YearsAtCompany,TotalWorkingYears)
    
    lm_model_0 = lm(MonthlyIncome~JobLevelN2+YearsAtCompany+TotalWorkingYears,data = df_raw_data_over)
    lm_model_pre_0 = predict(lm_model_0,newdata = df_test_lm)
    data_regession = data.frame(Amount=lm_model_pre_0,AmountFor= paste0("$", formatC(as.numeric(lm_model_pre_0), format="f", digits=2, big.mark=",")),JobLevel=vl_job_level)
    data_regession
  })
  
  event_regression_model =  eventReactive(input$btnLRunRegre,{
    run_regression_model()
  })
  
  
  
  
  output$plotRegression=renderPlot({
    df_raw_data_over = load_data_over()
    df_amount = event_regression_model()
    df_raw_data_over %>% ggplot(aes(x=JobLevelN2,y=MonthlyIncome))+geom_jitter(color="darkgreen")+
      scale_y_continuous(labels=scales::dollar)+labs(title = "Linear regression model",subtitle = "Monthly Income prediction",x="JobLevel",y="Monthly Income($)")+
      geom_smooth(method="lm")+geom_point(aes(x=df_amount$JobLevel,y=df_amount$Amount),color="red",size=10)
  })
  
  output$ctoRunReg=renderTable({
   
    df_raw_data_over = load_data_over()
    
    data_result = event_regression_model()
    data.frame(Amount=data_result$AmountFor,JobLevel=data_result$JobLevel)
    #df_model_result$MonthlyIncome
  })
  
  output$plotOver=renderPlot({
    df_std_unp = reactive_load_data()
    #People working overtime and Roles overtime
    df_std_unp %>% ggplot(aes(x=Attrition,fill=OverTime))+geom_bar()+
      theme(axis.text.x = element_text(angle = 45,hjust=1))+
      labs(title = "Attrition by Work Overtime",x="Attrition",y="Number of Employees")
  })
  
  output$plotJobLevel=renderPlot({
    df_std_unp = reactive_load_data()
    df_std_unp %>% ggplot(aes(x=OverTime,fill=JobRole))+geom_bar()+theme(axis.text.x = element_text(angle = 45,hjust=1))+
      labs(title = "Overtime by Job Role",x="Work Overtime",y="Number of Overtime")
  })
  
  output$plotJobLevelMonth=renderPlot({
    df_std_unp = reactive_load_data()
    #People working overtime and Roles overtime
    df_std_unp %>% ggplot(aes(x=JobLevelN2,y=MonthlyIncome))+
      geom_jitter(color="darkgreen")+geom_smooth(method = "lm",aes(x=JobLevelN2,y=MonthlyIncome))+labs(title = "Linear regression model",subtitle = "Monthly Income prediction",x="JobLevel",y="Monthly Income($)")+scale_y_continuous(labels=scales::dollar)
    
  })




}
