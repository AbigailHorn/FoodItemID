

########################################################################################
## PLOTTING OVERALL CI
########################################################################################

## EXAMPLE
# data.in <- SigStar_data_full
# vars.to.plot <- c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry")
# y.lab.in <- "Norm-Sig $\\hat{N}$" #"Rank"
# y.lim.in <- c(0.6,1)
# CI.lvl <- 0.95
# plot.overall.ribbon(data.in, vars.to.plot, CI.lvl, y.lab.in, y.lim.in)


plot.overall.ribbon <- function(data.in, vars.to.plot, CI.lvl, y.lab.in, y.lim.in){
  
  my_theme=theme(legend.title = element_blank() , 
                 axis.title.x = element_text(size = 16), 
                 axis.text.x = element_text(size = 12), 
                 axis.title.y = element_text(size = 16),
                 axis.text.y = element_text(size = 12))
  
  ## Select vars.to.plot
  #data <- data.in %>% filter (foodnet %in% vars.to.plot)
  data <- data.in
  data$num_ill <- as.numeric(as.character(data$num_ill))
  
  ggplot(data, aes(x=as.numeric(num_ill), y=value))+ 
    #stat_summary(geom="ribbon", fun.data=mean_cl_normal, 
    #             fun.args=list(conf.int=0.95), fill="lightblue")+
    stat_summary(geom="ribbon", fun.data=mean_cl_normal, fun.args=list(conf.int=CI.lvl), colour=NA ,alpha=0.25)+  
    stat_summary(geom="line", fun=mean, linetype="dashed") + 
    stat_summary(geom="point", fun=mean, colour="slategrey") +
    theme_bw() + my_theme +
    xlab("Illness cases (c)") + ylab(TeX(y.lab.in)) +
    coord_cartesian(ylim = y.lim.in)
  #stat_summary(geom="point", fun=mean, color="red")
  
}


########################################################################################
## PLOTTING MULTIPLE TOGETHER
########################################################################################

# ## EXAMPLE
# data.in <- SigStarHat_data_full
# vars.to.plot <- c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry")
# CI.lvl <- 0.5
# y.lab.in <- "Rank"
# y.lim.in <- c(.65,1)
# plot.mean = 1
# plot.together.ribbon(data.in=data.in,vars.to.plot=vars.to.plot,CI.lvl=CI.lvl, y.lab.in=y.lab.in, y.lim.in=y.lim.in,plot.mean=plot.mean)

plot.together.ribbon <- function(data.in, vars.to.plot, CI.lvl, x.lab.in, y.lab.in, y.lim.in, plot.mean, include.legend=TRUE, include.title=FALSE){
  
  include.legend=TRUE
  include.title=FALSE
  my_theme=theme(legend.title = element_blank() , 
                 legend.text = element_text(size = 14),
                 axis.title.x = element_text(size = 16), 
                 axis.text.x = element_text(size = 14), 
                 axis.title.y = element_text(size = 16),
                 axis.text.y = element_text(size = 14))
  if (include.legend==FALSE){
    my_theme= theme(legend.position = "none", 
                    legend.text = element_text(size = 14),
                    axis.title.x = element_text(size = 16), 
                    axis.text.x = element_text(size = 14), 
                    axis.title.y = element_text(size = 16),
                    axis.text.y = element_text(size = 14))
  }
  if (include.title!=FALSE){
    my_theme= theme(legend.title = element_blank() ,
                    legend.text = element_text(size = 14),
                    axis.title.x = element_text(size = 16), 
                    axis.text.x = element_text(size = 14), 
                    axis.title.y = element_text(size = 16),
                    axis.text.y = element_text(size = 14),
                    plot.title = element_text(size = 16, hjust = 0.5))
  }
  
  ## Select vars.to.plot
 # data <- data.in %>% filter (foodnet %in% vars.to.plot)
  data <- data.in
  data$num_ill <- as.numeric(as.character(data$num_ill))
  
  ## Names
  # longnames <- c("Meat Products", "Cheese","Eggs","Milk Products", "Poultry", "Vegetables")
  # names(longnames) <- c("meatProducts",   "cheese",         "eggs",    "milkProducts", "poultry",      "vegetables")   
  longnames <- paste0("RLG",c(1:6))
  names <- as.character(1:6)
  
  # ## scale_color_manual
  # nb = length(vars.to.plot)
  # nm = 2
  # myColors = apply(expand.grid(seq(70,40,length=nm), 100, seq(15,375,length=nb+1)[1:nb]), 1, function(x) hcl(x[3],x[2],x[1]))
  # fullColors <- myColors[c(FALSE,TRUE)]
  # cols.list <- c(fullColors)
  # names(cols.list) <- names(longnames)
  # color.this.var <- as.character(cols.list[vars.to.plot])
  
  #col.pal <- "Set2"
  
  ## Plot
  if (plot.mean==0){
    p <- ggplot(data, aes(x=(num_ill), y=value, color=foodnet, fill=foodnet))+ 
      stat_summary(geom="ribbon", fun.data=mean_cl_normal,
                   fun.args=list(conf.int=CI.lvl), alpha=0.5, colour="slategrey", size=.25)+
      #stat_summary(geom="ribbon", fun.data=mean_cl_normal, colour=NA ,alpha=0.1)+  
      stat_summary(geom="line", fun=mean, linetype="dashed", colour="slategrey")+
      #stat_summary(geom="point", fun=mean, colour="slategrey") +
      theme_bw() + my_theme + 
      #scale_y_continuous(limits = c(0, 1))+ #, breaks = seq(from = y.min.in, to = y.max.in, by = (y.max.in-y.min.in)/5))+
      scale_color_brewer(palette="Set1",labels=longnames) + scale_fill_brewer(palette="Set1",labels=longnames) +
      xlab((x.lab.in)) + ylab(TeX(y.lab.in)) +
      coord_cartesian(ylim = y.lim.in)
    if (include.title!=FALSE){
      p <- p + ggtitle(include.title)
    }
  }
  
  else if (plot.mean==1){
    p <- ggplot(data, aes(x=(num_ill), y=value))+ 
      stat_summary(geom="ribbon", fun.data=mean_cl_normal, fun.args=list(conf.int=CI.lvl), colour="black", size=0.25, alpha=0.25)+  
      stat_summary(geom="line", fun=mean, linetype="dotted", size=0.5) + 
      
      stat_summary(aes(x=(num_ill), y=value, color=foodnet, fill=foodnet), geom="ribbon", fun.data=mean_cl_normal,
                   fun.args=list(conf.int=CI.lvl), alpha=0.5, colour="slategrey", size=.25)+
      stat_summary(aes(x=(num_ill), y=value, color=foodnet, fill=foodnet), geom="line", fun=mean, linetype="dashed", colour="slategrey") +
      theme_bw() + my_theme +
      scale_color_brewer(palette="Set1",labels=longnames) + scale_fill_brewer(palette="Set1",labels=longnames) +
      xlab((x.lab.in)) + ylab(TeX(y.lab.in)) +
      coord_cartesian(ylim = y.lim.in)
    if (include.title!=FALSE){
      p <- p + ggtitle(include.title)
    }
  }
  #scale_fill_manual(values = c(cols.list),labels = longnames) + scale_color_manual(values = c(cols.list), labels = longnames)
  return(p)
}


