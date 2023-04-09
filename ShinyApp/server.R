server <- function(input, output, session) {
  #Reading beer's file
  read_beer_file = function(){
    
    v_type_upd = input$cchS3
    
    if(v_type_upd==TRUE){
      v_key = as.character(input$cpinKey)
      v_akey = as.character(input$cpinAcKey)
      v_buck = input$ctxBucket
      Sys.setenv("AWS_ACCESS_KEY_ID" = v_key,
                 "AWS_SECRET_ACCESS_KEY" = v_akey,
                 "AWS_DEFAULT_REGION"="us-east-2")
      v_obj_beer <- get_object("Beers.csv", bucket = v_buck)
      dfls_beers=read.csv(text = rawToChar(v_obj_beer), sep=",", header = TRUE)
      
    }else{
    fileBeers = input$cflBeers
    ext_file <- tools::file_ext(fileBeers$datapath)
    req(fileBeers)
    dfls_beers = read.csv(fileBeers$datapath,header = TRUE)
    
    }
    return (dfls_beers)
  }
  
  put_img_s3 = function(img){
    v_key = as.character(input$cpinKey)
    v_akey = as.character(input$cpinAcKey)
    v_buck = input$ctxBucket
    v_str_path = str_c("beer_study_img/",img)
    Sys.setenv("AWS_ACCESS_KEY_ID" = v_key,
               "AWS_SECRET_ACCESS_KEY" = v_akey,
               "AWS_DEFAULT_REGION"="us-east-2")
    put_object(img, object = v_str_path, bucket = v_buck)
  }
  
  #Reading breweries's file
  read_brewery_file = function(){
    
    v_type_upd = input$cchS3
    
    if(v_type_upd==TRUE){
      v_key = as.character(input$cpinKey)
      v_akey = as.character(input$cpinAcKey)
      v_buck = input$ctxBucket
      Sys.setenv("AWS_ACCESS_KEY_ID" = v_key,
                 "AWS_SECRET_ACCESS_KEY" = v_akey,
                 "AWS_DEFAULT_REGION"="us-east-2")
      v_obj_brew <- get_object("Breweries.csv", bucket = v_buck)
      dfls_brews=read.csv(text = rawToChar(v_obj_brew), sep=",", header = TRUE)
    }
    else{  
      fileBrew = input$cflBreweries
      ext_file <- tools::file_ext(fileBrew$datapath)
      req(fileBrew)
      dfls_brews = read.csv(fileBrew$datapath,header = TRUE)
    }
    
    
    return (dfls_brews)
  }
  
  
  
  #Data cleansing IBU and ABV
  apply_data_cleansing = function(p_df_beers,p_df_brew,knn_n){
    #Cleaning ABV using mean
    df_beers_cl0 = p_df_beers
    nr_mean_abv = mean(df_beers_cl0[!is.na(df_beers_cl0$ABV),]$ABV) #Calculate the mean
    length_abv = length(df_beers_cl0[is.na(df_beers_cl0$ABV),]$ABV) 
    if(length_abv > 0){
      df_beers_cl0[is.na(df_beers_cl0$ABV),]$ABV = nr_mean_abv      #Replacing Missing value with mean
    }
    
    #Cleaning using KnnInpute
    ##Creating the model K = 20
    knn_imp_model <- preProcess(df_beers_cl0 %>% 
                                  select(ABV,IBU),
                                method = c("knnImpute"),
                                k = 20,
                                knnSummary = mean)
    
    #Running the model
    df_beers_unp <- predict(knn_imp_model, df_beers_cl0,na.action = na.pass)
    #The beer data set will be normalized. To de-normalize and get the original data back:
    procNames <- data.frame(col = names(knn_imp_model$mean), mean = knn_imp_model$mean, sd = knn_imp_model$std)
    for(i in procNames$col){
      df_beers_unp[i] <- df_beers_unp[i]*knn_imp_model$std[i]+knn_imp_model$mean[i] 
    }
    
    #Dataframe Map by State
    df_usa_states_0 = usmapdata::centroid_labels("states")
    df_beerbre_unp = merge(df_beers_unp,p_df_brew,by.x = "Brewery_id",by.y = "Brew_ID")
    
    df_beerbre_unp$State = str_trim(df_beerbre_unp$State)
    df_usa_states_0$abbr = str_trim(df_usa_states_0$abbr)
    df_beerbre_unp_2 = merge(df_beerbre_unp,df_usa_states_0,by.x = "State",by.y="abbr")
    
    lst_par = list("beers"=df_beers_unp,"beerbrew"=df_beerbre_unp_2)
    return (lst_par)
  }
  
  
  
  
  #Plotting IBU variable
  output$ploIBU = renderPlot({
    dfs_beers = read_beer_file()
    dfs_brews = read_brewery_file()
    if(input$cchDS == TRUE){
      df_ret_dc = apply_data_cleansing(dfs_beers,dfs_brews,input$cnrKnn)
      dfs_beers =  df_ret_dc$beerbrew
    }else{
      dfs_beers = merge(dfs_beers,dfs_brews,by.x = "Brewery_id",by.y = "Brew_ID")
    }
    str_state = input$cseStates
    if( str_state != "ALL"  && input$cchDS == TRUE){
      dfs_beers = filter(dfs_beers,full == str_state)
    }
    if(input$cchS3IMG==FALSE){
      if(input$ccsTypePlot == "Histogram"){
        ggplot(dfs_beers,aes(x=IBU))+geom_histogram(fill=input$cciCoIBU,bins = input$cslBrIBU)+
          labs(title="IBU after performing data cleansing",x="IBU(International bitterness Unit)",y="Observation number")
      }else{
        ggplot(dfs_beers,aes(x=IBU))+geom_boxplot()+
          labs(title="IBU after performing data cleansing",x="IBU(International bitterness Unit)",y="Observation number")
      }
    }else{
      if(input$ccsTypePlot == "Histogram"){
        ggplot(dfs_beers,aes(x=IBU))+geom_histogram(fill=input$cciCoIBU,bins = input$cslBrIBU)+
          labs(title="IBU after performing data cleansing",x="IBU(International bitterness Unit)",y="Observation number")
      }else{
        ggplot(dfs_beers,aes(x=IBU))+geom_boxplot()+
          labs(title="IBU after performing data cleansing",x="IBU(International bitterness Unit)",y="Observation number")
      }
      ggsave("IBU.png")
      put_img_s3("IBU.png")
    }

    
  })
  
  
  
  
  #Plotting ABV variable
  output$ploABV = renderPlot({
    dfs_beers = read_beer_file()
    dfs_brews = read_brewery_file()
    if(input$cchDS == TRUE){
      df_ret_dc = apply_data_cleansing(dfs_beers,dfs_brews,input$cnrKnn)
      dfs_beers =  df_ret_dc$beerbrew
    }else{
      dfs_beers = merge(dfs_beers,dfs_brews,by.x = "Brewery_id",by.y = "Brew_ID")
    }
    str_state = input$cseStatesABV
    if( str_state != "ALL" && input$cchDS == TRUE){
      dfs_beers = filter(dfs_beers,full == str_state)
    }
    
    if(input$cchS3IMG==FALSE){
      if(input$ccsTypePlotABV == "Histogram"){
        ggplot(dfs_beers,aes(x=ABV))+geom_histogram(fill=input$cciCoABV,bins = input$cslBrABV)+
          labs(title="ABV after performing data cleansing",x="ABV(Alcohol by Volume)",y="Observation number")
      }else{
        ggplot(dfs_beers,aes(x=ABV))+geom_boxplot()+
          labs(title="ABV after performing data cleansing",x="ABV(Alcohol by Volume)",y="Observation number")
      }
    }
    else{
      if(input$ccsTypePlotABV == "Histogram"){
        ggplot(dfs_beers,aes(x=ABV))+geom_histogram(fill=input$cciCoABV,bins = input$cslBrABV)+
          labs(title="ABV after performing data cleansing",x="ABV(Alcohol by Volume)",y="Observation number")
      }else{
        ggplot(dfs_beers,aes(x=ABV))+geom_boxplot()+
          labs(title="ABV after performing data cleansing",x="ABV(Alcohol by Volume)",y="Observation number")
      }
      ggsave("ABV.png")
      put_img_s3("ABV.png")
    }
    
  
    
  })
  
  
  
  
  #Plotting IBU vs ABV variable
  output$ploABVIBU = renderPlot({
    dfs_beers = read_beer_file()
    dfs_brews = read_brewery_file()
    if(input$cchDS == TRUE){
      df_ret_dc = apply_data_cleansing(dfs_beers,dfs_brews,input$cnrKnn)
      dfs_beers =  df_ret_dc$beerbrew
    }else{
      dfs_beers = merge(dfs_beers,dfs_brews,by.x = "Brewery_id",by.y = "Brew_ID")
    }
    str_state = input$cseStatesAI
    if( str_state != "ALL" && input$cchDS == TRUE){
      dfs_beers = filter(dfs_beers,full == str_state)
    }
    
    if(input$cchS3IMG==FALSE){
      if(input$cchAddLineal == TRUE){
        dfs_beers %>% ggplot(aes(x=ABV,y=IBU))+geom_point()+geom_smooth(method = "lm")+
          labs(title = "Relationship IBU and AVB",subtitle = "Relationship IBU/AVB by Beer Type")+xlab("Alcohol by Volume (ABV)")+ylab("International Bitterness Unit(IBU)")
      }else{  
      dfs_beers %>% ggplot(aes(x=ABV,y=IBU))+geom_point()+
        labs(title = "Relationship IBU and AVB",subtitle = "Relationship IBU/AVB by Beer Type")+xlab("Alcohol by Volume (ABV)")+ylab("International Bitterness Unit(IBU)")
      }
    }
    else{
      if(input$cchAddLineal == TRUE){
        dfs_beers %>% ggplot(aes(x=ABV,y=IBU))+geom_point()+geom_smooth(method = "lm")+
          labs(title = "Relationship IBU and AVB",subtitle = "Relationship IBU/AVB by Beer Type")+xlab("Alcohol by Volume (ABV)")+ylab("International Bitterness Unit(IBU)")
      }else{  
        dfs_beers %>% ggplot(aes(x=ABV,y=IBU))+geom_point()+
          labs(title = "Relationship IBU and AVB",subtitle = "Relationship IBU/AVB by Beer Type")+xlab("Alcohol by Volume (ABV)")+ylab("International Bitterness Unit(IBU)")
      }
      ggsave("IBUvsABV.png")
      put_img_s3("IBUvsABV.png")
    }  
  
  })
  
  
  
  #Plotting MAP
  output$ploAdd = renderPlot({
    dfs_beers = read_beer_file()
    dfs_brews = read_brewery_file()
    df_usa_states_0 = usmapdata::centroid_labels("states")
      if(input$cchDS == TRUE){
        df_ret_dc = apply_data_cleansing(dfs_beers,dfs_brews,input$cnrKnn)
        dfs_beers =  df_ret_dc$beerbrew
      }else{
          dfs_beers = merge(dfs_beers,dfs_brews,by.x = "Brewery_id",by.y = "Brew_ID")
      }
      
      df_berbrew_bystate_0 = group_by(dfs_beers,Brewery_id,Name.y,State) %>% summarize(count_beer = n()) %>% arrange(desc(count_beer)) %>% head(n=input$cnrNrBrew)
      df_berbrew_bystate_0$State = str_trim(df_berbrew_bystate_0$State)
      df_usa_states_0$abbr = str_trim(df_usa_states_0$abbr)
      df_berbrew_bystate_1 = merge(df_berbrew_bystate_0,df_usa_states_0,by.x = "State",by.y = "abbr")
      dfl_berbrew_bystate_1=data.frame(df_berbrew_bystate_1$Name.y,df_berbrew_bystate_1$State,df_berbrew_bystate_1$x,df_berbrew_bystate_1$y,df_berbrew_bystate_1$count_beer)
      colnames(dfl_berbrew_bystate_1)=c("company","state","lon","lat","n")
      if(input$cchS3IMG==FALSE){
      plot_usmap(data = dfl_berbrew_bystate_1, regions = "state", values = "n", fill="indianred",color = "lemonchiffon",labels = TRUE,label_color = "#E69F00") +  ggrepel::geom_label_repel(data = dfl_berbrew_bystate_1,aes(x = lon, y = lat, label =company),
                                                                                                                                                                                            size = 3, alpha = 0.8,
                                                                                                                                                                                            label.r = unit(0.5, "lines"), label.size = 0.5,
                                                                                                                                                                                            segment.color = "black", segment.size = 1)+geom_point(data = dfl_berbrew_bystate_1,
                                                                                                                                                                                                                                                  aes(x = lon, y = lat, size = n),
                                                                                                                                                                                                                                                  color = "navyblue", alpha = 0.5)+scale_size_continuous(range = c(5, 10),name = "Number of American IPA", label = scales::comma)+theme(legend.position = "right")+
        labs(title="Analysis breweries by States",subtitle = "Most popular breweries in the United States")
      }else{
        plot_usmap(data = dfl_berbrew_bystate_1, regions = "state", values = "n", fill="indianred",color = "lemonchiffon",labels = TRUE,label_color = "#E69F00") +  ggrepel::geom_label_repel(data = dfl_berbrew_bystate_1,aes(x = lon, y = lat, label =company),
                                                                                                                                                                                              size = 3, alpha = 0.8,
                                                                                                                                                                                              label.r = unit(0.5, "lines"), label.size = 0.5,
                                                                                                                                                                                              segment.color = "black", segment.size = 1)+geom_point(data = dfl_berbrew_bystate_1,
                                                                                                                                                                                                                                                    aes(x = lon, y = lat, size = n),
                                                                                                                                                                                                                                                    color = "navyblue", alpha = 0.5)+scale_size_continuous(range = c(5, 10),name = "Number of American IPA", label = scales::comma)+theme(legend.position = "right")+
          labs(title="Analysis breweries by States",subtitle = "Most popular breweries in the United States")
        ggsave("MAP.png")
        put_img_s3("MAP.png")
       }
    
 
                                                                                                                                              
  })
  
  output$tbOut=renderTable({
    
    input$cchS3IMG
    # dfs_beers = read_beer_file()
    # dfs_brews = read_brewery_file()
    # if(input$cchDS == TRUE){
    #    df_ret_dc = apply_data_cleansing(dfs_beers,dfs_brews,input$cnrKnn)
    #    dfs_beers =  df_ret_dc$beerbrew
    #    dfs_beers$State = str_trim(dfs_beers$State)
    #    df_usa_states_0 = usmapdata::centroid_labels("states")
    #    df_usa_states_0$abbr = str_trim(df_usa_states_0$abbr)
    #    dfs_beers_2 = merge(dfs_beers,df_usa_states_0,by.x = "State",by.y="abbr")
    #    dfs_beers_2
    # }
  })



}
