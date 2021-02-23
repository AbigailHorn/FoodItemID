


########################################################################################
## PLOTTING MULTIPLE CONFIDENCE INTERVALS TOGETHER
########################################################################################

plot.together.capacity <- function(traj.CI=traj.CI, data.in=data.in, endDatePlot=endDatePlot, vars.to.plot, y.lab.in, y.max.in, chart.title, plot.capacity, plot.annotations) {

  ###########
  ### traj.CI
  ###########

  ## Filter only to variable of interest
  traj.CI <- traj.CI %>%  dplyr::filter(state.name %in% vars.to.plot)

  ## Select only more recent dates
  init.date <- as.Date("2020-03-01")
  startDatePlot <- init.date #
  endDatePlot <- as.Date(endDatePlot) #startDatePlot + time.steps.4plot #- 40  # the constant 40 because the traj are not aligned to start date
  traj.CI <- traj.CI %>% dplyr::filter(date >= startDatePlot) %>% dplyr::filter(date < endDatePlot)

  ## Add title
  traj.CI$title <- chart.title

  ###########
  ### data.in
  ###########

  ## Data in -- plot only for the selected variable
  if(!is.null(data.in)){

    if(any(vars.to.plot %in% colnames(data.in))) {  # FIX LATER -- REMOVE TMP

      ## Filter only to variable of interest
      vars.to.extract <- vars.to.plot[vars.to.plot %in% colnames(data.in) ]

      data.in<- data.in %>% dplyr::select(vars.to.extract)

      ## ALIGN DATES: DATA
      no_obs <- nrow(data.in)
      step <- 0:(no_obs-1)
      date <- init.date + step
      data.date <- cbind(date,data.in)
      rownames(data.date) <- date
      #data.date$date <- NULL

      ## Select only more recent dates
      data.date <- data.date %>% dplyr::filter(date > startDatePlot)
      data.processed <- reshape2::melt(data.date, measure.vars = c(2:ncol(data.date)), variable.name = "state.name")
    }

    else {data.processed = NULL}
  }

  #####################
  ### colors and names
  #####################

  longnames <- c("Susceptible",
                 "New Obs. Infected",
                 "Current Obs. Infected",
                 "Cum. Obs. Infected",
                 "Current Tot. Infected",
                 "Cum. Tot. Infected",
                 "New in Hospital",
                 "Current in Hospital",
                 "Cum. in Hospital",
                 "Current in ICU",
                 "Cum. in ICU",
                 "Current Ventilation",
                 "Cum. Ventilation",
                 "New Deaths",
                 "Cum. Deaths",
                 "Recovered",
                 "R0(t)",
                 "Alpha(t)",
                 "Kappa(t)",
                 "Delta(t)",
                 "r(t)",
                 "CFR",
                 "IFR",
                 "R(t) NPI=Observed",
                 "R(t) NPI=Moderate",
                 "R(t) NPI=None",
                 "Alpha(t) Protect=Observed",
                 "Kappa(t) Protect=Observed",
                 "Delta(t) Protect=Observed",
                 "Alpha(t) Protect=100",
                 "Kappa(t) Protect=100",
                 "Delta(t) Protect=100",
                 "Alpha(t) Protect=50",
                 "Kappa(t) Protect=50",
                 "Delta(t) Protect=50"
  )

  names(longnames) <-  c(
    "S",
    "I_detect_new",
    "I",
    "Idetectcum",
    "Itot",
    "Itotcum",
    "H_new",
    "Htot",
    "Htotcum",
    "Q",
    "Qcum",
    "V",
    "Vcum",
    "D_new",
    "D",
    "R",
    "Rt",
    "Alpha_t",
    "Kappa_t",
    "Delta_t",
    "r_t",
    "CFR",
    "IFR",
    "NPI.Obs",
    "NPI.Mod",
    "NPI.None",
    "Alpha.Protect.0",
    "Kappa.Protect.0",
    "Delta.Protect.0",
    "Alpha.Protect.100",
    "Kappa.Protect.100",
    "Delta.Protect.100",
    "Alpha.Protect.50",
    "Kappa.Protect.50",
    "Delta.Protect.50"
  )

  ## Colors

  cols.list <- c(
    "salmon",
    "sandybrown",
    "navajowhite3",
    "olivedrab4",
    "olivedrab2",
    "mediumseagreen",
    "mediumaquamarine",
    "mediumturquoise",
    "cyan2",
    "lightskyblue",
    "steelblue2",
    "mediumpurple",
    "mediumorchid",
    "plum1",
    "violetred1",
    "deeppink4",
    "grey50",
    "mediumturquoise",
    "lightskyblue",
    "violetred1",
    "grey50",
    "grey50",
    "grey50",
    ## R(t) Scenarios
    "deeppink1",
    "cornflowerblue",
    "antiquewhite4",
    ## A K D Scenarios
    # A
    "aquamarine4",
    "aquamarine3",
    "aquamarine2",
    # K
    "deepskyblue4",
    "deepskyblue",
    "darkslategray2",
    # D
    "deeppink4",
    "deeppink",
    "darkorange3"
  )

  names(cols.list) <- names(longnames)
  color.this.var <- as.character(cols.list[vars.to.plot])

  ##################
  ### CREATE PLOT
  ##################

  p <- ggplot(data = traj.CI,
              aes(x = date,
                  y = median, ymin = low_95, ymax = up_95,
                  color = state.name,
                  fill = state.name,
                  group = state.name))

  p <- p +  geom_ribbon(data = traj.CI,
                        aes(x = date,
                            y = median, ymin = low_50, ymax = up_50,
                            color = state.name,
                            fill = state.name,
                            group = state.name),alpha = .5, inherit.aes=TRUE, color=FALSE)

  p <- p +  scale_fill_manual(values = c(color.this.var),labels = longnames) + scale_color_manual(values = c(color.this.var), labels = longnames)
  p <- p + geom_line() + geom_ribbon(alpha = 0.2, color = FALSE)

  if(!is.null(data.in)){
    p <- p + geom_point(data = data.processed,
                        aes(x = date, y = value,
                            color = state.name),
                        alpha = 0.7,
                        inherit.aes = FALSE)
  }

  ##################
  ## ADD CAPACITY
  if (!is.null(plot.capacity)){
    ##################
    ### CREATE CAPACITY DATA FRAME
    capacity.vals <- as.data.frame(matrix(NA, nrow=length(levels(traj.CI$state.name)), ncol=2))
    capacity.vals[,1] <- levels(traj.CI$state.name)
    rownames(capacity.vals) <- levels(traj.CI$state.name)
    capacity.vals["Htot",2] <- 4000
    capacity.vals["Q",2] <- 2245
    capacity.vals["V",2] <-1000
    colnames(capacity.vals) <- c("state.name","capacity")
    ##################
    ### ADD CAPACITY LINES
    capacity.vals <- capacity.vals %>% filter(state.name %in% vars.to.plot)
    p <- p + geom_hline(data = capacity.vals, aes(yintercept=capacity),linetype = "dashed", colour="azure4")
  }

  #################
  ## ADD DATE ANNOTATIONS
  if (!is.null(plot.annotations)){

    ######### Create data frame with annotations
    traj.CI.date <- as.data.frame(matrix(NA, nrow=8, ncol=3))
    colnames(traj.CI.date) <- c("date","date.label","y.place")
    traj.CI.date$date <- c(as.Date("2020-03-19"),as.Date("2020-05-08"),as.Date("2020-06-12"),as.Date("2020-07-01"),as.Date("2020-08-18"),as.Date("2020-10-31"),as.Date("2020-11-26"),as.Date("2020-12-25"))
    traj.CI.date$date.label <- c("Stage I", "Stage II", "Stage III", "Modifications", "School Year", "Halloween", "Thanksgiving","Christmas")
    traj.CI.date$y.place <- c(1:8)

    ######### Add data frame with annotations
    p <- p + geom_vline(data=traj.CI.date, aes(xintercept=as.Date(date)), linetype="dashed",colour="azure4", size=.35) +
      # annotate("text", label = traj.CI.date$date.label, x = traj.CI.date$date, y = (y.max.in/2)+(y.max.in/20)*traj.CI.date$y.place, size = 3.5, colour = "black")
      annotate("text", label = traj.CI.date$date.label, x = traj.CI.date$date, y = (y.max.in)-(y.max.in/25)*traj.CI.date$y.place, size = 3.5, colour = "black")
  }

  ##################
  ## FINISH PLOT
  p <- p + theme_bw() + theme(legend.title = element_blank())
  p <- p + scale_x_date(limits = as.Date(c(startDatePlot,endDatePlot)), date_breaks = "1 month" , date_labels = "%d-%b-%y")
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


########################################################################################
## CREATING THE PLOT
########################################################################################

#traj.CI.ex <- traj.0 %>% filter(state.name %in% c("Itot","I"))
#saveRDS(traj.CI.ex, file = "data4plot.rds")
readRDS(file = "data4plot.rds")  # The name of the dataframe necessary for the plot is traj.CI.ex

data.in <- NULL
y.max.in <- traj.CI.ex %>% filter(state.name=="Itot") %>% select(up_95) %>% max() %>% round(digits=-5) + 50000
y.lab.in <- "Current Infections"
vars.to.plot<-c("Itot","I")
endDatePlot <- as.Date("2021-02-16")
chart.title <- "Current Infections Observed and Unobserved"
data.in <- NULL
infections_plot <- plot.together.capacity(traj.CI=traj.CI.ex, data.in=data.in, endDatePlot=endDatePlot, vars.to.plot = vars.to.plot, y.lab.in=y.lab.in, y.max.in=y.max.in, chart.title=chart.title, plot.capacity=NULL, plot.annotations=TRUE)
infections_plot