########################################################################################
## PLOTTING MULTIPLE TOGETHER -- ARCHIVE
########################################################################################

## EXAMPLE
# vars.to.plot <- c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry")
# plot.sig <- plot.together.ribbon.archive(traj.CI=traj.CI.networks, vars.to.plot=vars.to.plot,y.lab.in="1 / entropy", y.max.in=NULL, chart.title="Baseline Signal: Synthetic Outbreaks")
# plot.sig

plot.together.ribbon.archive <- function(traj.CI=traj.CI.networks, vars.to.plot, y.lab.in, y.max.in, chart.title) {
  
  ###########
  ### traj.CI
  ###########
  
  ## Filter only to variable of interest
  traj.CI <- traj.CI %>%  dplyr::filter(foodnet %in% vars.to.plot)
  
  y.max.in <- round(max(traj.CI$up_95))
  
  ## Add title
  traj.CI$title <- chart.title
  
  #####################
  ### colors and names
  #####################
  
  longnames <- c("Vegetables", "Eggs", "Meat products", "Cheese", "Milk Products","Poultry", "Milk")
  
  names(longnames) <- c("vegetables",   "eggs",         "meatProducts",    "cheese",       "milkProducts", "poultry",      "milk")   
  
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
  color.this.var <- as.character(cols.list[vars.to.plot])
  
  ##################
  ### CREATE PLOT
  ##################
  
  p <- ggplot(data = traj.CI,
              aes(x = num_ill,
                  y = mean, ymin = low_50, ymax = up_50,
                  color = foodnet,
                  fill = foodnet,
                  group = foodnet))
  
  p <- p +  geom_ribbon(data = traj.CI,
                        aes(x = num_ill,
                            y = mean, ymin = low_50, ymax = up_50,
                            color = foodnet,
                            fill = foodnet,
                            group = foodnet),alpha = .5, inherit.aes=TRUE, color=FALSE)
  
  p <- p +  scale_fill_manual(values = c(color.this.var),labels = longnames) + scale_color_manual(values = c(color.this.var), labels = longnames)
  p <- p + geom_line() + geom_ribbon(alpha = 0.2, color = FALSE)
  
  
  ##################
  ## FINISH PLOT
  p <- p + theme_bw() + theme(legend.title = element_blank())
  #p <- p + scale_x_date(limits = as.Date(c(startDatePlot,endDatePlot)), date_breaks = "1 month" , date_labels = "%d-%b-%y")
  p <- p + scale_y_continuous(limits = c(0,y.max.in), breaks = seq(from = 0, to = y.max.in, by = y.max.in/10))
  p <- p + theme(axis.text.x = element_text(angle = 90),
                 strip.text.x = element_text(size = 12, face = "bold"))
  #  p <- p + ylab(paste0("Number  ", as.character(longnames[var.to.plot]))) + xlab(NULL)
  #p <- p + ylab("Probability") + xlab(NULL)
  p <- p + ylab(y.lab.in) + xlab(NULL)
  #p <- p + labs(title = title.input)
  #p<-p+theme(plot.title = element_text(size = 12, hjust = 0.5, face="bold"))
  p <- p + facet_grid(. ~ title)
  
  
  p
  
  
  
}

