


########################################################
## FUNCTIONS

## FUNCTION TO MAKE NUMERIC AND NAME
Matlab_format <- function(data_in, num_iter, prev_max_iter, ill_interval){
  
  # Get the right format
  this_data <- mutate_all(as.data.frame(data_in), function(x) as.numeric(as.character(x)))
  
  # name appropriately
  #ill_interval <- c(seq(20,100,by=20), seq(150,300,by=50))
  colnames(this_data) <- ill_interval
  foodnet <- rep(net_names, each = num_iter)
  iter <- rep(seq(1:num_iter),times=num_nets) + prev_max_iter
  data_named <- cbind(foodnet, iter, this_data)
  data_named_melted <- reshape2::melt(data_named, measure.vars = c(3:ncol(data_named)), variable.name = "num_ill")
  
  return(data_named_melted)
}

## FUNCTION TO GET CI OVERALL AND BY EACH NET
get.CI <- function(data_full, by_net){
  
  #data_full_filter <- data_full %>% filter(foodnet %in% c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry")  )
  #df.data_full <- as.data.table(data_full_filter)
  
  df.data_full <- as.data.table(data_full)
  
  if (by_net==0){
    traj.CI <- df.data_full[, list(
      N=.N,
      mean = mean(value),
      median = quantile(value, c(.5),na.rm=TRUE),
      low_95 = quantile(value, c(.025),na.rm=TRUE),
      up_95 = quantile(value, c(.975),na.rm=TRUE),
      up_50 = quantile(value,.75,na.rm=TRUE),
      low_50 = quantile(value,.25,na.rm=TRUE)),
      by = c("num_ill")]
    traj.CI <- as.data.frame(traj.CI)
  }
  
  if (by_net==1){
    traj.CI.networks <- df.data_full[, list(
      N=.N,
      mean = mean(value),
      median = quantile(value, c(.5),na.rm=TRUE),
      low_95 = quantile(value, c(.025),na.rm=TRUE),
      up_95 = quantile(value, c(.975),na.rm=TRUE),
      up_50 = quantile(value,.75,na.rm=TRUE),
      low_50 = quantile(value,.25,na.rm=TRUE)),
      by = c("num_ill","foodnet")]
    traj.CI <- as.data.frame(traj.CI.networks)
  }
  return(traj.CI)
}

# ########################################################
# ## LOOP TO COMBINE AND PROCESS ALL ACCURACY FILES
# 
# ## Inputs -- names and parameters of ACC files
# acc_inputs <- matrix(nrow=4, ncol=2)
# colnames(acc_inputs) <- c("filename","num_iter")
# acc_inputs[,"filename"] <- c("ACC_SimSig_V10_30_Star_Acc2","ACC_SimSig_V7_30_Star_Acc2","ACC_SimSig_V8_30_Star_Acc2","ACC_SimSig_V9_50_Star_Acc2")
# acc_inputs[,"num_iter"] <- c(30, 30, 30, 50)
# nr_files <- nrow(acc_inputs)
# 
# ## Initialize dataframes and parameters
# ACC1_data_full <- NULL
# ACC2_data_full <- NULL
# rank_data_full <- NULL
# SigStar_data_full <- NULL
# SigStarRatio_data_full <- NULL
# prev_max_iter = 0
# 
# ## Loop to combine and process each file 
# 
# for (file.idx in 1:nr_files){
#   #acc_list_curr <- acc_list[[i]]
#   filename <- acc_inputs[file.idx,1]
#   num_iter <- as.numeric(acc_inputs[file.idx,2])
#   
#   ################## Matlab readin
#   
#   readin_path <- path(Germany.dir, paste0(filename,".csv"))
#   acc_data = read.csv(readin_path, sep=",", header=FALSE) # ,stringsAsFactors = FALSE))
#   
#   ## VARIABLE NAMES
#   #ill_interval <- c(seq(20,100,by=20), seq(150,300,by=50))
#   num_ill_interval <- length(ill_interval)
#   #num_iter <- num_iter
#   num_nets <- 7
#   net_names <- c("vegetables","eggs","meatProducts","cheese","milkProducts","poultry","milk")
#   
#   ## EXTRACT ACC DATA
#   ACC1_data <- t(acc_data[c(1:9),])
#   ACC2_data <- t(acc_data[c(11:19),])
#   rank_data <- t(acc_data[c(21:29),])
#   SigStar_data <- t(acc_data[c(31:39),])
#   SigStarHat_data <- t(acc_data[c(41:49),])
#   
#   ##################
#   
#   ACC1_data <- Matlab_format(ACC1_data, num_iter=num_iter, prev_max_iter=prev_max_iter)
#   ACC1_data_full <- rbind(ACC1_data, ACC1_data_full)
#   
#   ACC2_data <- Matlab_format(ACC2_data, num_iter=num_iter, prev_max_iter=prev_max_iter)
#   ACC2_data_full <- rbind(ACC2_data, ACC2_data_full)
#   
#   rank_data <- Matlab_format(rank_data, num_iter=num_iter, prev_max_iter=prev_max_iter)
#   rank_data_full <- rbind(rank_data, rank_data_full)
#   
#   SigStar_data <- Matlab_format(SigStar_data, num_iter=num_iter, prev_max_iter=prev_max_iter)
#   SigStar_data_full <- rbind(SigStar_data, SigStar_data_full)
#   
#   SigStarRatio_data <- Matlab_format(SigStarRatio_data, num_iter=num_iter, prev_max_iter=prev_max_iter)
#   SigStarRatio_data_full <- rbind(SigStarRatio_data, SigStarHat_data_full)
#   
#   prev_max_iter <- prev_max_iter + num_iter
#   
# }
# 
# ## Get CI overall and for each net, for each accuracy statistic
# CI.ACC1_net <- get.CI(ACC1_data_full, by_net=1)
# CI.ACC1_all <- get.CI(ACC1_data_full, by_net=0)
# CI.ACC2_net <- get.CI(ACC2_data_full, by_net=1)
# CI.ACC2_all <- get.CI(ACC2_data_full, by_net=0)
# CI.rank_net <- get.CI(rank_data_full, by_net=1)
# CI.rank_all <- get.CI(rank_data_full, by_net=0)
# CI.SigStar_net <- get.CI(SigStar_data_full, by_net=1)
# CI.SigStar_all <- get.CI(SigStar_data_full, by_net=0)
# CI.SigStarHat_net <- get.CI(SigStarHat_data_full, by_net=1)
# CI.SigStarHat_all <- get.CI(SigStarHat_data_full, by_net=0)
# 
# 

