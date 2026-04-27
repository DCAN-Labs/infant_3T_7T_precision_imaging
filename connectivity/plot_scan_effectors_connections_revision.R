setwd("C:/mypth/revision") #directory with data tables
library(tidyverse)
library(NHANES)


data_overview <- read.csv( "results_scan_vs_effector_right.csv", header=TRUE, sep=",") #%>%
  #filter(condition!='7T_highres')


sum.connections <- data_overview %>%                               # Summary by group using dplyr
  group_by(ID, magnet, network) %>% 
  summarize(mean = mean(value),
            std = sd(value))

data_summary <- function(x) {
  m <- mean(x)
  ymin <- m-sd(x)
  ymax <- m+sd(x)
  return(c(y=m,ymin=ymin,ymax=ymax))
}

data_overview %>% 
  ggplot(aes(
    x=magnet, 
    y=value, 
    color=network, 
    fill=network
  )) +
  geom_bar(stat = "summary", position = "dodge")+
  geom_jitter(size=3, shape = 21, stroke = 1.5, fill="white", show.legend = FALSE, position=position_dodge(0.8))+
  scale_color_manual(values = c("SCAN" = "#000000", "effector" = "#828282"))+
  scale_fill_manual(values = c("SCAN" = "#000000", "effector" = "#828282"))+
  ylab("connectivity") +
  theme_bw() +
  theme(
    strip.text.y = element_text(size = 18),
    text = element_text(size = 18),
    legend.title = element_blank(),
    axis.text.x=element_text(angle = 90, size=16, color="black", vjust=0.5),
    axis.text.y=element_text(size=18, color="black"),
    axis.title.y = element_text(size = 18),
    axis.title.x = element_blank(),
    #panel.border = element_blank(),
    axis.line = element_line(colour = "black")
    )+
    #facet_grid(cols = vars(sub), rows = vars(space))
    facet_grid(cols = vars(ID))
#p + stat_summary(fun.data=data_summary, color="blue")

