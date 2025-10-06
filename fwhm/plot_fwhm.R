setwd("C:/myfolderBaby_7T") #directory with data tables
library(tidyverse)
library(NHANES)
#library(remotes) for pattern
#library(ggpattern) for pattern
# library(lme4) # Package that provides multilevel modeling with lmer()
# library(lmerTest) # Used to estimate degrees of freedom for LMER
# library(emmeans) #for post hoc test with lmer

#txt files created in previous step are accumulated as .csv file
#this plot only includes 7T 1.6mm data and not 1.25mm data
data_overview <- read.csv( "FWHM_PB0015-22.csv", header=TRUE, sep=",") %>%
  filter(condition!='7T_highres')


sum.fwhm <- data_overview %>%                               # Summary by group using dplyr
  group_by(space, condition) %>% 
  summarize(mean = mean(fwhm),
            std = sd(fwhm))


data_overview$space <- factor(data_overview$space, levels = c('native', 'MNI'))


data_overview %>% 
  ggplot(aes(
    x=condition, 
    y=fwhm, 
    color=condition
  )) +
  geom_point(size=3, show.legend = FALSE)+
  scale_color_manual(values = c("3T" = "#8F0644", "7T" = "#13A885"))+
  ylab("FWHM") +
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
    facet_grid(cols = vars(sub), rows = vars(space), scales = "free_y")
 
  


