setwd("C:/Users/moser297/Box/ION/ION_Data_analysis/Baby3T-7Tpaper/R scripts/") #directory with data tables
library(tidyverse)
library(NHANES)

data1 <- read.csv( "Connectivity_strength_numbers_short.csv", sep=",")
data2 <- data1 %>% 
  filter(stats == 'sd')
data3 <- data1 %>% 
  filter(stats == 'mean')
data4 <- data1 %>% 
  filter(stats == 'median')
data5 <- data1 %>% 
  filter(stats == '5thpercentile')
data6 <- data1 %>% 
  filter(stats == '95thpercentile')


ggplot(data3, aes(x = condition, y = values, color = condition)) +
  geom_point(size = 5) +
  ylab("absolute connectivity strength") +
  facet_grid(cols = vars(SUB)) +
  geom_errorbar(aes(
    x = condition,
    ymin = values - data2$values,
    ymax = values + data2$values
  )) +
  geom_point(aes(
    x = condition,
    y = data4$values,
    color = condition
  ), shape = 4, size = 5) +
  geom_point(aes(
    x = condition,
    y = data5$values,
    color = condition
  ), shape = 4, size = 5) +
  geom_point(aes(
    x = condition,
    y = data6$values,
    color = condition
  ), shape = 4, size = 5) +
  theme_bw() +
  theme(text = element_text(size = 18),
        axis.title.x = element_blank())+
  scale_color_manual(values = c("3T" = "#8F0644", "7T" = "#13A885"))
