
########################################################################################
## GET CONVERGENCE
########################################################################################

# ## EXAMPLE
# test.iter.idx <- c(seq(10,250,10))
# num.ill.idx <- 300
# ACC.data.in <- ACC2_data_full
# mean.CI.overall <- get.conv(test.iter.idx=test.iter.idx, num.ill.idx = num.ill.idx, ACC.data.in = ACC.data.in)


get.conv <- function(test.iter.idx, num.ill.idx, ACC.data.in){
  mean.CI.overall <- NULL
  
  for (i in 1:length(test.iter.idx)) {
    iter.idx <- test.iter.idx[i]
    data.in <- ACC.data.in %>% filter(iter %in% c(1:iter.idx))
    vars.to.plot <- c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry")  
    y.lab.in <- "Accuracy"
    plot.mean = 1
    CI.lvl <- 0.95
    
    y.lim.in <- c(0, 1)
    p_ACC_together <- plot.together.ribbon(data.in=data.in,vars.to.plot=vars.to.plot,CI.lvl=CI.lvl, 
                                           y.lab.in=y.lab.in, y.lim.in=y.lim.in,plot.mean=plot.mean)
    
    CI1 <- ggplot_build(p_ACC_together)$data[[3]]
    CI2 <- CI1 %>% filter(x==num.ill.idx) %>% select(c(group,y,ymin,ymax))
    #CI2
    
    mean1 <- ggplot_build(p_ACC_together)$data[[4]] 
    mean2 <- mean1 %>% filter(x==num.ill.idx) %>% select(c(group,y))
    #mean2
    
    mean.CI <- cbind(CI2, mean2$y)
    mean.CI$y<-NULL
    mean.CI$mean <- mean.CI$"mean2$y"
    mean.CI$"mean2$y" <- NULL
    mean.CI$iter <- iter.idx
    
    mean.CI.overall <- rbind(mean.CI.overall, mean.CI)
  }
  
  ## CONVERT GROUP 1:6 TO NETWORK NAMES
  
  #c("Cheese","Eggs","Meat Products","Milk Products", "Poultry", "Vegetables")
  
  # CI.SigStar_net <- arrange(CI.SigStar_net, desc(CI.SigStar_net$"foodnet"))
  # CI.SigStar_net$N <- NULL
  # CI.out <- CI.SigStar_net
  
  net_i <- vector(length=nrow(mean.CI.overall))
  for (i in 1:length(net_i)){
    if (mean.CI.overall[i,"group"]==1) net_i[i]="cheese"
    if (mean.CI.overall[i,"group"]==2) net_i[i]="eggs"
    if (mean.CI.overall[i,"group"]==3) net_i[i]="meatProducts"
    if (mean.CI.overall[i,"group"]==4) net_i[i]="milkProducts"
    if (mean.CI.overall[i,"group"]==5) net_i[i]="poultry"
    if (mean.CI.overall[i,"group"]==6) net_i[i]="vegetables"
  }
  
  mean.CI.overall$foodnet <- net_i
  
  return(mean.CI.overall)
}


########################################################################################
## PLOTTING CONVERGENCE
########################################################################################

# ## EXAMPLE
# traj.CI <- mean.CI.overall
# chart.title <- "TEST"
# plot.sig <- plot.together.ribbon.conv(traj.CI=traj.CI, y.lab.in="Accuracy", y.max.in=NULL, chart.title=chart.title)
# plot.sig

plot.together.ribbon.conv <- function(traj.CI, y.lab.in, y.max.in, chart.title) {
  
  ###########
  ### traj.CI
  ###########
  
  ## Filter only to variable of interest
  #traj.CI <- traj.CI %>%  dplyr::filter(foodnet %in% vars.to.plot)
  
  #y.max.in <- round(max(traj.CI$ymax))
  
  ## Add title
  traj.CI$title <- chart.title
  
  #####################
  ### colors and names
  #####################
  
  #longnames <- c("Vegetables", "Eggs", "Meat products", "Cheese", "Milk Products","Poultry", "Milk")
  
  longnames <- c("Cheese","Eggs","Meat Products","Milk Products", "Poultry", "Vegetables")
  
  names(longnames) <- c("cheese","eggs","meatProducts","milkProducts","poultry","vegetables")
  
  ## Colors
  
  cols.list <- c(
    "salmon",
    "navajowhite3",
    "olivedrab4",
    "mediumseagreen",
    "mediumturquoise",
    "cyan2",
    "lightskyblue"
  )
  
  names(cols.list) <- names(longnames)
  color.this.var <- as.character(cols.list[c(1:6)])
  
  ##################
  ### CREATE PLOT
  ##################
  
  p <- ggplot(data = traj.CI,
              aes(x = iter,
                  y = mean, ymin = ymin, ymax = ymax,
                  color = foodnet,
                  fill = foodnet,
                  group = foodnet))
  
  p <- p +  geom_ribbon(data = traj.CI,
                        aes(x = iter,
                            y = mean, ymin = ymin, ymax = ymax,
                            color = foodnet,
                            fill = foodnet,
                            group = foodnet),alpha = .5, colour="slategrey",size=.25, inherit.aes=TRUE)
  
  # p <- p +  scale_fill_manual(values = c(color.this.var),labels = longnames) + scale_color_manual(values = c(color.this.var), labels = longnames)
  p <- p + scale_color_brewer(palette="Set1",labels=longnames) + scale_fill_brewer(palette="Set1",labels=longnames)
  p <- p + geom_line(linetype="dashed", colour="slategrey") + geom_ribbon(alpha = 0.2, color = FALSE)
  
  
  ##################
  ## FINISH PLOT
  p <- p + theme_bw() + theme(legend.title = element_blank())
  #p <- p + scale_x_date(limits = as.Date(c(startDatePlot,endDatePlot)), date_breaks = "1 month" , date_labels = "%d-%b-%y")
  p <- p + scale_y_continuous(limits = c(0,y.max.in), breaks = seq(from = 0, to = y.max.in, by = y.max.in/4))
  # p <- p + theme(axis.text.x = element_text(angle = 90),
  #                strip.text.x = element_text(size = 12, face = "bold"))
  p <- p + theme(strip.text.x = element_text(size=12,face="bold"))
  #  p <- p + ylab(paste0("Number  ", as.character(longnames[var.to.plot]))) + xlab(NULL)
  #p <- p + ylab("Probability") + xlab(NULL)
  p <- p + ylab(TeX(y.lab.in)) + xlab("Number of outbreaks")
  #p <- p + labs(title = title.input)
  #p<-p+theme(plot.title = element_text(size = 12, hjust = 0.5, face="bold"))
  p <- p + facet_grid(. ~ title)
  
  p
  
  
  
}



