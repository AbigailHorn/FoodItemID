########################################################################################
## PLOTTING MULTIPLE TOGETHER
########################################################################################
## USED IN:
## plot.param.t
## CFR.IFR.plots

vars.to.plot <- c("vegetables",   "eggs",         "sausageTC",    "cheese",       "milkProducts", "poultry")  
plot.sig <- plot.together.ribbon(traj.CI=sig.CI, vars.to.plot=vars.to.plot,y.lab.in="1 / entropy", y.max.in=NULL, chart.title="Baseline Signal: Synthetic Outbreaks")

plot.together.ribbon <- function(traj.CI=traj.CI, vars.to.plot, y.lab.in, y.max.in, chart.title) {
  
  ###########
  ### traj.CI
  ###########
  
  ## Filter only to variable of interest
  traj.CI <- traj.CI %>%  dplyr::filter(foodnet %in% vars.to.plot)
  
  ## Add title
  traj.CI$title <- chart.title
  
  #####################
  ### colors and names
  #####################
  
  longnames <- c("Vegetables", "Eggs", "Meat products", "Cheese", "Milk Products","Poultry", "Milk")
  
  names(longnames) <- c("vegetables",   "eggs",         "sausageTC",    "cheese",       "milkProducts", "poultry",      "milk")   
  
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
                  y = mean, ymin = low_95, ymax = up_95,
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
  #p <- p + scale_y_continuous(limits = c(0,y.max.in), breaks = seq(from = 0, to = y.max.in, by = y.max.in/10))
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

